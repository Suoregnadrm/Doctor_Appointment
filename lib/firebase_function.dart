import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:medic/provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'doctors_page.dart';
import 'home.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
String uid = "";


Future<void> verifyPhoneNumber(BuildContext context,String phoneNumber) async {
  final userData = Provider.of<UserData>(context, listen: false);
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {

    },
    verificationFailed: (FirebaseAuthException e) {
      print(e);
      // Handle verification failure, e.g., invalid phone number format
      showDialog(
        context: context,
        builder: (BuildContext context) {
          //signOutUser(context);
          return AlertDialog(
            title: const Text('Verification Failed'),
            content: e!=null?Text(e.message.toString()):const Text('The phone number verification has failed due to. Please try again.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  //isLoading.setIsLoading(false);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
    codeSent: (String verificationId, int? resendToken) {
      userData.setVerificationID(verificationId);
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      // Auto-retrieval timeout, handle the situation accordingly
      print('Phone verification timeout');
    },
  );
}

Future<void> verifyOTPCodeForRegistration(BuildContext context, String verificationId,String code,) async {
  final userData = Provider.of<UserData>(context,listen: false);
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    if (userCredential.user != null) {
      uid = userCredential.user!.uid;
      userData.setUid(uid);
      //print(userData.uid);
      if(await checkINFirestore(context)){
        snackBar("Account already exists with the number", context);
        signOut();
        //Navigator.pop(context);
      }
      else{
        snackBar("in",context);
        await storeSignup(context);
        await getDoctors(context);
        if(userData.type == "Patient"){
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context)=>const Home()),
                (route) => false,
          );
        }
        else{
          // await getAppointments(context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context)=>const DoctorProfilePage()),
                (route) => false,
          );
        }
      }

    }
  } catch (e) {
    print('Sign-in error: ${e.toString()}');
  }
}

Future<void> verifyOTPCodeForLogin(BuildContext context, String verificationId,String code,) async {
  final userData = Provider.of<UserData>(context,listen: false);
  try {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: code,
    );
    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    if (userCredential.user != null) {
      uid = userCredential.user!.uid;
      userData.setUid(uid);
      // snackBar("In",context);
      await doesUserExist(context);
    }
  } catch (e) {
    print('Sign-in error: ${e.toString()}');
  }
}


Future<bool> checkINFirestore(BuildContext context) async{
  final userData = Provider.of<UserData>(context, listen: false);
  CollectionReference userRef = firestore.collection('users');
  CollectionReference docRef = firestore.collection('doctors');
  bool res = false;
  DocumentSnapshot document1Snapshot =
  await userRef.doc(userData.uid).get();
  DocumentSnapshot document2Snapshot =
  await docRef.doc(userData.uid).get();

  if(document1Snapshot.exists || document2Snapshot.exists){
    res = true;
  }

  return res;
}


Future<void> storeSignup(BuildContext context) async {
  final userData = Provider.of<UserData>(context, listen: false);
  //print(userData.type);
  if(userData.type == "Patient") {
    CollectionReference userRef = firestore.collection('users');
    //final userData = Provider.of<UserData>(context, listen: false);
    //String uId = userData.uid;
    //await getFCMFromCache(context);
    Map<String, dynamic> data = {
      'name': userData.userName,
      'age' : userData.age,
      'gender': userData.gender,
      'phone Number': userData.phoneNumber,
      'uid': userData.uid,
      'email': userData.email,
      'type': userData.type,
      'registered on': DateTime.now(),
      // Add more fields as needed
    };
    try {
      await userRef.doc(userData.uid).set(data);
      print('Document added with ID: ${userData.uid}');
    } catch (e) {
      print('Error adding document: ${e.toString()}');
    }
  }
  if(userData.type == "Doctor") {
    CollectionReference userRef = firestore.collection('doctors');
    //final userData = Provider.of<UserData>(context, listen: false);
    //String uId = userData.uid;
    //await getFCMFromCache(context);
    Map<String, dynamic> data = {
      'name': userData.userName,
      'age' : userData.age,
      'gender': userData.gender,
      'phone Number': userData.phoneNumber,
      'uid': userData.uid,
      'email': userData.email,
      'type': userData.type,
      'doctortype': userData.doctortype,
      'fees': userData.fees,
      'from time':userData.fromTime,
      'to time': userData.toTime,
      'appointments':0,
      'registered on': DateTime.now(),
      'license': "",
      'status': "verified",
    };
    try {
      await userRef.doc(userData.uid).set(data);
      print('Document added with ID: ${userData.uid}');
    } catch (e) {
      print('Error adding document: ${e.toString()}');
    }
  }
}


void snackBar(String text,BuildContext context){
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)),
  );
}


