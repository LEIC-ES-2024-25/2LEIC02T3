import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRcodeGeneratorScreen extends StatefulWidget {
  const QRcodeGeneratorScreen({super.key});

  @override
  _QRcodeGeneratorScreenState createState() => _QRcodeGeneratorScreenState();
}

class _QRcodeGeneratorScreenState extends State<QRcodeGeneratorScreen> {
  
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
    'local|commerce', 
    'thrift|store',   
    'public|transport' 
  ];

  
  String? selectedEventType;
  DateTime? selectedDate;
  String? enteredPassword;

  
  bool isQRGenerated = false;

  
  final Set<String> passwordRequiredEvents = {
    'local|commerce',
    'thrift|store',
    'public|transport'
  };

  
  static const String defaultPassword = '1234';

  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)), 
      firstDate: DateTime.now().add(Duration(days: 1)), 
      lastDate: DateTime(2100), 
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        isQRGenerated = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
        backgroundColor: Colors.green, 
        titleTextStyle: TextStyle(
          color: Colors.white, 
          fontSize: 20, 
        ),
      ),
      backgroundColor: Colors.green.shade100, 
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            SizedBox(
              height: 120, 
              child: PageView.builder(
                itemCount: 2, 
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      
                      Card(
                        color: Colors.white, 
                        elevation: 4, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), 
                        ),
                        margin: EdgeInsets.zero, 
                        child: Padding(
                          padding: const EdgeInsets.all(16.0), 
                          child: Text(
                            index == 0
                                ? "Organize an Eco-friendly Event and create a QR Code for it. Then show the QR Code to the people who join your event so they can scan it and earn points."
                                : "You must create the QR Code beforehand. To ensure that there are no fraudulent actions, it isn't allowed to generate QR Codes for a current day event.",
                            style: TextStyle(
                              color: Colors.black87, 
                              fontSize: 14, 
                              fontWeight: FontWeight.w500, 
                            ),
                          ),
                        ),
                      ),
                      
                      Positioned(
                        bottom: 30, 
                        right: 8, 
                        child: Text(
                          "${index + 1}/2", 
                          style: TextStyle(
                            color: Colors.black54, 
                            fontSize: 14, 
                            fontWeight: FontWeight.bold, 
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 0), 
            
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Event Type',
                labelStyle: TextStyle(color: Colors.black87), 
              ),
              value: selectedEventType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedEventType = newValue;
                  isQRGenerated = false; 
                  if (!passwordRequiredEvents.contains(newValue)) {
                    enteredPassword = null; 
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

            
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Select Date',
                    suffixIcon: Icon(Icons.calendar_today, color: Colors.green.shade700), 
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

            
            if (passwordRequiredEvents.contains(selectedEventType))
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter Password',
                  hintText: 'Default password is 1234',
                  labelStyle: TextStyle(color: Colors.black87), 
                ),
                obscureText: true, 
                onChanged: (value) {
                  setState(() {
                    enteredPassword = value;
                    isQRGenerated = false; 
                  });
                },
              ),

            SizedBox(height: 16),

            
            Center(
              child: ElevatedButton(
                onPressed: selectedEventType != null &&
                    selectedDate != null &&
                    (!passwordRequiredEvents.contains(selectedEventType) ||
                        enteredPassword == defaultPassword)
                    ? () {
                  
                  setState(() {
                    isQRGenerated = true;
                  });
                }
                    : null, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    Icon(Icons.qr_code, color: Colors.white), 
                    const SizedBox(width: 8), 
                    const Text(
                      "Generate QR Code",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            
            if (isQRGenerated && selectedEventType != null && selectedDate != null)
              Center(
                child: QrImageView(
                  data:
                  '$selectedEventType ${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}',
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white, 
                  gapless: true, 
                  errorStateBuilder: (context, error) {
                    return Center(
                      child: Text(
                        'Error generating QR Code',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  },              ),
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
