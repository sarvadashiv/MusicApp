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
  bool _isNewPasswordVisible = false;
  bool _isConfirmNewPasswordVisible = false;
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  bool _isOtpSent = false;
  bool _canResendOtp = false;
  int _secondsLeft = 60;
  Timer? _timer;

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address.';
      });
      return;
    }

    setState(() {
      _isOtpSent = true;
      _canResendOtp = false;
      _secondsLeft = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          _canResendOtp = true;
          _timer?.cancel();
        }
      });
    });

    // TODO: Implement the actual OTP request logic here
  }

  void _resendOtp() {
    if (_canResendOtp) {
      _sendOtp();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resetPassword() async {

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmNewPassword = _confirmNewPasswordController.text.trim();
    if (email.isEmpty || otp.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required.';
      });
      return;
    }
    if (newPassword != confirmNewPassword) {
      setState(() {
        _errorMessage = "Passwords don't match.";
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final response = await http.post(
        Uri.parse('https://task-4-0pfy.onrender.com/user/resetpassword'),
        body: json.encode({'email': email,'otp': otp, 'newpassword': newPassword}),
        headers: {'Content-Type': 'application/json'},
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset successfully.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
      else {
        setState(() {
          _errorMessage = data['message']?? 'Password reset failed!';
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
                    SizedBox(height: 40,),
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
                    SizedBox(height: 16,),
                    Text('OTP', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'KumbhSans')),
                    SizedBox(height: 10),
                    TextField(
                      controller: _otpController,
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
                    SizedBox(height: 10,),
                    TextButton(
                      onPressed: _sendOtp,
                      child: Text(
                        _isOtpSent ? "Resend OTP ($_secondsLeft s)" : "Send OTP",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),
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
                        onPressed: _resetPassword,
                        child: Text("Reset Password", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'KumbhSans')),
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