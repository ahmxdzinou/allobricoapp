// Importation des différentes dépendances nécessaires au fonctionnement de l'écran d'accueil
import 'package:allobricoapp/provider/auth_provider.dart';  // Fournisseur d'authentification personnalisé
import 'package:allobricoapp/screens/home_screen.dart';  // Écran d'accueil principal
import 'package:allobricoapp/screens/register_screen.dart';  // Écran d'inscription
import 'package:allobricoapp/widgets/custom_button.dart';  // Bouton personnalisé
import 'package:flutter/material.dart';  // Package principal de Flutter pour la création de l'interface utilisateur
import 'package:provider/provider.dart';  // Package pour la gestion des états via le pattern Provider

// Déclaration du widget WelcomeScreen en tant que StatefulWidget
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// État associé à WelcomeScreen
class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Récupère l'instance d'AuthProvider sans écouter les changements
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      // Utilisation de SafeArea pour éviter les zones d'encoche et de barre de statut
      body: SafeArea(
        // Centre le contenu à l'écran
        child: Center(
          // Ajoute des marges internes autour du contenu
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            // Utilise une colonne pour organiser les widgets verticalement
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Affiche une image
                Image.asset(
                  "assets/image1.png",
                  height: 300,
                ),
                const SizedBox(height: 20),
                // Affiche un texte avec le titre de l'application
                const Text(
                  "Allo Brico !",
                  style: TextStyle(
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Affiche une sous-titre
                const Text(
                  "Trouvez les pros dont vous avez besoin, en un clin d'œil!",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Bouton personnalisé
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    onPressed: () async {
                      // Si l'utilisateur est déjà connecté
                      if (ap.isSignedIn == true) {
                        // Récupère les données depuis le Shared Preferences et navigue vers HomeScreen
                        await ap.getDataFromSP().whenComplete(
                              () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              ),
                            );
                      } else {
                        // Si l'utilisateur n'est pas connecté, navigue vers RegisterScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      }
                    },
                    text: "C'est parti",  // Texte du bouton
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