Widget fullScreenLoader(){
  return Container(
    color: Colors.white,
    child: Center(
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          //shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Center(
          child: LoadingAnimationWidget.stretchedDots(
            color: Colors.blue,
            size: 50,
          ),
        ),
      ),
    ),
  );
}
Future<void> signOut() async {
  try {
    await _auth.signOut();
    print('User signed out successfully');
    // Navigate to login screen or desired flow
  } catch (e) {
    print('Error signing out: $e');
    // Handle errors appropriately
  }
}

Future<void> doesUserExist(BuildContext context)async {

  snackBar("in",context);
  final userData = Provider.of<UserData>(context,listen: false);
  final CollectionReference userRef = firestore.collection('users');
  final CollectionReference docRef = firestore.collection('doctors');
  DocumentSnapshot document1Snapshot =
  await userRef.doc(userData.uid).get();
  DocumentSnapshot document2Snapshot =
  await docRef.doc(userData.uid).get();

  if (document1Snapshot.exists) {
    // Document exists, you can access its data
    Map<String, dynamic> data = document1Snapshot.data() as Map<String, dynamic>;
    userData.setType(data['type']);
    userData.setPhoneNumber(data['phone Number']);
    userData.setEmail(data['email']);
    userData.setUserName(data['name']);
    userData.setAge(data['age']);
    userData.setGender(data['gender']);
    await getDoctors(context);
    snackBar("Patient",context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context)=>const Home()),
          (route) => false,

    );

  }
  else  if (document2Snapshot.exists) {
    // Document exists, you can access its data
    Map<String, dynamic> data = document2Snapshot.data() as Map<String, dynamic>;
    userData.setType(data['type']);
    userData.setPhoneNumber(data['phone Number']);
    userData.setEmail(data['email']);
    userData.setUserName(data['name']);
    userData.setAge(data['age']);
    userData.setGender(data['gender']);
    userData.setDoctorType(data['doctortype']);
    userData.setFee(data['fees']);
    userData.setFromTime(data['from time']);
    userData.setToTime(data['to time']);
    userData.setStatus(data['status']);

    await getAppointments(context);
    // snackBar("Doctor",context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context)=>const DoctorProfilePage()),
          (route) => false,

    );

  }
  else {
    signOut();
    snackBar("NOT Registered", context);
    Navigator.pop(context);
  }
}

Future<void> getDoctors(BuildContext context)async {
  final doctorProvider = Provider.of<DoctorsProvider>(context,listen:false);
  final userData = Provider.of<UserData>(context,listen: false);
  List<Doctor> doctors=[];
  try {
    final docRef = await firestore.collection("doctors").get();
    for(QueryDocumentSnapshot doc in docRef.docs){
      Map<String, dynamic> data = doc.data() as Map<String,dynamic> ;
      int appointments = data['appointments'];
      if(appointments == 5 || data['status'] =="not verified"){
        continue;
      }
      String name = data['name'];
      String age = data['age'];
      String doctortype = data['doctortype'];
      String uid = data['uid'];
      String email = data['email'];
      int fees = data['fees'];
      String fromTime = data['from time'];
      String gender = data['gender'];
      String phoneNumber = data['phone Number'];
      String toTime = data['to time'];
      String type = data['type'];
      doctors.add(Doctor(name: name, age: age, doctortype: doctortype, email: email, fromTime: fromTime, gender: gender, phoneNumber: phoneNumber, toTime: toTime, type: type, uid: uid, fees: fees,appointments: appointments));

      //teachers.add(Teacher(uid: uid, name: name, exp: exp, description: description, pay: pay,rating: rating,dp:dp))
    }
    doctorProvider.setDoctors(doctors);

  } catch (error) {
    // Handle any errors that occurred during fetching
    //snackBar("$error", context);
    print('Error fetching doctors: $error');
    doctorProvider.setDoctors([]);
  }
}

Future<void> bookAppointment(BuildContext context, String doctorUid, String DocName, String FTime, String TTime) async {
  final userData = Provider.of<UserData>(context,listen:false);
  CollectionReference appointmentRef =  firestore.collection("doctors").doc(doctorUid).collection("appointments");
  final appUpdateRef =  firestore.collection("doctors").doc(doctorUid);
  final adocSnap =   await appUpdateRef.get();
  Map<String, dynamic> datt = adocSnap.data() as Map<String,dynamic> ;
  int appointments = datt['appointments'];
  appointments++;
  DocumentSnapshot docSnap =
  await appointmentRef.doc(userData.uid).get();
  if(docSnap.exists){
    snackBar("Appointment already exists", context);
    return;
  }
  Map<String, dynamic> data = {
    'name': userData.userName,
    'age' : userData.age,
    'gender': userData.gender,
    'phone Number': userData.phoneNumber,
    'uid': userData.uid,
    'email': userData.email,
    // Add more fields as needed
  };
  try{
    await appointmentRef.doc(userData.uid).set(data);
    await firestore.collection("doctors").doc(doctorUid).update({
      'appointment' : appointments,
    });
    await firestore.collection("users").doc(userData.uid).collection("appointments").doc().set({
      'doctorName': DocName,
      'From': FTime,
      'To': TTime,
    });
    snackBar("Booking Done", context);
  }
  catch(e){
    print(e);
  }
}

