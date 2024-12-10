import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Database
import 'sign_up_page.dart';
import 'admin_landing_page.dart';
import 'student_landing_page.dart';
import 'staff_landing_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _passwordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Function to store admin details in Firebase Realtime Database
  Future<void> _storeAdminData() async {
    DatabaseReference adminRef = FirebaseDatabase.instance.ref('users/admin');
    DataSnapshot snapshot = await adminRef.get();

    // Check if admin data already exists
    if (!snapshot.exists) {
      await adminRef.set({
        'role': 'admin',
        'name': 'Administrator',
        'email': 'admin@admin.com'
      });
    }
  }

  void _login() async {
    String input = _controller.text;
    String password = _passwordController.text;

    // Check if the user is 'root' and the password is 'adminonly123'
    if (input == 'root' && password == 'adminonly123') {
      // Store admin data in the database if it doesn't already exist
      await _storeAdminData();

      // Navigate to Admin Landing Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminLandingPage()),
      );
    } else {
      // Proceed with Firebase Authentication for students and staff
      if (_formKey.currentState!.validate()) {
        try {
          UserCredential userCredential;

          // Check if the input is a student ID (numeric)
          if (RegExp(r'^[0-9]+$').hasMatch(input)) {
            int studentID = int.parse(input);

            // Validate student ID range
            if (studentID < 2018000000 || studentID > 2024999999) {
              _showErrorDialog(
                  'Invalid student ID. Must be within the allowed range.');
              return;
            }

            // Sign in as a student using a generated email
            String email = '$input@university.edu'; // Assumed student email
            userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } else if (RegExp(r'^[a-zA-Z]+$').hasMatch(input)) {
            // If the input contains only alphabets, treat it as a staff login
            String email = '$input@staff.edu'; // Fake email for staff
            userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } else {
            _showErrorDialog(
                'Invalid input. Please enter a valid student ID or staff name.');
            return;
          }

          // Fetch user data from Realtime Database
          DatabaseReference userRef = FirebaseDatabase.instance
              .ref('users/${userCredential.user!.uid}'); // Updated to use ref()
          DataSnapshot snapshot =
              await userRef.get(); // Use get() instead of once()

          if (snapshot.exists) {
            String role =
                snapshot.child('role').value as String; // Cast value to String

            // Navigate based on user type
            switch (role) {
              case 'student':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentLandingPage())
                  );
                break;
              case 'staff':
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const StaffLandingPage(isStaff: true)),
                );
                break;
              default:
                _showErrorDialog('Unknown user role');
            }
          } else {
            _showErrorDialog('User data not found in database');
          }
        } on FirebaseAuthException catch (e) {
          _showErrorDialog(e.message!);
        } catch (e) {
          _showErrorDialog('An error occurred: ${e.toString()}');
        }
      }
    }
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
                  'Welcome Back!',
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
                        TextFormField(
                          controller: _controller,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                            labelText: 'Staff Name/Student ID',
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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text('Don\'t have an account? Sign Up'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'LOGIN PAGE',
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
