import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:music_app/auth/signInScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSignUpLoading = false;
  String _errorMessage = '';


  Future<void> _signUpWithEmail() async {
    setState(() {
      _isSignUpLoading = true;
      _errorMessage = '';
    });
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = "Passwords don't match.";
        _isSignUpLoading = false;
      });
      return;
    }
    if ([email, password, name].any((field) => field.isEmpty)) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      _isSignUpLoading = false;
      return;
    }
    try {
      final response = await http.post(
        Uri.parse("https://task-4-0pfy.onrender.com/user/signup"),
        body: json.encode({'name': name,'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: data['message']),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
      else {
        setState(() {
          _errorMessage = data['message'];
        });
      }
    } catch (error) {
      print('Error during sign-up: $error');
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isSignUpLoading = false;
      });
    }
  }

  @override
  Widget build (BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
          child: Container(
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
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.06,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: screenWidth*0.5,
                      height: screenWidth*0.5
                    ),
                    SizedBox(height: screenHeight*0.02),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome to ',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 243, 159, 89),
                                      fontSize: screenWidth*0.06, fontFamily: 'KumbhSans'
                                  ),
                                ),
                                TextSpan(
                                  text: ' Raag!',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 243, 159, 89),
                                      fontSize: screenWidth*0.06,
                                      fontWeight: FontWeight.bold, fontFamily: 'KumbhSans'
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    SizedBox(height: screenHeight*0.01),
                    Center(
                      child: Text('Create your Account', style: TextStyle(
                          color: Colors.white, fontFamily: 'KumbhSans', fontSize: screenWidth*0.04),),
                    ),
                    SizedBox(height: screenHeight*0.05),
                    Text('Name', style: TextStyle(color: Colors.white, fontSize: screenWidth*0.04, fontFamily: 'KumbhSans')),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 233, 188, 185),
                        hintText: 'T y p e    h e r e',
                        hintStyle: TextStyle(color: Color.fromARGB(80, 0, 0, 0), fontFamily: 'KumbhSans') ,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight*0.02),
                    Text('Email address', style: TextStyle(color: Colors.white, fontSize: screenWidth*0.04, fontFamily: 'KumbhSans')),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 233, 188, 185),
                        hintText: 'T y p e    h e r e',
                        hintStyle: TextStyle(color: Color.fromARGB(80, 0, 0, 0), fontFamily: 'KumbhSans') ,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight*0.02),
                    Text('Password', style: TextStyle(color: Colors.white, fontSize: screenWidth*0.04, fontFamily: 'KumbhSans')),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
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
                            _isPasswordVisible = !_isPasswordVisible;  // Toggle the visibility
                          });
                        },
                            icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.black54,))
                      ),
                    ),
                    SizedBox(height: screenHeight*0.02),
                    Text('Confirm Password', style: TextStyle(color: Colors.white, fontSize: screenWidth*0.04, fontFamily: 'KumbhSans')),
                    SizedBox(height: screenHeight * 0.01),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
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
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;  // Toggle the visibility
                            });
                          },
                              icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,color: Colors.black54,))
                      ),
                    ),
                    SizedBox(height: screenHeight*0.02),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Already have an account?",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15, fontFamily: 'KumbhSans'
                                  ),
                                ),
                                TextSpan(
                                  text: ' Sign In',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 243, 159, 89),
                                      fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'KumbhSans'
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => SignInScreen()),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Center(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    SizedBox(height: screenHeight*0.06),
                    _isSignUpLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                        onPressed: _isSignUpLoading ? null : _signUpWithEmail,
                        child: Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'KumbhSans')),
                        style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 243, 159, 90),fixedSize: Size(screenWidth*0.84,screenHeight*0.06),shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),)
                    ),
                  ],
                ),
              ),
            ),),
        )
    );
  }
}