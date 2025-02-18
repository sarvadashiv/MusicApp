import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _sendLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter email first!.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http.post(
        Uri.parse('https://task-4-0pfy.onrender.com/user/requestPasswordReset'),
        body: json.encode({'email': email, 'redirectUrl': 'http://task-4-0pfy.onrender.com/user/requestPasswordReset' }),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        final responseData=jsonDecode(response.body);
        if(responseData['message']== 'Password reset email sent'){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification link sent'), backgroundColor: Colors.green,),
          );
          Navigator.pushReplacementNamed(context, '/newPassword');
        } else{
          print(data);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message']?? "Something went wrong"), backgroundColor: Colors.red,),
          );
        }
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
  Widget build (BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
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
            child:SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.06,
                  vertical: 20,
                ),
                child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height*0.25),
                        const Text(
                          'Forgot password?',
                          style: TextStyle(
                              color: Color.fromARGB(255, 243, 159, 89),
                              fontSize: 30,
                              fontFamily: 'KumbhSans',
                              fontWeight: FontWeight.w900
                          )
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "We'll send you a verification link on provided email.",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'KumbhSans',
                              fontSize: 20
                          )
                        ),
                        const SizedBox(height: 40),
                        const Text(
                            'Email address',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'KumbhSans'
                            )
                        ),
                        const SizedBox(height: 10,),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 233, 188, 185),
                            hintText: 'T y p e    h e r e',
                            hintStyle: const TextStyle(
                                color: Color.fromARGB(80, 0, 0, 0),
                                fontFamily: 'KumbhSans'
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_errorMessage.isNotEmpty)
                          Center(
                              child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red)
                              )
                          ),
                        const SizedBox(height: 40),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                            onPressed: _sendLink,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 243, 159, 90),
                              fixedSize: const Size(double.infinity,50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)
                              )
                            ),
                            child: const Text(
                                "Send",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'KumbhSans'
                                )
                            )
                        ),
                      ],
                ),
              ),
            )
          ),
        )
    );
  }
}