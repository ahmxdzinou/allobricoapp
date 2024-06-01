// Importation des différentes dépendances nécessaires au fonctionnement de cet écran
import 'package:allobricoapp/screens/booking_form.dart';  // Écran du formulaire de réservation
import 'package:allobricoapp/widgets/drawer.dart';  // Menu latéral personnalisé
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore pour la base de données cloud
import 'package:firebase_auth/firebase_auth.dart';  // Authentification Firebase
import 'package:flutter/material.dart';  // Package principal de Flutter pour la création de l'interface utilisateur

// Déclaration du widget HomeScreen en tant que StatefulWidget
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// État associé à HomeScreen
class _HomeScreenState extends State<HomeScreen> {
  late List<DocumentSnapshot> workers = [];  // Liste des travailleurs

  @override
  void initState() {
    super.initState();
    fetchWorkersByCategory("plombier");  // Chargement initial des plombiers
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset(
              'assets/menu.png',  // Icône du menu
              width: 25,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      drawer: const MyDrawer(),  // Menu latéral personnalisé
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Section supérieure avec dégradé et texte
            Container(
              height: 330,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 25, right: 25, top: 60),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50.0),
                    bottomLeft: Radius.circular(50.0)),
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    colors: [Color.fromRGBO(255, 250, 182, 1), Color.fromRGBO(255, 239, 78, 1)]),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 60),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Expanded(
                          flex: 4,
                          child: Text('Des Pros \nEn Votre Main',
                              style: TextStyle(
                                  fontSize: 25,
                                  letterSpacing: -1.0,
                                  fontWeight: FontWeight.w800,
                                  color: Color.fromRGBO(72, 72, 72, 1)))),
                      Expanded(
                        flex: 3,
                        child: Image.asset('assets/image4.png'),  // Image illustrative
                      ),
                    ],
                  )
                ],
              ),
            ),
            // Champ de recherche
            Transform.translate(
              offset: const Offset(0, -35),
              child: Container(
                height: 60,
                padding: const EdgeInsets.only(left: 20, top: 5),
                margin: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.grey[350]!, blurRadius: 20, offset: const Offset(0, 10))],
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.white),
                child: const TextField(
                  decoration: InputDecoration(
                      suffixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 23,
                      ),
                      border: InputBorder.none,
                      hintText: 'Rechercher'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Boutons de catégorie
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CategoryButton(
                      category: 'plombier',
                      onPressed: fetchWorkersByCategory,
                    ),
                    CategoryButton(
                      category: 'electricien',
                      onPressed: fetchWorkersByCategory,
                    ),
                    CategoryButton(
                      category: 'peintre',
                      onPressed: fetchWorkersByCategory,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
            // Liste horizontale des travailleurs
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  return WorkerCard(
                    workerData: workers[index] as QueryDocumentSnapshot,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour récupérer les travailleurs par catégorie depuis Firestore
  void fetchWorkersByCategory(String category) {
    FirebaseFirestore.instance
      .collection('workers')
      .where('workerType', isEqualTo: category)
      .get()
      .then((QuerySnapshot querySnapshot) {
      setState(() {
        workers = querySnapshot.docs;  // Mise à jour de la liste des travailleurs
      });
    });
  }
}

// Widget pour les boutons de catégorie
class CategoryButton extends StatelessWidget {
  final String category;
  final Function(String) onPressed;

  const CategoryButton({Key? key, required this.category, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(10)),
        backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(251, 53, 105, 0.1)),
      ),
      onPressed: () => onPressed(category),
      child: Text(
        category,
        style: const TextStyle(
          color: Color.fromRGBO(251, 53, 105, 1),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Widget pour les cartes des travailleurs
class WorkerCard extends StatefulWidget {
  final QueryDocumentSnapshot workerData;

  const WorkerCard({Key? key, required this.workerData}) : super(key: key);

  @override
  _WorkerCardState createState() => _WorkerCardState();
}

class _WorkerCardState extends State<WorkerCard> {
  bool isFavorite = false;  // État du favori
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Card(
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(251, 233, 239, 1),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // Position de l'ombre
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(widget.workerData['profilePic']),  // Image de profil
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.workerData['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white, // Couleur de fond du cercle
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0,
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    size: 23,
                                    color: isFavorite ? Colors.red : Color.fromARGB(255, 222, 222, 222),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isFavorite = !isFavorite;
                                      if (isFavorite) {
                                        FirebaseFirestore.instance
                                            .collection('favorites')
                                            .add({
                                              'userId': user!.uid,
                                              'workerId': widget.workerData.id,
                                            });
                                      } else {
                                        FirebaseFirestore.instance
                                            .collection('favorites')
                                            .where('userId', isEqualTo: user!.uid)
                                            .where('workerId', isEqualTo: widget.workerData.id)
                                            .get()
                                            .then((querySnapshot) {
                                          for (var doc in querySnapshot.docs) {
                                            doc.reference.delete();
                                          }
                                        });
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.workerData['workerType'],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(255, 78, 140, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Text(
                  widget.workerData['bio'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookingForm(workerUid: widget.workerData.id),  // Navigue vers le formulaire de réservation
                        ),
                      );
                    },
                    child: const Text(
                      'Contacter',
                      style: TextStyle(
                        fontSize: 16, // Taille de la police
                        fontWeight: FontWeight.bold, // Poids de la police
                      ),
                    ),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(255, 253, 254, 1)),
                      foregroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(251, 53, 105, 1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
