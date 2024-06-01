import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:allobricoapp/screens/booking_form.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user!.uid)
            .get(),
        builder: (context, snapshot) {
          // Afficher un indicateur de chargement si les données ne sont pas encore prêtes
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Afficher un message si aucun favori n'est trouvé
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No favorites found.'));
          }

          // Récupérer les IDs des travailleurs favoris
          final favoriteWorkerIds = snapshot.data!.docs.map((doc) => doc['workerId']).toList();

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('workers')
                .where(FieldPath.documentId, whereIn: favoriteWorkerIds)
                .get(),
            builder: (context, snapshot) {
              // Afficher un indicateur de chargement si les données ne sont pas encore prêtes
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Afficher un message si aucun travailleur n'est trouvé
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No workers found.'));
              }

              // Construire la liste des cartes des travailleurs
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final workerData = snapshot.data!.docs[index];

                  return WorkerCard(
                    workerData: workerData,
                    onRemove: () {
                      // Supprimer un travailleur des favoris
                      FirebaseFirestore.instance
                          .collection('favorites')
                          .where('userId', isEqualTo: user!.uid)
                          .where('workerId', isEqualTo: workerData.id)
                          .get()
                          .then((querySnapshot) {
                        for (var doc in querySnapshot.docs) {
                          doc.reference.delete();
                        }
                        setState(() {});
                      });
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Widget pour afficher les informations d'un travailleur
class WorkerCard extends StatelessWidget {
  final QueryDocumentSnapshot workerData;
  final VoidCallback onRemove;

  const WorkerCard({Key? key, required this.workerData, required this.onRemove}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(15),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Affichage de la photo de profil du travailleur
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(workerData['profilePic']),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Affichage du nom du travailleur
                  Text(
                    workerData['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Affichage du type de travailleur
                  Text(
                    workerData['workerType'],
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(255, 78, 140, 1),
                    ),
                  ),
                ],
              ),
            ),
            // Bouton pour envoyer un message au travailleur
            IconButton(
              icon: const Icon(
                Icons.message,
                color: Colors.black,
                size: 26,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingForm(workerUid: workerData.id),
                  ),
                );
              },
            ),
            const SizedBox(width: 20),
            // Bouton pour supprimer le travailleur des favoris
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 29),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
