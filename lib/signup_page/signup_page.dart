import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devio/constants/db_constants.dart';
import 'package:devio/constants/misc.dart';
import 'package:devio/signup_success_page/signup_success_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  int _sIndex = 0; // Stepper index; stepper for sign up form
  bool _loading = false;
  final DateTime _today = DateTime.now();
  final DateTime _fDate = DateTime(DateTime.now().year - 100);
  final int _formStepCount = 3; // Form (Stepper) step count


  // Form states
  // [Basic info form fields]
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPasswordField = '';

  // [Personal info form fields]
  String? _usernameCheck;
  String _firstName = '';
  String _lastName = '';
  String _gender = Gender.NOTSELECTED;
  File? _dp; // State to store the display picture selected from the gallery or captured from the camera
  DateTime? _dob; // State for date of birth

  // [Final info form fields]
  bool _isTnCChecked = false; // State for terms and conditions checkbox
  // Form controllers
  final _fkBasicInfo = GlobalKey<FormState>(); // Controls the basic info form
  final _fkPersonalInfo = GlobalKey<FormState>(); // Controls the personal info form

  // Dropdown menu items for gender
  final List<DropdownMenuItem>_ddGenders = <DropdownMenuItem>[
    const DropdownMenuItem(value: Gender.NOTSELECTED, onTap: null,child: Text(Gender.NOTSELECTED),),
    const DropdownMenuItem(value: Gender.MALE, child: Text(Gender.MALE)),
    const DropdownMenuItem(value: Gender.FEMALE, child: Text(Gender.FEMALE)),
    const DropdownMenuItem(value: Gender.UNDISCLOSED, child: Text(Gender.UNDISCLOSED))
  ];

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
        child:Card(
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
                          onPressed: handleNextStep,
                          child: Text(_sIndex < _formStepCount - 1 ? 'Next' : 'Done')
                      )
                    ],
                  ),
                  steps: [
                    // Step 1: Basic Information
                    // Username, email, and password, T&Cs
                    Step(
                      title: const Text('Basic Information'),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        child: Form(
                          key: _fkBasicInfo,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                validator: (value) => _usernameCheck,
                                onChanged: (value) {
                                  _validateUsername(value);
                                  _fkBasicInfo.currentState!.validate();
                                  setState(() {
                                    _username = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                    label: Text('Username'),
                                    hintText: 'Enter a unique username'
                                ),
                              ),

                              TextFormField(
                                validator: _validateEmail,
                                onChanged: (value){
                                  setState(() {
                                    _email = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                    label: Text('Email'),
                                    hintText: 'Enter your email'
                                ),
                              ),

                              TextFormField(
                                validator: _validatePassword,
                                onChanged: (value){
                                  setState(() {
                                    _password = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                    label: Text('Password'),
                                    hintText: 'Enter your password'
                                ),
                              ),

                              TextFormField(
                                validator: _validateConfirmPassword,
                                onChanged: (value){
                                  setState(() {
                                    _confirmPasswordField = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                    label: Text('Confirm Password'),
                                    hintText: 'Confirm Password'
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Step 2: Personal Information
                    // Full name, date of birth, profile pic
                    Step(
                      title: const Text('Personal Information'),
                      content: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        child: Form(
                          key: _fkPersonalInfo,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile pic goes here
                              InkWell(
                                onTap: () => handleImagePicker(),
                                child: Card(
                                  elevation: 4,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          height: 256,
                                          width: 256,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                              image: DecorationImage(
                                                image: drawDisplayPic()
                                              )
                                          ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.upload),
                                            Text('Upload')
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Name
                              TextFormField(
                                validator: (value) {
                                  if(value == null || value.isEmpty) return "First name is required.";
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _firstName = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                    label: Text('First Name'),
                                    hintText: 'Enter your first name'
                                ),
                              ),

                              TextFormField(
                                validator: (value) {
                                  if(value == null || value.isEmpty) return "Last name is required.";
                                  return null;
                                },
                                onChanged: (value){
                                  setState(() {
                                    _lastName = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                    label: Text('Last Name'),
                                    hintText: 'Enter your last name'
                                ),
                              ),

                              // DoB
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                child: OutlinedButton(
                                  onPressed: () => handleDoBChange(context),
                                  child: _drawDoBButtonContent(),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                child: Center(
                                  child: DropdownButtonFormField(
                                      value: _gender,
                                      validator: (value) {
                                        if(value.compareTo(Gender.NOTSELECTED) == 0) {
                                          return "Select your gender.";
                                        }
                                        return null;
                                      },
                                      icon: const Icon(Icons.arrow_drop_down),
                                      elevation: 8,
                                      onChanged: handleGenderDropdownChange,
                                      items: _ddGenders,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Step 3: Job/educational information
                    // Job title, company/institution, educational info
                    Step(
                        title: const Text('Finish'),
                        content: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                          child: Column(
                            children: [
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
                        )
                    )
                  ]
              )
          ),
        ),
      ),
    );
  }

  ImageProvider drawDisplayPic() {
    if(_dp == null) {
      return const AssetImage('assets/images/guest_male.png');
    }
    return FileImage(_dp!);
  }

  void handlePreviousStep() {
    if(_sIndex > 0) {
      setState(() {
        _sIndex = _sIndex - 1;
      });
    }
  }

  void handleNextStep() {
    switch(_sIndex) {
      case 0:
        // Validate basic info
        if(_isValidBasicInfo()) {
          setState(() {
            _sIndex = 1;
          });
        }
        break;
      case 1:
        // Validate personal info
        if(_isValidPersonalInfo()) {
          setState(() {
            _sIndex = 2;
          });
        }
        break;
      case 2:
        if(_isTnCChecked) {
          handleSignUp();
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            const SnackBar(
                content: Text('You need to accept the terms and conditions before finishing registration.')
            )
          );
        }
        break;
      default:
        debugPrint("Signup page > handleNextStep() > hit default case. Stepper index is: $_sIndex");
        break;
    }
  }

  Future<void> handleDoBChange(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
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
    setState(() {
      _loading = true;
    });

    // Step 1
    // Use Firebase auth to create a new account with email and password
    // Create account here
    late UserCredential uc;
    try {
      uc = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _email,
          password: _password
      );

      await uc.user?.sendEmailVerification();
    } on FirebaseAuthException catch(err) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(content: Text("Failed to create new user."))
      );

      debugPrint("Sign up page > handleSignup() > Firebase error > ${err.message}");
      return;
    }

    String? uid = uc.user?.uid;

    // Step 2
    // Upload the profile picture to firebase storage
    String? dpUrl;
    if(_dp != null) {
      debugPrint("Sign up page > handleSignUp() > Uploading profile picture");
      final storageRef = FirebaseStorage.instance.ref();
      final imgRef = storageRef.child('images/${uid}');

      try {
        await imgRef.putFile(_dp!);
        dpUrl = await imgRef.getDownloadURL();
        debugPrint("Sign up page > handleSignUp() > Done uploading profile picture > $dpUrl");
      } on FirebaseException catch(err) {
        debugPrint("Sign up page > handleSignup() > Failed to upload profile picture.");
      }
    }


    // Step 3
    // Create a cloud firestore(database) document on the collection 'users'
    // and populate the document with the information given by the user
    UserModel model = UserModel(
        firstName: _firstName,
        lastName: _lastName,
        uid: uid!,
        username: _username,
        gender: _gender,
        dob: Timestamp.fromDate(_dob!),
        dpUrl: dpUrl
    );

    debugPrint('Sign up page > handleSignup() > model: ${model.toJson().toString()}');

    final dbRef = FirebaseFirestore.instance;
    final usersCollRef = dbRef.collection(UsersCollection.collectionName);
    final usernamesCollRef = dbRef.collection(UsernamesCollection.collectionName);
    try {
      await usernamesCollRef.doc(_username).set({
        UsernamesCollection.uidKey: uid
      });

      await usersCollRef.doc(uid).set(model.toJson());
    } on FirebaseException catch(err) {
      debugPrint('Sign up page > handleSingup() > Failed to update firestore database entries.');
    }

    // User created
    // Notify the user
    setState(() {
      _loading = false;
    });

    if(mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupSuccessPage(model: model,)));
    }
  }

  bool _isValidBasicInfo() {
    return _fkBasicInfo.currentState!.validate();
  }

  bool _isValidPersonalInfo() {
    return _fkPersonalInfo.currentState!.validate();
  }

  void handleGenderDropdownChange(value) {
    setState(() {
      _gender = value;
    });
  }

  void _validateUsername(String? value) {
    if(value == null || value.isEmpty || value.length < 5) {
      setState(() {
        _usernameCheck = 'Username must be at least 5 characters.';
      });
    } else {
      final dbRef = FirebaseFirestore.instance;
      final collRef = dbRef.collection(UsernamesCollection.collectionName);
      final docFuture = collRef.doc(value).get();
      docFuture.then((doc) {
        if (doc.exists) {
          setState(() {
            _usernameCheck = "Username already exists.";
          });
        } else {
          _usernameCheck = null;
        }
      }, onError: (err) {
        debugPrint(err.toString());
      });
    }
  }

  String? _validateEmail(String? value) {
    bool isValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value ?? '');
    if(!isValid) {
      return "Invalid email.";
    }

    return null;
  }

  String? _validatePassword(String? value) {
    bool isValid = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
        .hasMatch(value ?? '');
    if(!isValid) {
      return "Invalid password format.";
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    String pass = value ?? '';
    if(pass.isEmpty) return 'Password is required.';

    if(pass.compareTo(_password) != 0) return "Passwords do not match.";
    return null;
  }

  Widget _drawDoBButtonContent() {
    if(_dob == null) return const Text("Select your birthday");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
          children: [
            const Text('Select your birthday'),
            Text(DateFormat('yMMMMd').format(_dob!)),
          ]
      ),
    );
  }
}
