import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobile_app/services/firestore.dart';

class MyDialogFormat extends StatefulWidget {
  final File image;
  final String title;
  final String description;
  final Map<String, dynamic> symptoms;
  final Map<String, dynamic> treatment;
  const MyDialogFormat(
      {super.key,
      required this.image,
      required this.title,
      required this.description,
      required this.symptoms,
      required this.treatment});

  @override
  State<MyDialogFormat> createState() => _MyDialogFormatState();
}

class _MyDialogFormatState extends State<MyDialogFormat> {
  final FirestoreService firestoreService = FirestoreService();
  bool _isLoading = false;

  String formatMaps(Map<String, dynamic> mapData) {
    return mapData.entries
        .map((entry) => '${entry.key}. ${entry.value}')
        .join('\n');
  }

  Future<bool> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.only(
        top: 70,
        bottom: 40,
        left: 10,
        right: 10,
      ),
      contentTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
      content: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.file(
                    widget.image,
                    width: 200,
                    height: 200,
                  ), // Adjust image radius as needed
                ],
              ),
              const SizedBox(height: 10), // Add some space
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20), // Add some space
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 5),
              Text(
                widget.description,
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              const Text(
                'Symptoms:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 5),
              Text(
                formatMaps(widget.symptoms),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              const Text(
                'Treatment:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 5),
              Text(
                formatMaps(widget.treatment),
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the modal sheet
                Navigator.pushNamed(context, '/homepage');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red[300], // Set background color for Cancel button
                foregroundColor: Colors.white,
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(
              width: 40,
            ),
            ElevatedButton(
              onPressed: () async {
                if (_isLoading) return;

                setState(() {
                  _isLoading = true;
                });

                Navigator.pushNamed(context, '/homepage');

                String imageUrl =
                    await firestoreService.uploadImage(widget.image);
                await firestoreService.addLog(widget.title, imageUrl);

                setState(() {
                  _isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.blue[300], // Set background color for Add button
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}
