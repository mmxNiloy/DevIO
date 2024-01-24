import 'package:devio/models/user_model.dart';
import 'package:flutter/material.dart';

class SignupSuccessPage extends StatelessWidget {
  final UserModel model;
  const SignupSuccessPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up complete'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            Navigator.popUntil(context, ModalRoute.withName('/'));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Text(
'''
Dear ${model.firstName} ${model.lastName},

Congratulations on successfully signing up for DevIO!

To ensure the security of your account and provide you with the best experience, we've sent a verification message to the email address you provided during signup. Please check your inbox and follow the instructions in the email to verify your account.

Once you've verified your account, you can log in to DevIO and start exploring all the exciting features we have to offer. Whether you're here for the communities or to connect with like-minded individuals, we're confident you'll find DevIO to be a valuable and enjoyable space.

Here's a quick guide to get you started:

Check Your Email: Look for the verification message in your inbox. If you don't see it, please check your spam or junk folder.

Verify Your Account: Follow the instructions in the email to complete the account verification process.

Log In: Once verified, log in to your account on DevIO using your credentials.

Explore and Engage: Dive into DevIO! Explore the features, connect with others, and make the most of your experience.

If you encounter any issues or have questions, our support team is ready to assist. Simply reach out to dev.niloysarkar@gmail.com.

Thank you for choosing DevIO! We look forward to seeing you actively engage and contribute to our growing community.

Best regards,
DevIO Team
'''
              ),
              OutlinedButton(
                  onPressed: (){ Navigator.popUntil(context, ModalRoute.withName('/')); },
                  child: const Text('Login')
              )
            ],
          ),
        ),
      ),
    );
  }
}
/*

 */