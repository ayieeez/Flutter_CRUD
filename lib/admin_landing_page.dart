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
<<<<<<< HEAD
  final DatabaseReference _deletedBookingsRef =
      FirebaseDatabase.instance.ref().child('deleted_bookings');

  List<Map<String, dynamic>> bookings = [];
  List<Map<String, dynamic>> deletedBookings = [];
  List<String> selectedBookings = [];
  bool isSelectAllBookingHistory = false;
  bool isSelectAllDeletedBookings = false;
=======

  List<Map<String, dynamic>> bookings = [];
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812

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
<<<<<<< HEAD
            'status': value['status'],
          };
        }).toList();
      });
    }
  }

  Future<void> _fetchDeletedBookings() async {
    final snapshot = await _deletedBookingsRef.once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      setState(() {
        deletedBookings = data.entries.map((entry) {
          final value = entry.value as Map<dynamic, dynamic>;
          return {
            'id': entry.key,
            'applicant_name': value['applicant_name'],
            'event_name': value['event_name'],
            'event_description': value['event_description'],
            'event_type': value['event_type'],
            'equipment': value['equipment'],
            'status': value['status'],
=======
            'status': value['status'], // Add status field
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
          };
        }).toList();
      });
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
<<<<<<< HEAD
    await _bookingsRef.child(bookingId).update({'status': newStatus});
=======
    await _bookingsRef.child(bookingId).update({
      'status': newStatus,
    });

    // Refresh the bookings list after the status update
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
    await _fetchBookings();
  }

  Future<void> _deleteBooking(String bookingId) async {
<<<<<<< HEAD
    final booking =
        bookings.firstWhere((booking) => booking['id'] == bookingId);

    // Add to deleted bookings instead of deleting from the database
    await _deletedBookingsRef.child(bookingId).set(booking);
    await _bookingsRef.child(bookingId).update({'status': 'Deleted'});
    setState(() {
      bookings.removeWhere((booking) => booking['id'] == bookingId);
      deletedBookings.add(booking);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking deleted temporarily')),
    );
=======
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
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
  }

  Future<void> _deleteSelectedBookings() async {
    for (var bookingId in selectedBookings) {
      final booking =
          bookings.firstWhere((booking) => booking['id'] == bookingId);

      // Add to deleted bookings and update status to 'Deleted'
      await _deletedBookingsRef.child(bookingId).set(booking);
      await _bookingsRef.child(bookingId).update({'status': 'Deleted'});
      setState(() {
        bookings.removeWhere((booking) => booking['id'] == bookingId);
        deletedBookings.add(booking);
      });
    }

    selectedBookings.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected bookings deleted temporarily')),
    );
  }

  Future<void> _restoreDeletedBooking(String bookingId) async {
    final booking =
        deletedBookings.firstWhere((booking) => booking['id'] == bookingId);

    // Restore from deleted bookings to bookings
    await _bookingsRef.child(bookingId).set(booking);
    await _deletedBookingsRef.child(bookingId).remove();
    setState(() {
      deletedBookings.removeWhere((booking) => booking['id'] == bookingId);
      bookings.add(booking);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking restored successfully')),
    );
  }

  Future<void> _permanentlyDeleteBooking(String bookingId) async {
    await _deletedBookingsRef.child(bookingId).remove();
    await _bookingsRef
        .child(bookingId)
        .remove(); // Remove from bookings as well
    setState(() {
      deletedBookings.removeWhere((booking) => booking['id'] == bookingId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking permanently deleted')),
    );
  }

  Future<void> _permanentlyDeleteSelectedBookings() async {
    for (var bookingId in selectedBookings) {
      await _deletedBookingsRef.child(bookingId).remove();
      await _bookingsRef.child(bookingId).remove(); // Remove from bookings
      setState(() {
        deletedBookings.removeWhere((booking) => booking['id'] == bookingId);
      });
    }

    selectedBookings.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selected bookings permanently deleted')),
    );
  }

  void _toggleSelectAllBookingHistory() {
    setState(() {
      isSelectAllBookingHistory = !isSelectAllBookingHistory;
      if (isSelectAllBookingHistory) {
        selectedBookings =
            bookings.map((booking) => booking['id'] as String).toList();
      } else {
        selectedBookings.clear();
      }
    });
  }

  void _toggleSelectAllDeletedBookings() {
    setState(() {
      isSelectAllDeletedBookings = !isSelectAllDeletedBookings;
      if (isSelectAllDeletedBookings) {
        selectedBookings =
            deletedBookings.map((booking) => booking['id'] as String).toList();
      } else {
        selectedBookings.clear();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _fetchDeletedBookings();
    _tabController = TabController(length: 3, vsync: this);
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
<<<<<<< HEAD
              Navigator.of(context).pushReplacementNamed('/');
=======
              Navigator.of(context).pushReplacementNamed(
                  '/'); // Assuming '/' is your main page route
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Booking History'),
            Tab(text: 'Pending Approvals'),
<<<<<<< HEAD
            Tab(text: 'Recently Deleted'),
=======
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
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
<<<<<<< HEAD
                Row(
                  children: [
                    Checkbox(
                      value: isSelectAllBookingHistory,
                      onChanged: (_) {
                        _toggleSelectAllBookingHistory();
                      },
                    ),
                    const Text("Select All"),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: selectedBookings.isEmpty
                          ? null
                          : _deleteSelectedBookings,
                      child: const Text('Delete Selected'),
                    ),
                  ],
                ),
=======
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
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
<<<<<<< HEAD
                              trailing: Checkbox(
                                value: selectedBookings.contains(booking['id']),
                                onChanged: (_) {
                                  setState(() {
                                    if (selectedBookings
                                        .contains(booking['id'])) {
                                      selectedBookings.remove(booking['id']);
                                    } else {
                                      selectedBookings.add(booking['id']);
                                    }
                                  });
                                },
                              ),
=======
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
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),
<<<<<<< HEAD
          // Tab 2: Pending Approvals
=======

          // Tab 2: Pending Approvals (Optional)
          // This tab can show only the pending bookings
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
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
<<<<<<< HEAD
                Column(
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
                            Text('Applicant: ${booking['applicant_name']}'),
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
                            IconButton(
                              icon: const Icon(Icons.check),
                              onPressed: () {
                                _updateBookingStatus(booking['id'], 'Approved');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _updateBookingStatus(booking['id'], 'Rejected');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Tab 3: Recently Deleted
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recently Deleted',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: isSelectAllDeletedBookings,
                      onChanged: (_) {
                        _toggleSelectAllDeletedBookings();
                      },
                    ),
                    const Text("Select All"),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: selectedBookings.isEmpty
                          ? null
                          : _permanentlyDeleteSelectedBookings,
                      child: const Text('Permanently Delete Selected'),
                    ),
                  ],
                ),
                deletedBookings.isEmpty
                    ? const Center(child: Text('No recently deleted bookings.'))
                    : Column(
                        children: deletedBookings.map((booking) {
=======
                bookings
                        .where((booking) => booking['status'] == 'Pending')
                        .isEmpty
                    ? const Center(child: Text('No pending approvals.'))
                    : Column(
                        children: bookings
                            .where((booking) => booking['status'] == 'Pending')
                            .map((booking) {
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
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
<<<<<<< HEAD
                                  Text('Status: ${booking['status']}'),
=======
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
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
<<<<<<< HEAD
                              trailing: Checkbox(
                                value: selectedBookings.contains(booking['id']),
                                onChanged: (_) {
                                  setState(() {
                                    if (selectedBookings
                                        .contains(booking['id'])) {
                                      selectedBookings.remove(booking['id']);
                                    } else {
                                      selectedBookings.add(booking['id']);
                                    }
                                  });
                                },
=======
                              trailing: const Icon(
                                Icons.pending,
                                color: Colors.orange,
>>>>>>> a66b96089096d6b0c998bee04db4efef528fa812
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
