// Importation des différentes dépendances nécessaires au fonctionnement de cet écran
import 'package:allobricoapp/provider/auth_provider.dart';  // Fournisseur d'authentification personnalisé
import 'package:allobricoapp/widgets/custom_button.dart';  // Bouton personnalisé
import 'package:country_picker/country_picker.dart';  // Package pour la sélection de pays
import 'package:flutter/material.dart';  // Package principal de Flutter pour la création de l'interface utilisateur
import 'package:provider/provider.dart';  // Package pour la gestion des états via le pattern Provider

// Déclaration du widget RegisterScreen en tant que StatefulWidget
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// État associé à RegisterScreen
class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController phoneController = TextEditingController();  // Contrôleur pour le champ de texte du numéro de téléphone

  // Pays sélectionné par défaut
  Country selectedCountry = Country(
    phoneCode: "213", 
    countryCode: "DZ", 
    e164Sc: 0, 
    geographic: true, 
    level: 1, 
    name: "Algeria", 
    example: "Algeria", 
    displayName: "Algeria", 
    displayNameNoCountryCode: "DZ", 
    e164Key: "", 
  );

  @override
  Widget build(BuildContext context) {
    // Positionne le curseur à la fin du texte dans le champ de texte du numéro de téléphone
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              children: [
                // Affiche une image
                Container(
                  width: 300,
                  height: 300,
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    "assets/image2.png",
                  ),
                ),
                const SizedBox(height: 20),
                // Titre de la page
                const Text(
                  "Inscription",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Sous-titre de la page
                const Text(
                  "Ajoutez votre numéro, Nous vous enverrons un code de vérification",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Champ de texte pour entrer le numéro de téléphone
                TextFormField(
                  cursorColor:  const Color.fromRGBO(251, 53, 105, 1),
                  controller: phoneController,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (value) {
                    setState(() {
                      phoneController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Entrer votre numéro",
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        onTap: () {
                          // Affiche le sélecteur de pays
                          showCountryPicker(
                            context: context,
                              countryListTheme: const CountryListThemeData(
                                bottomSheetHeight: 550,
                              ),
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              }
                          );
                        },
                        // Affiche le drapeau et le code du pays sélectionné
                        child: Text(
                          "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                          style: const TextStyle(
                            fontSize: 19,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Icône de validation si le numéro de téléphone est valide
                    suffixIcon: phoneController.text.length > 9
                        ? Container(
                            height: 30,
                            width: 30,
                            margin: const EdgeInsets.all(10.0),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                            child: const Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Bouton pour envoyer le numéro de téléphone
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                      text: "Login", onPressed: () => sendPhoneNumber()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fonction pour envoyer le numéro de téléphone pour l'authentification
  void sendPhoneNumber() {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String phoneNumber = phoneController.text.trim();
    ap.signInWithPhone(context, "+${selectedCountry.phoneCode}$phoneNumber");
  }
}