Future<void> getAppointments(BuildContext context)async {
  final appointmentsProvider = Provider.of<AppointmentsProvider>(context,listen:false);
  final userData = Provider.of<UserData>(context,listen: false);
  List<Appointment> appointments=[];
  try {
    final docRef = await firestore.collection("doctors").doc(userData.uid).collection("appointments").get();
    for(QueryDocumentSnapshot doc in docRef.docs){
      Map<String, dynamic> data = doc.data() as Map<String,dynamic> ;
      String name = data['name'];
      String age = data['age'];
      String uid = data['uid'];
      String email = data['email'];
      String gender = data['gender'];
      String phoneNumber = data['phone Number'];

      appointments.add(Appointment(name: name, age: age, gender: gender, email: email, phoneNumber: phoneNumber, uid: uid));
      //teachers.add(Teacher(uid: uid, name: name, exp: exp, description: description, pay: pay,rating: rating,dp:dp))
    }
    appointmentsProvider.setAppointments(appointments);

  } catch (error) {
    // Handle any errors that occurred during fetching
    //snackBar("$error", context);
    print('Error fetching doctors: $error');
    appointmentsProvider.setAppointments([]);
  }
}


Future<List<AppointmentHistory>> fetchUserAppointments(String userId) async {
  List<AppointmentHistory> userAppointments = [];

  try {
    // Reference to the user's appointments collection in Firestore
    CollectionReference appointmentsRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('appointments');

    // Query for the user's appointments
    QuerySnapshot querySnapshot = await appointmentsRef.get();

    // Iterate through the documents and extract appointment data
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      AppointmentHistory appointment = AppointmentHistory.fromFirestore(data);
      userAppointments.add(appointment);
    }
  } catch (e) {
    // Handle any errors that occurred during fetching
    print('Error fetching user appointments: $e');
  }

  return userAppointments;
}


String getFileName(String filePath) {
  return filePath.split('/').last;
}
Future<void> uploadLicence(BuildContext context) async {
  final userData = Provider.of<UserData>(context,listen: false);

  try {

    final storageReference = FirebaseStorage.instance.ref().child('licence');
    final fileName = getFileName(userData.licenceFile.path);

    // Upload the file
    await storageReference.child(fileName).putFile(userData.licenceFile);

    // Get download URL and update user data
    final downloadURL = await storageReference.child(fileName).getDownloadURL();
    userData.setLicence(downloadURL);

    // Dismiss progress indicator and show success message
    snackBar("Licence uploaded successfully!", context);
  } catch (e) {
    // Handle errors with specific messages
    final message = e.toString();
    snackBar(message, context);
  }
}

Future<String?> getDoctorIdFromName(String doctorName) async {
  try {
    // Query for the doctor by name
    final querySnapshot = await FirebaseFirestore.instance.collection('doctors').where('name', isEqualTo: doctorName).get();

    // Return the doctorId if found
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching doctorId: $e');
    return null;
  }
}

Future<void> deleteDoctorAppointment(String doctorId, String userId, String doctorName, String fromTime, String toTime) async {
  try {
    // Get the doctor's appointments collection reference
    final doctorAppointmentsRef = FirebaseFirestore.instance.collection('doctors').doc(doctorId).collection('appointments');

    // Query for the appointment
    final querySnapshot = await doctorAppointmentsRef
        .where('uid', isEqualTo: userId)
        // .where('doctorName', isEqualTo: doctorName)
        // .where('fromTime', isEqualTo: fromTime)
        // .where('toTime', isEqualTo: toTime)
        .get();

    // Delete the appointment if found
    querySnapshot.docs.forEach((doc) async {
      await doctorAppointmentsRef.doc(doc.id).delete();
    });
  } catch (e) {
    // Handle errors
    print('Error deleting doctor appointment: $e');
  }
}

Future<void> deleteUserAppointment(String userId, String doctorName, String fromTime, String toTime) async {
  try {
    // Reference to the user's appointments collection in Firestore
    CollectionReference appointmentsRef = FirebaseFirestore.instance.collection('users').doc(userId).collection('appointments');

    // Query for the user's appointments
    QuerySnapshot querySnapshot = await appointmentsRef.where('doctorName', isEqualTo: doctorName).get();

    // Iterate through the documents and extract appointment data
    for (var doc in querySnapshot.docs) {
      await appointmentsRef.doc(doc.id).delete();
    }
  } catch (e) {
    // Handle any errors that occurred during fetching
    print('Error fetching user appointments: $e');
  }
}

