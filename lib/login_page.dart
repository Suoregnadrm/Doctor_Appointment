import 'package:flutter/material.dart';
import 'package:medic/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'firebase_function.dart';
// import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _phoneNumber = '';
  TextEditingController otpController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return Scaffold(
      body: Stack(children: [
        SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height, // Set the height of the container to the screen height
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_color.jpg'), // Replace with your background image
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 25, left: 25, top: 50),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container( // Custom rectangular box
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'ProtestRiot',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 120.0),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Phone Number',
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0), // Adjust the curve as needed
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 16.0),
                            ),
                            validator: (value) => value!.isEmpty ? 'Please enter Phone Number' : null,
                            onChanged: (value) => _phoneNumber = value,
                          ),
                        ),

                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              _isLoading = true;
                            });
                            await verifyPhoneNumber(context, "+91$_phoneNumber");
                            snackBar("OTP sent",context);
                            setState(() {
                              _isLoading = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            // primary: Colors.blue, // Background color
                            // onPrimary: Colors.white, // Text color
                            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0), // Adjust the curve as needed
                            ),
                            elevation: 4, // Elevation
                          ),
                          child: const Text(
                            'Get OTP',
                            style: TextStyle(fontFamily: 'OldStandardTT', fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: PinCodeTextField(
                            appContext: context,
                            length: 6,
                            onChanged: (value) {
                              print(value);
                            },
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.underline,
                              activeColor: Colors.blue,
                              inactiveColor: Colors.grey,
                              selectedColor: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              await verifyOTPCodeForLogin(context, userData.verfID, otpController.text);
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            // primary: Colors.blue, // Background color
                            // onPrimary: Colors.white, // Text color
                            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0), // Border radius
                            ),
                            elevation: 4, // Elevation
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontFamily: 'ProtestRiot', fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
        if(_isLoading)
          fullScreenLoader(),
      ]),
      // Extend the body to fullscreen when keyboard is displayed
      resizeToAvoidBottomInset: true,
    );
  }
}
