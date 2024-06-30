import 'package:flutter/material.dart';
import 'package:medic/provider.dart';
import 'package:provider/provider.dart';
import 'registration_page.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserData>(create: (_) => UserData()),
        ChangeNotifierProvider<DoctorsProvider>(create: (_)=> DoctorsProvider(),),
        ChangeNotifierProvider<AppointmentsProvider>(create: (_)=> AppointmentsProvider(),),
      ],
      child: const MaterialApp(
        title: "Medic",
        home: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg_color.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with rounded corners and transparency
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                      child: Image.asset(
                        'assets/Logo.png',
                        width: 120.0,
                        height: 120.0,
                      ),
                    ),
                  ),
                  //const SizedBox(height: 10),
                  // Rest of the content...

                  // const Text(
                  //   'WELCOME TO',
                  //   //style: TextStyle(fontFamily: 'PlayfairDisplay-VariableFont_wght', fontSize: 27),
                  //   style: TextStyle(fontFamily: 'Quicksand-VariableFont_wght', fontSize: 27),
                  //   textAlign: TextAlign.center,
                  // ),
                  // const SizedBox(height: 10),
                  // const Text(
                  //   'MEDIC',
                  //   style: TextStyle(fontSize: 27, fontFamily: 'Merriweather'),
                  //   //style: TextStyle(fontFamily: 'AlfaSlabOne', fontSize: 28),
                  //   textAlign: TextAlign.center,
                  // ),
                  const SizedBox(height: 40),
                  const Text(
                    'Welcome to your Doctor Appointment App',
                    style: TextStyle(fontFamily: 'OldStandardTT',
                        fontSize: 15,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const Text('Let\'s Get Started..!',
                      style: TextStyle(fontFamily: 'Merriweather-Italic', fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w300,
                      )
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context)=>const LoginPage()
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Adjust the value as needed
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 100), // Adjust the padding as needed
                        minimumSize: const Size(200, 0), // Adjust the minimum size as needed
                      ),
                      child: const Text(
                        'Login',
                          style: TextStyle(fontFamily: 'Merriweather-Italic', fontSize: 14)
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),
                  // Already have an account text and Register button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Create new account?',
                          style: TextStyle(fontFamily: 'Merriweather-Italic', fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500)
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context)=>const RegistrationPage()
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Adjust the padding as needed
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontFamily: 'Merriweather-Italic',
                            fontSize: 14, // Adjust the font size as needed
                          ),
                        ),
                      ),

                    ],
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
