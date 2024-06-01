import 'dart:convert';
import 'dart:io';

import 'package:allobricoapp/model/request_model.dart';  // Modèle de requête
import 'package:allobricoapp/model/user_model.dart';  // Modèle d'utilisateur
import 'package:allobricoapp/screens/otp_screen.dart';  // Écran OTP
import 'package:allobricoapp/utils/utils.dart';  // Utilitaires
import 'package:cloud_firestore/cloud_firestore.dart';  // Firestore
import 'package:firebase_auth/firebase_auth.dart';  // Authentification Firebase
import 'package:firebase_storage/firebase_storage.dart';  // Stockage Firebase
import 'package:flutter/material.dart';  // Package principal Flutter
import 'package:shared_preferences/shared_preferences.dart';  // Préférences partagées

// Fournisseur d'authentification étendu à partir de ChangeNotifier
class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;  // État de la connexion
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;  // État de chargement
  bool get isLoading => _isLoading;
  String? _uid;  // UID de l'utilisateur
  String get uid => _uid!;
  UserModel? _userModel;  // Modèle d'utilisateur
  UserModel get userModel => _userModel!;

  // Instances Firebase
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Met à jour l'état de chargement et notifie les auditeurs
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Constructeur: Vérifie l'état de la connexion lors de l'initialisation
  AuthProvider() {
    checkSign();
  }

  // Vérifie si l'utilisateur est connecté en utilisant les préférences partagées
  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  // Met à jour l'état de connexion dans les préférences partagées
  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // Connexion avec un numéro de téléphone
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  // Vérification de l'OTP
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user;

      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vérifie si l'utilisateur existe déjà dans Firestore
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("users").doc(_uid).get();
    if (snapshot.exists) {
      print("USER EXISTS");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // Sauvegarde des données utilisateur dans Firebase
  void saveUserDataToFirebase({
    required BuildContext context,
    required UserModel userModel,
    required File profilePic,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Télécharge l'image de profil dans Firebase Storage
      await storeFileToStorage("profilePic/$_uid", profilePic).then((value) {
        userModel.profilePic = value;
        userModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        userModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        userModel.uid = _firebaseAuth.currentUser!.uid;
      });
      _userModel = userModel;

      // Sauvegarde les données de l'utilisateur dans Firestore
      await _firebaseFirestore
          .collection("users")
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // Télécharge un fichier dans Firebase Storage et retourne l'URL de téléchargement
  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Récupère les données utilisateur depuis Firestore
  Future getDataFromFirestore() async {
    await _firebaseFirestore
        .collection("users")
        .doc(_firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      _userModel = UserModel(
        name: snapshot['name'],
        email: snapshot['email'],
        createdAt: snapshot['createdAt'],
        bio: snapshot['bio'],
        uid: snapshot['uid'],
        profilePic: snapshot['profilePic'],
        phoneNumber: snapshot['phoneNumber'],
      );
      _uid = userModel.uid;
    });
  }

  // Sauvegarde des données utilisateur localement avec SharedPreferences
  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("user_model", jsonEncode(userModel.toMap()));
  }

  // Récupère les données utilisateur depuis SharedPreferences
  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("user_model") ?? '';
    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;
    notifyListeners();
  }

  // Déconnexion de l'utilisateur
  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }

  // Sauvegarde des données de demande dans Firestore
  Future<void> saveRequestDataToFirestore({
    required BookingModel bookingModel,
    required Function onSuccess,
    required Function onError,
  }) async {
    try {
      setLoading(true);

      // Upload des données de la requête dans Firestore
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .add(bookingModel.toMap())
          .then((_) {
        onSuccess();
      }).catchError((error) {
        onError();
      });

      setLoading(false);
    } catch (error) {
      print('Error saving request data: $error');
      setLoading(false);
      throw error;  // Relancer l'erreur pour être capturée dans le widget
    }
  }
}
