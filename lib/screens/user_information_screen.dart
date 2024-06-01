// Importation des différentes dépendances nécessaires au fonctionnement de cet écran
import 'dart:io';  // Pour la gestion des fichiers

import 'package:allobricoapp/model/user_model.dart';  // Modèle de données pour l'utilisateur
import 'package:allobricoapp/provider/auth_provider.dart';  // Fournisseur d'authentification personnalisé
import 'package:allobricoapp/screens/home_screen.dart';  // Écran d'accueil principal
import 'package:allobricoapp/utils/utils.dart';  // Utilitaires divers
import 'package:allobricoapp/widgets/custom_button.dart';  // Bouton personnalisé
import 'package:flutter/material.dart';  // Package principal de Flutter pour la création de l'interface utilisateur
import 'package:provider/provider.dart';  // Package pour la gestion des états via le pattern Provider

// Déclaration du widget UserInformationScreen en tant que StatefulWidget
class UserInfromationScreen extends StatefulWidget {
  const UserInfromationScreen({super.key});

  @override
  State<UserInfromationScreen> createState() => _UserInfromationScreenState();
}

// État associé à UserInformationScreen
class _UserInfromationScreenState extends State<UserInfromationScreen> {
  File? image;  // Variable pour stocker l'image de profil sélectionnée
  final nameController = TextEditingController();  // Contrôleur pour le champ de texte du nom
  final emailController = TextEditingController();  // Contrôleur pour le champ de texte de l'email
  final bioController = TextEditingController();  // Contrôleur pour le champ de texte de la bio

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
  }

  // Fonction pour sélectionner une image
  void selectImage() async {
    image = await pickImage(context);  // Utilise une fonction utilitaire pour sélectionner une image
    setState(() {});  // Met à jour l'état de l'application
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context, listen: true).isLoading;  // Indicateur de chargement
    return Scaffold(
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(251, 53, 105, 1),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
                child: Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => selectImage(),
                        child: image == null
                            ? const CircleAvatar(
                                backgroundColor: Color.fromRGBO(251, 53, 105, 1),
                                radius: 50,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 90,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                backgroundImage: FileImage(image!),
                                radius: 50,
                              ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        margin: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            // Champ de texte pour le nom
                            textFeld(
                              hintText: "Nom & Prénom",
                              icon: Icons.account_circle,
                              inputType: TextInputType.name,
                              maxLines: 1,
                              controller: nameController,
                            ),
                            // Champ de texte pour l'email
                            textFeld(
                              hintText: "abc@example.com",
                              icon: Icons.email,
                              inputType: TextInputType.emailAddress,
                              maxLines: 1,
                              controller: emailController,
                            ),
                            // Champ de texte pour la bio
                            textFeld(
                              hintText: "Entrer votre bio ici...",
                              icon: Icons.edit,
                              inputType: TextInputType.name,
                              maxLines: 1,
                              controller: bioController,
                            ),
                          ],
                        ), 
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: CustomButton(
                          text: "Continuer",
                          onPressed: () => storeData(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Widget personnalisé pour les champs de texte
  Widget textFeld({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: const Color.fromRGBO(251, 53, 105, 1),
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color.fromRGBO(251, 53, 105, 1),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
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
          fillColor: const Color.fromARGB(255, 255, 230, 236),
          filled: true,
        ),
      ),
    );
  }

  // Fonction pour stocker les données utilisateur dans la base de données
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    UserModel userModel = UserModel(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      bio: bioController.text.trim(),
      profilePic: "",
      createdAt: "",
      phoneNumber: "",
      uid: "",
    );
    if (image != null) {
      ap.saveUserDataToFirebase(
        context: context,
        userModel: userModel,
        profilePic: image!,
        onSuccess: () {
          ap.saveUserDataToSP().then(
                (value) => ap.setSignIn().then(
                      (value) => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                          (route) => false),
                    ),
              );
        },
      );
    } else {
      showSnackBar(context, "Please upload your profile photo");  // Affiche un message d'erreur si aucune photo n'est sélectionnée
    }
  }
}
