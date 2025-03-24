import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRcodeGeneratorScreen extends StatefulWidget {
  const QRcodeGeneratorScreen({super.key});

  @override
  _QRcodeGeneratorScreenState createState() => _QRcodeGeneratorScreenState();
}

class _QRcodeGeneratorScreenState extends State<QRcodeGeneratorScreen> {
  // Dropdown items for event types
  final List<String> eventTypes = [
    'clean|up|event',
    'eco|friendly|market',
    'sustainable|food|festival',
    'tree|planting|event',
    'bicycle|parade',
    'group|walk|event',
    'play|a|sport|event',
    'car|free|day|meet|up',
    'car|pool',
    'local|commerce', // New event type
    'thrift|store',   // New event type
    'public|transport' // New event type
  ];

  // Selected event type, date, and password
  String? selectedEventType;
  DateTime? selectedDate;
  String? enteredPassword;

  // Track whether the QR code should be displayed
  bool isQRGenerated = false;

  // List of event types that require a password
  final Set<String> passwordRequiredEvents = {
    'local|commerce',
    'thrift|store',
    'public|transport'
  };

  // Default password for password-required events
  static const String defaultPassword = '1234';

  // Function to show the date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)), // Start from tomorrow
      firstDate: DateTime.now().add(Duration(days: 1)), // Only allow future dates
      lastDate: DateTime(2100), // Arbitrary far future date
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        isQRGenerated = false; // Reset QR code when date changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
        backgroundColor: Colors.green.shade800, // Dark green for the header
        titleTextStyle: TextStyle(
          color: Colors.white, // Set the header text color to white
          fontSize: 20, // Optional: Adjust font size if needed
          fontWeight: FontWeight.bold, // Optional: Make the text bold
        ),
      ),
      backgroundColor: Colors.green.shade100, // Light green for the body background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal Swipe Cards
            SizedBox(
              height: 120, // Fixed height for the cards
              child: PageView.builder(
                itemCount: 2, // Total number of cards
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      // Card Content
                      Card(
                        color: Colors.white, // White background
                        elevation: 4, // Add subtle shadow for depth
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                        margin: EdgeInsets.zero, // Remove default margin
                        child: Padding(
                          padding: const EdgeInsets.all(16.0), // Add padding inside the card
                          child: Text(
                            index == 0
                                ? "Organize an Eco-friendly Event and create a QR Code for it. Then show the QR Code to the people who join your event so they can scan it and earn points."
                                : "You must create the QR Code beforehand. To ensure that there are no fraudulent actions, it isn't allowed to generate QR Codes for current day event.",
                            style: TextStyle(
                              color: Colors.black87, // Dark text for contrast
                              fontSize: 14, // Slightly larger font size for emphasis
                              fontWeight: FontWeight.w500, // Medium weight for readability
                            ),
                          ),
                        ),
                      ),
                      // Index Indicator (Bottom-Right Corner)
                      Positioned(
                        bottom: 30, // Reduced from 8 to bring it closer to the card
                        right: 8, // Reduced from 8 to bring it closer to the card
                        child: Text(
                          "${index + 1}/2", // Display index (1/2 or 2/2)
                          style: TextStyle(
                            color: Colors.black54, // Subtle text color
                            fontSize: 14, // Smaller font size
                            fontWeight: FontWeight.bold, // Bold for emphasis
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 0), // Add spacing between the cards and the dropdown
            // Dropdown for selecting event type
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Event Type',
                labelStyle: TextStyle(color: Colors.black87), // Adjust text color for contrast
              ),
              value: selectedEventType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedEventType = newValue;
                  isQRGenerated = false; // Reset QR code when event type changes
                  if (!passwordRequiredEvents.contains(newValue)) {
                    enteredPassword = null; // Reset password if not required
                  }
                });
              },
              items: eventTypes.map((String eventType) {
                return DropdownMenuItem<String>(
                  value: eventType,
                  child: Text(eventType.replaceAll('|', ' ')),
                );
              }).toList(),
            ),

            SizedBox(height: 16),

            // Date picker field
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.green.shade700), // Match main color
                  ),
                  controller: TextEditingController(
                    text: selectedDate != null
                        ? '${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}'
                        : null,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Password field (only visible for specific event types)
            if (passwordRequiredEvents.contains(selectedEventType))
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter Password',
                  hintText: 'Default password is 1234',
                  labelStyle: TextStyle(color: Colors.black87), // Adjust text color for contrast
                ),
                obscureText: true, // Hide password input
                onChanged: (value) {
                  setState(() {
                    enteredPassword = value;
                    isQRGenerated = false; // Reset QR code when password changes
                  });
                },
              ),

            SizedBox(height: 16),

            // Generate QR Code button
            Center(
              child: ElevatedButton(
                onPressed: selectedEventType != null &&
                    selectedDate != null &&
                    (!passwordRequiredEvents.contains(selectedEventType) ||
                        enteredPassword == defaultPassword)
                    ? () {
                  // When the button is pressed, set isQRGenerated to true
                  setState(() {
                    isQRGenerated = true;
                  });
                }
                    : null, // Disable the button if conditions are not met
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Main green color for the button
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Keep the icon and text compact
                  children: [
                    Icon(Icons.qr_code, color: Colors.white), // QR code icon
                    const SizedBox(width: 8), // Add spacing between icon and text
                    const Text(
                      "Generate QR Code",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Display the generated QR code only if isQRGenerated is true
            if (isQRGenerated && selectedEventType != null && selectedDate != null)
              Center(
                child: QrImageView(
                  data:
                  '$selectedEventType ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white, // Match the background color
                  gapless: true, // Prevent gaps between modules
                  errorStateBuilder: (context, error) {
                    return Center(
                      child: Text(
                        'Error generating QR Code',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'QRcodeGeneratorScreen',
      ),
    );
  }
}