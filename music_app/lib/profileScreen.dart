import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> avatarList = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
  ];

  String? _selectedAvatar;

  String username = '';
  String email = '';
  bool isLoading = true;
  String _errorMessage = '';
  bool isEditing = false;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      print(userId);
      if (userId == null) {
        _showErrorMessage('User ID not found. Please log in again.');
        return;
      }

      final response = await http.get(
        Uri.parse('https://task-4-0pfy.onrender.com/profile/userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(response.statusCode);
        setState(() {
          username = data['username'];
          email = data['email'];
          _usernameController.text = username;
        });
      } else {
        print(response.statusCode);
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
          const SnackBar(content: Text('Username updated successfully')),
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
        Navigator.pushNamedAndRemoveUntil(context, '/signup', (route) => false);
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
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.red))),
    );
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showAvatarSelection() async {
    final selectedAvatar = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return Container(
          height: 150,
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
            itemCount: avatarList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, avatarList[index]),
                child: CircleAvatar(
                  radius: 30,
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(
                    avatarList[index],
                    fit: BoxFit.cover
                  )
                  ),
                ),
              );
            },
          ),
        );
      },
    );

    if (selectedAvatar != null) {
      setState(() {
        _selectedAvatar = selectedAvatar;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar', selectedAvatar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
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
            ? const Center(child: CircularProgressIndicator())
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
                        backgroundImage: _selectedAvatar!= null? AssetImage(_selectedAvatar!)
                            : null,
                        child: _selectedAvatar == null
                           ? Icon(Icons.person, size: screenWidth * 0.15, color: Colors.grey): null
                        ),
                        Positioned(
                          left: 90,
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              _showAvatarSelection();
                            },
                            child: Container(
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: screenWidth * 0.05,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 5),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedAvatar = null;
                  });
                },
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Row(
                children: [
                  const Text(
                    'Username',
                    style: TextStyle(
                      color: Color.fromARGB(255, 243, 159, 89),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      setState(() => isEditing = true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5),
              isEditing
                  ? Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                      ),
                        focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: updateUsername,
                    child: const Text('Save'),
                  ),
                ],
              )
                  : Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                      username,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
              ),
              const SizedBox(height: 10),
                  const Text(
                    'Email',
                    style: TextStyle(color: Color.fromARGB(255, 243, 159, 89), fontSize: 22, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5,),
                  Text(email, style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 225),
              TextButton(
                onPressed: deleteAccount,
                child: const Text('Delete Account', style: TextStyle(color: Colors.red, fontSize: 20)),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 243, 159, 90),fixedSize: const Size(50,50)),
                child: const Text('Logout', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}