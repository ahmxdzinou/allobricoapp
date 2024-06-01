// Importation des différentes dépendances nécessaires au fonctionnement de cet écran
import 'package:allobricoapp/model/request_model.dart';  // Modèle de requête
import 'package:allobricoapp/provider/auth_provider.dart';  // Fournisseur d'authentification
import 'package:allobricoapp/screens/home_screen.dart';  // Écran d'accueil
import 'package:allobricoapp/utils/utils.dart';  // Utilitaires
import 'package:allobricoapp/widgets/custom_button.dart';  // Bouton personnalisé
import 'package:flutter/material.dart';  // Package principal de Flutter pour la création de l'interface utilisateur
import 'package:provider/provider.dart';  // Gestion de l'état

// Déclaration du widget BookingForm en tant que StatefulWidget
class BookingForm extends StatefulWidget {
  final String workerUid;  // UID du travailleur
  const BookingForm({super.key, required this.workerUid});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

// État associé à BookingForm
class _BookingFormState extends State<BookingForm> {
  final TitleController = TextEditingController();  // Contrôleur pour le titre
  final DescriptionController = TextEditingController();  // Contrôleur pour la description

  @override
  void dispose() {
    super.dispose();
    TitleController.dispose();
    DescriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context, listen: true).isLoading;  // Vérifie si une opération de chargement est en cours
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Form'),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 255, 179, 0),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  textFeld(
                    hintText: "Titre de problème",
                    icon: Icons.title,
                    inputType: TextInputType.text,
                    controller: TitleController,
                  ),
                  SizedBox(height: 20.0),
                  textFeld(
                    hintText: "Description de problème ",
                    icon: Icons.description,
                    inputType: TextInputType.text,
                    controller: DescriptionController,
                  ),
                  SizedBox(height: 20.0),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: CustomButton(
                      text: "Valider",
                      onPressed: () {
                        saveRequestDataToFirestore(context);  // Sauvegarde des données de la requête dans Firestore
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget pour les champs de texte
  Widget textFeld({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: const Color.fromRGBO(251, 53, 105, 1),
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          prefixIcon: Container(
            child: Icon(
              icon,
              size: 30,
              color: const Color.fromRGBO(251, 53, 105, 1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: const Color.fromARGB(255, 255, 236, 241),
          filled: true,
        ),
      ),
    );
  }

  // Fonction pour sauvegarder les données de la requête dans Firestore
  void saveRequestDataToFirestore(BuildContext context) async {
    try {
      final ap = Provider.of<AuthProvider>(context, listen: false);  // Fournisseur d'authentification
      
      BookingModel bookingModel = BookingModel(
        title: TitleController.text.trim(),
        description: DescriptionController.text.trim(),
        requesterName: ap.userModel.name,  // Nom du demandeur
        requesterId: ap.uid,  // UID du demandeur
        workerId: widget.workerUid,  // UID du travailleur
        createdAt: DateTime.now(),
        status: 'En cours',  // Statut initial
      );
      
      await ap.saveRequestDataToFirestore(
        bookingModel: bookingModel,
        onSuccess: () {
          ap.saveUserDataToSP().then(
            (value) => ap.setSignIn().then(
              (value) => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),  // Navigation vers l'écran d'accueil
                ),
                (route) => false,
              ),
            ),
          );
        },
        onError: () {
          // Gérer l'erreur si les données de la requête ne peuvent pas être sauvegardées
          showSnackBar(context, "Failed to save request data");
        },
      );
    } catch (error) {
      // Gérer les erreurs éventuelles
      print('Error storing request data: $error');
      // Afficher un message d'erreur
      showSnackBar(context, "Failed to store request data");
    }
  }
}
