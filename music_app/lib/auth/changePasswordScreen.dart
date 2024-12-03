import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _resetPass() async {

    final newPassword = _newPasswordController.text.trim();
    final confirmNewPassword = _confirmNewPasswordController.text.trim();

    if (newPassword != confirmNewPassword) {
      setState(() {
        _errorMessage = "Passwords don't match.";
      });
      return;
    }

    if (newPassword.isEmpty || confirmNewPassword.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('https://task-4-0pfy.onrender.com/user/requestPasswordReset/:userId/:resetString'),
        body: json.encode({"confirmPassword": confirmNewPassword, "newPassword": newPassword}),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification link sent')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
      else {
        setState(() {
          _errorMessage = data['message']?? 'Link not sent!';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 29, 26, 57),
                  Color.fromARGB(255, 29, 26, 57),
                  Color.fromARGB(255, 29, 26, 57),
                  Color.fromARGB(255, 0, 0, 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child:Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text('Reset your password', style: TextStyle(color: Color.fromARGB(255, 243, 159, 89),
                                  fontSize: 30, fontFamily: 'KumbhSans', fontWeight: FontWeight.w900),),
                            ],
                          ),
                        ),
                        SizedBox(height: 15,),
                        Center(child: Text('It happens! No worries, we got your back.', style: TextStyle(color: Colors.white, fontFamily: 'KumbhSans', fontSize: 20),)),
                        SizedBox(height: 30),
                        Text('New password', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'KumbhSans')),
                        SizedBox(height: 10,),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: !_isNewPasswordVisible,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Color.fromARGB(255, 233, 188, 185),
                              hintText: 'T y p e    h e r e',
                              hintStyle: TextStyle(color: Color.fromARGB(80, 0, 0, 0), fontFamily: 'KumbhSans'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(onPressed: () {
                                setState(() {
                                  _isNewPasswordVisible = !_isNewPasswordVisible;  // Toggle the visibility
                                });
                              },
                                  icon: Icon(_isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.black54,))
                          ),
                        ),
                        SizedBox(height: 16),
                        Text('Confirm new password', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'KumbhSans')),
                        SizedBox(height: 10,),
                        TextField(
                          controller: _confirmNewPasswordController,
                          obscureText: !_isConfirmNewPasswordVisible,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Color.fromARGB(255, 233, 188, 185),
                              hintText: 'T y p e    h e r e',
                              hintStyle: TextStyle(color: Color.fromARGB(80, 0, 0, 0), fontFamily: 'KumbhSans'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(onPressed: () {
                                setState(() {
                                  _isConfirmNewPasswordVisible = !_isConfirmNewPasswordVisible;  // Toggle the visibility
                                });
                              },
                                  icon: Icon(_isConfirmNewPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.black54,))
                          ),
                        ),
                        SizedBox(height: 10),
                        if (_errorMessage.isNotEmpty)
                          Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red))),
                        SizedBox(height: 70),
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                            onPressed: _resetPass,
                            child: Text("Reset", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'KumbhSans')),
                            style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 243, 159, 90),fixedSize: Size(50,50),shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),  // Set your desired radius
                            ),)
                        ),
                      ],
                    ),
                  ),))
        )
    );
  }
}