import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FBFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Include the auth_header widget here
            AuthHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21.0, vertical: 40.0),
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                      ),
                      suffixIcon: Icon(Icons.visibility),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10.0),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Include the auth_footer widget here
            AuthFooter(),
          ],
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Implement your auth_header widget here
    );
  }
}

class AuthFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Implement your auth_footer widget here
    );
  }
}