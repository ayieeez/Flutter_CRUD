import 'package:flutter/material.dart';
import 'login_page.dart'; // Ensure to import the login page

class StaffLandingPage extends StatelessWidget {
  const StaffLandingPage({super.key});

  void _logout(BuildContext context) {
    // Navigates back to the login page when the user logs out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Landing Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Call logout function
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome, Staff!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context), // Logout button in the body
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
