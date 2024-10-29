import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailOrNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isStudent = false;

  @override
  void dispose() {
    _emailOrNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      String emailOrName = _emailOrNameController.text;
      String password = _passwordController.text;
      String confirmPassword = _confirmPasswordController.text;

      if (password != confirmPassword) {
        _showErrorDialog('Passwords do not match');
        return;
      }

      try {
        UserCredential userCredential;

        // Check if the user is a student or staff
        if (_isStudent) {
          int studentID = int.parse(emailOrName);
          if (studentID < 2018000000 || studentID > 2024999999) {
            _showErrorDialog(
                'Invalid student ID. Must be within the allowed range.');
            return;
          }

          // Create student user using a generated email
          String email = '$emailOrName@university.edu'; // Modify as needed
          userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          // Store student data in Realtime Database
          await _saveUserData(userCredential.user!.uid, emailOrName, 'student');
          _showSuccessDialog('Student signed up successfully!');
        } else {
          // Ensure staff only uses alphabets for their name
          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(emailOrName)) {
            _showErrorDialog('Staff name should only contain alphabets.');
            return;
          }

          // Create a staff user using the staff name instead of email
          userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email:
                '$emailOrName@staff.edu', // Create a fake email for Firebase Auth
            password: password,
          );

          // Store staff data in Realtime Database
          await _saveUserData(userCredential.user!.uid, emailOrName, 'staff');
          _showSuccessDialog('Staff signed up successfully!');
        }
      } on FirebaseAuthException catch (e) {
        _showErrorDialog(e.message!);
      } catch (e) {
        _showErrorDialog('An error occurred: ${e.toString()}');
      }
    }
  }

  Future<void> _saveUserData(
      String userId, String emailOrName, String role) async {
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref('users/$userId'); // Updated to use ref()

    await userRef.set({
      'email_or_id': emailOrName,
      'role': role,
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('Are you a student?'),
                          value: _isStudent,
                          onChanged: (bool value) {
                            setState(() {
                              _isStudent = value;
                            });
                          },
                        ),
                        TextFormField(
                          controller: _emailOrNameController,
                          decoration: InputDecoration(
                            labelText: _isStudent ? 'Student ID' : 'Staff Name',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[400]!,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a value';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[400]!,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Colors.grey[400]!,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Already have an account? Login'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'SIGN UP PAGE',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
