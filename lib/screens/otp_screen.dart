// Importation des différentes dépendances nécessaires au fonctionnement de cet écran
import 'package:allobricoapp/provider/auth_provider.dart';  // Fournisseur d'authentification personnalisé
import 'package:allobricoapp/screens/home_screen.dart';  // Écran d'accueil
import 'package:allobricoapp/screens/user_information_screen.dart';  // Écran d'informations utilisateur
import 'package:allobricoapp/utils/utils.dart';  // Utilitaires
import 'package:allobricoapp/widgets/custom_button.dart';  // Bouton personnalisé
import 'package:flutter/material.dart';  // Package principal de Flutter pour la création de l'interface utilisateur
import 'package:pinput/pinput.dart';  // Package pour l'entrée de code PIN
import 'package:provider/provider.dart';  // Package pour la gestion des états via le pattern Provider

// Déclaration du widget OtpScreen en tant que StatefulWidget
class OtpScreen extends StatefulWidget {
  final String verificationId;  // Identifiant de vérification OTP
  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

// État associé à OtpScreen
class _OtpScreenState extends State<OtpScreen> {
  String? otpCode;  // Variable pour stocker le code OTP saisi

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context, listen: true).isLoading;  // État de chargement
    return Scaffold(
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(251, 53, 105, 1),
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.arrow_back),  // Icône de retour en arrière
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 200,
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                          "assets/image3.png",  // Image de vérification
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Vérification",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Entrez le code envoyé à votre numéro de téléphone",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Widget pour l'entrée du code PIN
                      Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color.fromRGBO(251, 53, 105, 1),
                            ),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onCompleted: (value) {
                          setState(() {
                            otpCode = value;  // Met à jour le code OTP saisi
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: CustomButton(
                          text: "Vérifier",
                          onPressed: () {
                            if (otpCode != null) {
                              verifyOtp(context, otpCode!);  // Vérifie le code OTP saisi
                            } else {
                              showSnackBar(context, "Entrez le code à 6 chiffres");
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Vous n'avez reçu aucun code ?",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Renvoyer un nouveau code",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(251, 53, 105, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Fonction pour vérifier le code OTP
  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: userOtp,
      onSuccess: () {
        // Vérifie si l'utilisateur existe dans la base de données
        ap.checkExistingUser().then(
          (value) async {
            if (value == true) {
              // L'utilisateur existe dans notre application
              ap.getDataFromFirestore().then(
                    (value) => ap.saveUserDataToSP().then(
                          (value) => ap.setSignIn().then(
                                (value) => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),  // Navigue vers l'écran d'accueil
                                    ),
                                    (route) => false),
                              ),
                        ),
                  );
            } else {
              // Nouvel utilisateur
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserInfromationScreen()),  // Navigue vers l'écran d'informations utilisateur
                  (route) => false);
            }
          },
        );
      },
    );
  }
}
