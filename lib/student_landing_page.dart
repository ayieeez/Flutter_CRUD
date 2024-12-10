
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentLandingPage extends StatefulWidget {
  const StudentLandingPage({Key? key}) : super(key: key);

  @override
  _StudentLandingPageState createState() => _StudentLandingPageState();
}

class _StudentLandingPageState extends State<StudentLandingPage>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _bookingsRef =
      FirebaseDatabase.instance.ref().child('bookings');

  // Add a variable to track user role
  String userRole = 'student'; // Default to student for this example

  final TextEditingController applicantNameController = TextEditingController();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventDescriptionController =
      TextEditingController();

  String? eventType = 'Formal'; // Default event type
  List<Map<String, dynamic>> equipmentSelections = [
    {'equipment': null, 'quantity': 1}
  ];

  final List<String> equipmentOptions = [
    'Camera',
    'Portable Projector',
    'Portable Stage',
    'Portable Stand',
    'Portable Speaker',
    'Rostrum',
    'Dining Table'
  ];

  final Map<String, int> equipmentStock = {
    'Camera': 10,
    'Portable Projector': 5,
    'Portable Stage': 3,
    'Portable Stand': 7,
    'Portable Speaker': 4,
    'Rostrum': 2,
    'Dining Table': 6,
  };

  List<Map<String, dynamic>> bookings = [];

  late TabController _tabController;

  // Modify _fetchBookings to filter based on user role
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
            'role': value['role'], // Assuming there's a field indicating the user role
          };
        }).toList();

        // Filter bookings based on the user role
        if (userRole == 'student') {
          bookings = bookings.where((booking) => booking['role'] == 'student').toList();
        }
      });
    }
  }

  Future<void> _addBooking() async {
    if (applicantNameController.text.isEmpty) return;

    List<Map<String, dynamic>> equipmentList = equipmentSelections
        .where((selection) => selection['equipment'] != null)
        .map((selection) => {
              'equipment': selection['equipment'],
              'quantity': selection['quantity']
            })
        .toList();

    // Add the user's role when adding a booking
    await _bookingsRef.push().set({
      'applicant_name': applicantNameController.text,
      'state': 'Melaka',
      'campus': 'UiTM Kampus Jasin',
      'event_name': eventNameController.text,
      'event_description': eventDescriptionController.text,
      'event_type': eventType,
      'equipment': equipmentList,
      'status': 'Pending', // Set default status to Pending
      'created_at': DateTime.now().toString(),
      'role': userRole, // Store the user's role in the booking
    });

    applicantNameController.clear();
    eventNameController.clear();
    eventDescriptionController.clear();
    setState(() {
      equipmentSelections = [
        {'equipment': null, 'quantity': 1}
      ];
    });

    await _fetchBookings();
  }

  void _addEquipmentSelection() {
    setState(() {
      equipmentSelections.add({'equipment': null, 'quantity': 1});
    });
  }

  void _logout() {
    Navigator.of(context)
        .pushReplacementNamed('/'); // Assuming '/' is your main page route
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
    applicantNameController.dispose();
    eventNameController.dispose();
    eventDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipment Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Current Bookings'),
            Tab(text: 'New Booking'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Current Bookings
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Bookings',
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
                              trailing: Icon(
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
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
          ),

          // Tab 2: New Booking
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: applicantNameController,
                  decoration:
                      const InputDecoration(labelText: 'Applicant Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: eventNameController,
                  decoration: const InputDecoration(labelText: 'Event Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: eventDescriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Event Description'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: eventType,
                  decoration: const InputDecoration(labelText: 'Type of Event'),
                  items: ['Formal', 'Non-Formal']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => eventType = value),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Select Equipment and Quantity',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...equipmentSelections.map((selection) {
                  int stock = selection['equipment'] != null
                      ? equipmentStock[selection['equipment']] ?? 1
                      : 1;
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selection['equipment'],
                          decoration:
                              const InputDecoration(labelText: 'Equipment'),
                          items: equipmentOptions
                              .map((equipment) => DropdownMenuItem(
                                    value: equipment,
                                    child: Text(equipment),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selection['equipment'] = value;
                              selection['quantity'] = 1;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: selection['quantity'],
                          decoration:
                              const InputDecoration(labelText: 'Quantity'),
                          items: List<int>.generate(stock, (index) => index + 1)
                              .map((quantity) => DropdownMenuItem(
                                    value: quantity,
                                    child: Text(quantity.toString()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selection['quantity'] = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addEquipmentSelection,
                  child: const Text('Add Equipment'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addBooking,
                  child: const Text('Submit Booking'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

