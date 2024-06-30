import 'package:flutter/material.dart';
import 'firebase_function.dart';
import 'provider.dart';
import 'package:provider/provider.dart';

class ViewAppointmentHistory extends StatefulWidget {
  const ViewAppointmentHistory({Key? key}) : super(key: key);

  @override
  _ViewAppointmentHistoryState createState() => _ViewAppointmentHistoryState();
}

class _ViewAppointmentHistoryState extends State<ViewAppointmentHistory> {
  bool _isLoading = false;
  List<AppointmentHistory> _appointmentHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment History'),
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _buildAppointmentHistoryList(_appointmentHistory),
          if (_isLoading) fullScreenLoader(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchAppointmentHistory();
  }

  Future<void> _fetchAppointmentHistory() async {
    final userData = Provider.of<UserData>(context, listen: false);
    setState(() {
      _isLoading = true;
    });
    List<AppointmentHistory> appointmentHistory = await fetchUserAppointments(userData.uid);
    setState(() {
      _isLoading = false;
      _appointmentHistory = appointmentHistory;
    });
  }

  Future<void> _deleteAppointment(String userId, String doctorName, String fromTime, String toTime) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch the doctorId using doctorName
      final doctorId = await getDoctorIdFromName(doctorName);

      if (doctorId != null) {
        // Delete the appointment from the doctor's appointments collection
        await deleteDoctorAppointment(doctorId, userId, doctorName, fromTime, toTime);

        // After deleting from the doctor's appointments, delete from the user's appointments
        await deleteUserAppointment(userId, doctorName, fromTime, toTime);

        // Fetch updated appointment history
        await _fetchAppointmentHistory();
      } else {
        print('Doctor not found');
      }
    } catch (e) {
      print('Error deleting appointment: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildAppointmentHistoryList(List<AppointmentHistory> appointments) {
    final userData = Provider.of<UserData>(context, listen: false);
    if (appointments.isEmpty) {
      return Center(child: Text('No appointment history available.'));
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.0),
          elevation: 4.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: ListTile(
            contentPadding: EdgeInsets.all(16.0),
            title: Text(
              'Doctor: ${appointment.doctorName}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Text(
                  'From: ${appointment.fromTime}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                Text(
                  'To: ${appointment.toTime}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteAppointment(
                userData.uid,
                appointment.doctorName,
                appointment.fromTime,
                appointment.toTime,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget fullScreenLoader() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
