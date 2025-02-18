import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:music_app/auth/signUpScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _errorMessage = '';

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
          final userId = data['data']['_id'];
          print(userId);
          print(data);
          if (userId != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userId', userId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data['message'] ?? 'Sign-In successful!')),
            );
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route)=> false);
          } else {
            setState(() {
              _errorMessage = 'Unexpected error: userId is null.';
            });
          }
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
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
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
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/logo.png',width: screenWidth*0.2,height: screenHeight*0.2),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome back to ',
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 243, 159, 89),
                                    fontSize: screenWidth*0.06, fontFamily: 'KumbhSans'
                                  ),
                                ),
                                TextSpan(
                                  text: ' Raag!',
                                  style: TextStyle(
                                    color: const Color.fromARGB(255, 243, 159, 89),
                                    fontSize: screenWidth*0.06,
                                    fontWeight: FontWeight.bold, fontFamily: 'KumbhSans'
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                const SizedBox(height: 45,),
                const Text('Email address', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'KumbhSans')),
                const SizedBox(height: 10,),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 233, 188, 185),
                    hintText: 'T y p e    h e r e',
                    hintStyle: const TextStyle(color: Color.fromARGB(80, 0, 0, 0), fontFamily: 'KumbhSans') ,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Password', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'KumbhSans')),
                const SizedBox(height: 10,),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 233, 188, 185),
                    hintText: 'T y p e    h e r e',
                    hintStyle: const TextStyle(color: Color.fromARGB(80, 0, 0, 0), fontFamily: 'KumbhSans'),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Forgot Password?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: ' Click here',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 243, 159, 89),
                                fontSize: 15,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: "Don't have an account?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15, fontFamily: 'KumbhSans'
                            ),
                          ),
                          TextSpan(
                            text: ' Sign Up',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 243, 159, 89),
                              fontSize: 15, fontWeight: FontWeight.w900, fontFamily: 'KumbhSans'
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                _isSignInLoading
                    ? const Center(child: CircularProgressIndicator())
                     : ElevatedButton(
                        onPressed: _loginWithEmail,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 243, 159, 90),fixedSize: const Size(50,50),shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),  // Set your desired radius
                        ),),
                        child: const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'KumbhSans'))
                      ),
              ],
            ),
        ),)
      );
    }
  }