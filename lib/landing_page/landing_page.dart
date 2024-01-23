import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devio/signup_page/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// The landing page is for the users to login or sign-up
// TODO: Login form
// TODO: Firebase auth
// TODO: Firestore database
// TODO: Login persistence
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<StatefulWidget> createState() => _LandingPageState();


}

class _LandingPageState extends State<LandingPage> {
  final TextEditingController _emailController = TextEditingController(text: "");
  final TextEditingController _passwordController = TextEditingController(text: "");
  bool _isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Wrap(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'DevIO',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Login form "login" form label
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Container(
                                  color: Theme.of(context).dividerColor,
                                  height: 2,
                                ),
                              ),
                            ),
                            const Flexible(
                                flex: 1,
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Container(
                                  color: Colors.blue,
                                  height: 2,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),

                      // Login form begins here
                      // Email text field
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        child: TextField(
                          decoration: const InputDecoration(
                            label: Text('Email'),
                            hintText: 'Enter your email',
                          ),
                          controller: _emailController,
                        ),
                      ),

                      // Password text field
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        child: TextField(
                          decoration: InputDecoration(
                            label: const Text('Password'),
                            hintText: 'Enter your password',
                            suffix: IconButton(
                                onPressed: () => setState(() {
                                  _isPasswordHidden = !_isPasswordHidden;
                                }),
                                icon: Icon(
                                  _isPasswordHidden ?
                                    Icons.visibility : Icons.visibility_off
                                )
                            )
                          ),
                          obscureText: _isPasswordHidden,
                          controller: _passwordController,
                        ),
                      ),


                      // Login button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        child: OutlinedButton(
                            onPressed: handleLogin,
                            child: const Text('Login')
                        ),
                      ),

                      // Empty space
                      SizedBox.fromSize(
                        size: const Size(0, 32),
                      ),

                      // Sign-up divider
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        child: Text(
                          'Don\'t have an account?',
                          textAlign: TextAlign.center,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        child: OutlinedButton(
                          onPressed: handleSignupButton,
                          child: const Text('Sign up'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ]
        ),
      ),
    );
  }

  Future<void> handleLogin() async {
    // Sample login
    UserCredential uc = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim()
    );

    if(uc.user != null) {
      debugPrint('Firebase auth > ${uc.user?.uid}');
      final dbRef = FirebaseFirestore.instance;
      final collRef = dbRef.collection('users');

      String? uid = uc.user?.uid;
      final docRef = collRef.doc(uid!);
      final doc = await docRef.get();
      if(doc.exists) {
        await docRef.update({
          'login_count': int.parse(doc.data()!['login_count'].toString()) + 1
        });
      } else {
        await docRef.set({
          'login_count': 1
        });
      }
      debugPrint('Updated database.');

      FirebaseAuth.instance.signOut();
    } else {
      debugPrint('Firebase auth > Login failed. Invalid credentials.');
    }
  }

  void handleSignupButton() {
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => const SignupPage()
        )
    );
  }
}
