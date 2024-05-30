import 'package:allobricoapp/model/request_model.dart';
import 'package:allobricoapp/provider/auth_provider.dart';
import 'package:allobricoapp/screens/home_screen.dart';
import 'package:allobricoapp/utils/utils.dart';
import 'package:allobricoapp/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingForm extends StatefulWidget {
  final String workerUid;
  const BookingForm({super.key, required this.workerUid,});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  
  final TitleController = TextEditingController();
  final DescriptionController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    TitleController.dispose();
    DescriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context, listen: true).isLoading;
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Booking Form'),
      ),
      body: isLoading == true
          ?const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 255, 179, 0),
              ),
            )
          :Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  textFeld(
                    hintText: "Titre de probleme",
                    icon: Icons.title,
                    inputType: TextInputType.text,
                    controller: TitleController,
                  ),
                  SizedBox(height: 20.0),
                  textFeld(
                    hintText: "Description de probleme ",
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
                          onPressed:() {
                            saveRequestDataToFirestore(context);
                          },
                        ),
                  ),
                ],
              ),
            ),
        );
  }

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

  void saveRequestDataToFirestore(BuildContext context) async {
  try {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    
    BookingModel bookingModel = BookingModel(
      title: TitleController.text.trim(),
      description: DescriptionController.text.trim(),
      requesterName: ap.userModel.name, 
      requesterId: ap.uid,
      workerId: widget.workerUid,
      createdAt: DateTime.now(),
      status: 'En cours', 
    );
    
    await ap.saveRequestDataToFirestore(
      bookingModel: bookingModel,
      onSuccess: () {
        ap.saveUserDataToSP().then(
          (value) => ap.setSignIn().then(
            (value) => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
              (route) => false,
            ),
          ),
        );
      },
      onError: () {
        // Handle error if request data couldn't be saved
        showSnackBar(context, "Failed to save request data");
      },
    );
  } catch (error) {
    // Handle any errors
    print('Error storing request data: $error');
    // Show an error message
    showSnackBar(context, "Failed to store request data");
  }
}



  


}
