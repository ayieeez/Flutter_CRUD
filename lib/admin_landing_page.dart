import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminLandingPage extends StatefulWidget {
  const AdminLandingPage({Key? key}) : super(key: key);

  @override
  _AdminLandingPageState createState() => _AdminLandingPageState();
}

class _AdminLandingPageState extends State<AdminLandingPage>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _bookingsRef =
      FirebaseDatabase.instance.ref().child('bookings');

  List<Map<String, dynamic>> bookings = [];

  late TabController _tabController;

  Future<void> _fetchBookings() async {
    final snapshot = await _bookingsRef.once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        bookings = data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key,
            'applicant_name': value['applicant_name'],
            'event_name': value['event_name'],
            'event_description': value['event_description'],
            'event_type': value['event_type'],
            'equipment': value['equipment'],
            'status': value['status'], // Add status field
          };
        }).toList();
      });
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    await _bookingsRef.child(bookingId).update({
      'status': newStatus,
    });

    // Refresh the bookings list after the status update
    await _fetchBookings();
  }

  Future<void> _deleteBooking(String bookingId) async {
    await _bookingsRef.child(bookingId).remove();
    setState(() {
      bookings.removeWhere((booking) => booking['id'] == bookingId);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Equipment Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                  '/'); // Assuming '/' is your main page route
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Booking History'),
            Tab(text: 'Pending Approvals'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Booking History
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking History',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                bookings.isEmpty
                    ? const Center(child: Text('No bookings available.'))
                    : Column(
                        children: bookings.map((booking) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Text(
                                booking['event_name'] ?? 'No event name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Applicant: ${booking['applicant_name']}'),
                                  Text('Event Type: ${booking['event_type']}'),
                                  Text('Status: ${booking['status']}'),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Equipment: ' +
                                        (booking['equipment'] as List)
                                            .map((e) =>
                                                '${e['equipment']} x${e['quantity']}')
                                            .join(', '),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    booking['status'] == 'Approved'
                                        ? Icons.check_circle
                                        : booking['status'] == 'Rejected'
                                            ? Icons.cancel
                                            : Icons.pending,
                                    color: booking['status'] == 'Approved'
                                        ? Colors.green
                                        : booking['status'] == 'Rejected'
                                            ? Colors.red
                                            : Colors.orange,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteBooking(booking['id']);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (booking['status'] == 'Pending') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Update Status'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                _updateBookingStatus(
                                                    booking['id'], 'Approved');
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Approve'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _updateBookingStatus(
                                                    booking['id'], 'Rejected');
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Reject'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),

          // Tab 2: Pending Approvals (Optional)
          // This tab can show only the pending bookings
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pending Approvals',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                bookings
                        .where((booking) => booking['status'] == 'Pending')
                        .isEmpty
                    ? const Center(child: Text('No pending approvals.'))
                    : Column(
                        children: bookings
                            .where((booking) => booking['status'] == 'Pending')
                            .map((booking) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Text(
                                booking['event_name'] ?? 'No event name',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Applicant: ${booking['applicant_name']}'),
                                  Text('Event Type: ${booking['event_type']}'),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Equipment: ' +
                                        (booking['equipment'] as List)
                                            .map((e) =>
                                                '${e['equipment']} x${e['quantity']}')
                                            .join(', '),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.pending,
                                color: Colors.orange,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
