import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';
  bool isLoading = true;
  String _errorMessage = '';
  bool isEditing = false;
  TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final response = await http.get(
        Uri.parse('https://your-backend-url.com/user/profile'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'];
          email = data['email'];
          _usernameController.text = username;
        });
      } else {
        _showErrorMessage('Failed to load profile data');
      }
    } catch (error) {
      _showErrorMessage('Error fetching profile data');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateUsername() async {
    setState(() => isLoading = true);
    try {
      final response = await http.put(
        Uri.parse('https://your-backend-url.com/user/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': _usernameController.text.trim()}),
      );

      if (response.statusCode == 200) {
        setState(() {
          username = _usernameController.text.trim();
          isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username updated successfully')),
        );
      } else {
        _showErrorMessage('Failed to update username');
      }
    } catch (error) {
      _showErrorMessage('An error occurred while updating');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteAccount() async {
    bool confirmDelete = await _showConfirmationDialog();
    if (!confirmDelete) return;

    setState(() => isLoading = true);
    try {
      final response = await http.delete(
        Uri.parse('https://your-backend-url.com/user/delete'),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/signup');
      } else {
        _showErrorMessage('Failed to delete account');
      }
    } catch (error) {
      _showErrorMessage('Error deleting account');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.red))),
    );
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // Clear tokens and user data

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out successfully')),
    );

    Navigator.pushReplacementNamed(context, '/login');
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 29, 26, 57),
              Color.fromARGB(255, 0, 0, 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
    child: Padding(
    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: screenHeight * 0.1),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: screenWidth * 0.125,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: screenWidth * 0.15, color: Colors.grey),
                        ),
                        Positioned(
                          left: 90,
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              // Implement avatar editing functionality here
                            },
                            child: Container(
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: screenWidth * 0.05, // Adjust size based on screen width
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              SizedBox(height: screenHeight * 0.05),
              Row(
                children: [
                  Text(
                    'Username',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      setState(() => isEditing = true); // Enable editing mode
                    },
                  ),
                ],
              ),
              SizedBox(height: 5), // Add spacing between label and box
              isEditing
                  ? Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(// Background color for the field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: updateUsername,
                    child: Text('Save'),
                  ),
                ],
              )
                  : Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                      username,
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
              ),
              SizedBox(height: 20),
                  Text(
                    'Email',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 5,),
                  Text(email, style: TextStyle(color: Colors.white, fontSize: 20)),
              SizedBox(height: 20),
              if (_errorMessage.isNotEmpty) ...[
                Center(
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
                SizedBox(height: 10),
              ],
              SizedBox(height: 200),
              TextButton(
                onPressed: deleteAccount,
                child: Text('Delete Account', style: TextStyle(color: Colors.red, fontSize: 20)),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: logout,
                child: Text('Logout', style: TextStyle(fontSize: 20, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 243, 159, 90),fixedSize: Size(50,50)),
              ),
            ],
          ),
        ),
      ),
      ));
  }
}