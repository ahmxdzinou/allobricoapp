// Importation des différentes dépendances nécessaires au fonctionnement de l'application
import 'package:allobricoapp/provider/auth_provider.dart';  // Fournisseur d'authentification personnalisé
import 'package:allobricoapp/screens/welcome_screen.dart';  // Écran d'accueil de l'application
import 'package:firebase_core/firebase_core.dart';  // Package pour initialiser Firebase
import 'package:flutter/material.dart';  // Package principal de Flutter pour la création de l'interface utilisateur
import 'package:provider/provider.dart';  // Package pour la gestion des états via le pattern Provider

// Point d'entrée principal de l'application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Assure que les widgets Flutter sont initialisés avant de continuer
  await Firebase.initializeApp();  // Initialisation de Firebase
  runApp(const MyApp());  // Exécute l'application en utilisant la classe MyApp
}

// Classe principale de l'application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Configuration des providers pour l'application
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),  // Fournisseur pour la gestion de l'authentification
      ],
      // Définition de l'application Flutter
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,  // Désactive le bandeau de débogage
        home: WelcomeScreen(),  // Définit l'écran d'accueil de l'application
        title: "AlloBricoApp",  // Titre de l'application
      ),
    );
  }
}
