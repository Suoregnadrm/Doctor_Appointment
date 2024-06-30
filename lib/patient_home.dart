import 'package:flutter/material.dart';
import 'firebase_function.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final bool _isLoading = false;
  final bool _showDoctorList = false;

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        // Background image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg_color.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent, // Make scaffold transparent
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0), // Hide the default app bar
            child: Container(), // Empty container
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton( // Hamburger button
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            // Handle hamburger button press
                          },
                        ),
                        const Text(
                          'HOME',
                          style: TextStyle(
                            fontSize: 20,
                            //fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'ProtestRiot',
                          ),
                        ),
                        IconButton( // Settings button
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            // Handle settings button press
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    height: 40, // Set height to maintain consistency
                    width: 280, // Set width to match parent
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // Add border radius for slight curve
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        //Navigator.push(
                        //context,
                        //MaterialPageRoute(builder: (context) => ViewDoctors()),
                        //);
                      },
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.blue, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Button border radius
                        ),
                      ),
                      child: const Text(
                        'View Doctors',
                        style: TextStyle(
                          fontFamily: 'OldStandardTT',
                          fontWeight: FontWeight.w800,
                          color: Colors.white, // Text color
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    height: 40, // Set height to maintain consistency
                    width: 280, // Set width to match parent
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15), // Add border radius for slight curve
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        //Navigator.push(
                        //context,
                        //MaterialPageRoute(builder: (context) => ViewAppointmentHistory()),
                        //);
                      },
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.blue, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Button border radius
                        ),
                      ),
                      child: const Text(
                        'Appointment History',
                        style: TextStyle(
                          fontFamily: 'OldStandardTT',
                          fontWeight: FontWeight.w800,
                          color: Colors.white, // Text color
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Colors.white.withOpacity(0.7), // White color with 60% opacity
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 2),
                IconButton(icon: const Icon(Icons.home), onPressed: () {}),
                IconButton(icon: const Icon(Icons.gamepad), onPressed: () {}),
                IconButton(icon: const Icon(Icons.account_box), onPressed: () {}),
                const SizedBox(width: 2),
              ],
            ),
          ),
        ),
        if (_isLoading) fullScreenLoader(),
      ],
    );
  }
}