import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:music_app/auth/signUpScreen.dart';
import 'forgotPasswordScreen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignInLoading = false;
  bool _isGoogleLoading = false;
  String _errorMessage = '';
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = '';
    });
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _errorMessage = 'Google sign-in cancelled';
        });
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;
      final response = await http.post(
        Uri.parse('https://task-4-0pfy.onrender.com/user/login'),
        body: json.encode({'id_token': googleAuth.idToken}),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(
            context, '/home');
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Google login failed';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Google sign-in failed. Please try again.';
      });
    } finally {
      setState(() {
        _isGoogleLoading = false;
      });
    }
  }

    Future<void> _loginWithEmail() async {
      setState(() {
        _isSignInLoading = true;
        _errorMessage = '';
      });
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      try {
        final response = await http.post(
          Uri.parse('https://task-4-0pfy.onrender.com/user/login'),
          body: json.encode({'email': email, 'password': password}),
          headers: {'Content-Type': 'application/json'},
        );
        final data = json.decode(response.body);
        if (response.statusCode == 200) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _errorMessage = data['message'];
          });
        }
      } catch (error) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      } finally {
        setState(() {
          _isSignInLoading = false;
        });
      }
    }

    @override
    Widget build (BuildContext context) {
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
         child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(

            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 50,),
              Image.asset('assets/logo.png',width: 200,height: 200,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome back to ',
                              style: TextStyle(
                                color: Color.fromARGB(255, 243, 159, 89),
                                fontSize: 24, fontFamily: 'KumbhSans'
                              ),
                            ),
                            TextSpan(
                              text: ' Raag!',
                              style: TextStyle(
                                color: Color.fromARGB(255, 243, 159, 89),
                                fontSize: 24,
                                fontWeight: FontWeight.bold, fontFamily: 'KumbhSans'
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              SizedBox(height: 45,),
              Text('Email address', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'KumbhSans')),
              SizedBox(height: 10,),
              TextField(
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
              SizedBox(height: 16),
              Text('Password', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'KumbhSans')),
              SizedBox(height: 10,),
              TextField(
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
              SizedBox(height: 16,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Forgot Password?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        TextSpan(
                          text: ' Click here',
                          style: TextStyle(
                              color: Color.fromARGB(255, 243, 159, 89),
                              fontSize: 15,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('assets/google.svg', height: 30,width: 30,),
                  _isGoogleLoading
                       ? Center(child: CircularProgressIndicator())
                       : TextButton(
                     onPressed: _loginWithGoogle,
                     child: Text("Continue with Google", style: TextStyle(color: Colors.white, fontSize: 20),),
                   ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have an account?",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15, fontFamily: 'KumbhSans'
                          ),
                        ),
                        TextSpan(
                          text: ' Sign Up',
                          style: TextStyle(
                            color: Color.fromARGB(255, 243, 159, 89),
                            fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'KumbhSans'
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUpScreen()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              SizedBox(height: 80),
              _isSignInLoading
                  ? Center(child: CircularProgressIndicator())
                   : ElevatedButton(
                      onPressed: _loginWithEmail,
                      child: Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'KumbhSans')),
                      style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 243, 159, 90),fixedSize: Size(50,50),shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),  // Set your desired radius
                      ),)
                    ),
            ],
          ),
        ),)
      );
    }
  }