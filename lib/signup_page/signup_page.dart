import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  int _sIndex = 0; // Stepper index; stepper for sign up form
  bool _isTnCChecked = false; // State for terms and conditions checkbox
  DateTime _dob = DateTime.now(); // State for date of birth
  final DateTime _today = DateTime.now();
  final DateTime _fDate = DateTime(DateTime.now().year - 100);
  final int _formStepCount = 3; // Form (Stepper) step count
  File? _dp; // State to store the display picture selected from the gallery or captured from the camera

  // Form controllers
  final TextEditingController _conUsername = TextEditingController();
  final TextEditingController _conEmail = TextEditingController();
  final TextEditingController _conPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up to DevIO'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.chevron_left),
        ),
      ),

      body: Center(
        child: Wrap(
          children: [
            Card(
              child: Form(
                child: Stepper(
                  currentStep: _sIndex,
                  controlsBuilder: (context, details) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FilledButton(
                        onPressed: _sIndex > 0 ? handlePreviousStep : null,
                        child: const Text('Back'),
                      ),
                      FilledButton(
                          onPressed: _sIndex < _formStepCount - 1 ? handleNextStep : handleSignUp,
                          child: Text(_sIndex < _formStepCount - 1 ? 'Next' : 'Done')
                      )
                    ],
                  ),
                  steps: [
                    // Step 1: Basic Information
                    // Username, email, and password, T&Cs
                    Step(
                      title: const Text('Basic Information'),
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _conUsername,
                            decoration: const InputDecoration(
                                label: Text('Username'),
                                hintText: 'Enter a unique username'
                            ),
                          ),

                          TextFormField(
                            controller: _conEmail,
                            decoration: const InputDecoration(
                                label: Text('Email'),
                                hintText: 'Enter your email'
                            ),
                          ),

                          TextFormField(
                            controller: _conPassword,
                            decoration: const InputDecoration(
                                label: Text('Password'),
                                hintText: 'Enter your password'
                            ),
                          ),

                          TextFormField(
                            decoration: const InputDecoration(
                                label: Text('Confirm Password'),
                                hintText: 'Confirm Password'
                            ),
                          ),

                          // [Optional] TODO: Capcha

                          // T&Cs checkbox
                          CheckboxListTile(
                            value: _isTnCChecked,
                            dense: true,
                            onChanged: (value) => setState(() {
                              _isTnCChecked = value!;
                            }),
                            title: const Text('I\'ve read the Terms and Conditions and I agree with them.'),
                          ),
                        ],
                      ),
                    ),

                    // Step 2: Personal Information
                    // Full name, date of birth, profile pic
                    Step(
                      title: const Text('Personal Information'),
                      content: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile pic goes here
                          SizedBox(
                            height: 128,
                            width: 128,
                            child: OutlinedButton(
                                onPressed: () => handleImagePicker(),
                                style: OutlinedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(8)
                                ),
                                child: drawDisplayPic()
                            ),
                          ),
                          // Name
                          TextFormField(
                            decoration: const InputDecoration(
                                label: Text('First Name'),
                                hintText: 'Enter your first name'
                            ),
                          ),

                          TextFormField(
                            decoration: const InputDecoration(
                                label: Text('Last Name'),
                                hintText: 'Enter your last name'
                            ),
                          ),

                          // DoB
                          TextButton(
                            onPressed: () => handleDoBChange(context),
                            child: const Text('Select your birthday'),
                          ),

                          Text(DateFormat('yMMMMd').format(_dob)),
                        ],
                      ),
                    ),

                    // Step 3: Job/educational information
                    // Job title, company/institution, educational info
                    Step(
                        title: const Text('More about you'),
                        content: const Text('More info')
                    )
                  ]
                )
              ),
            ),
          ]
        ),
      ),
    );
  }

  CircleAvatar drawDisplayPic() {
    if(_dp == null) {
      return const CircleAvatar(
        maxRadius: double.infinity,
        backgroundColor: Colors.blue,
        backgroundImage: AssetImage('assets/images/guest_male.png'),
      );
    }
    return CircleAvatar(
      maxRadius: double.infinity,
      backgroundImage: FileImage(_dp!),
    );
  }

  void handlePreviousStep() {
    if(_sIndex > 0) {
      setState(() {
        _sIndex = _sIndex - 1;
      });
    }
  }

  void handleNextStep() {
    if(_sIndex < _formStepCount - 1) {
      setState(() {
        _sIndex = _sIndex + 1;
      });
    }
  }

  Future<void> handleDoBChange(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
        context: context,
        initialDate: _dob,
        firstDate: _fDate,
        lastDate: _today
    );



    if(selected != null && selected != _dob) {
      setState(() {
        _dob = selected;
      });
    }
  }

  Future<void> handleImagePicker() async {
    try {
      XFile? img = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(img == null) return;

      File? imgFile = File(img.path);
      setState(() {
        _dp = imgFile;
      });
    } on PlatformException catch (e) {
      debugPrint('Signup page > Image picker > ${e.message}');
      return;
    }
  }

  void handleSignUp() async {
    // Step 1
    // Use Firebase auth to create a new account with email and password
    String email = _conEmail.text.trim();
    String password = _conPassword.text.trim();

    // Create account here
    UserCredential uc = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email,
          password: password
    );

    String? uid = uc.user?.uid;

    // Step 2
    // Upload the profile picture to firebase storage
    if(_dp != null) {
      final storage = FirebaseStorage.instance;
      final imgRef = storage.ref('images/${uid}.jpeg');
    }


    // Step 3
    // Create a cloud firestore(database) document on the collection 'users'
    // and populate the document with the information given by the user
  }
}
