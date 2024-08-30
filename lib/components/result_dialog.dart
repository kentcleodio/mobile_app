import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/components/dialog_format.dart';
import 'dart:developer' as devtools;
import 'package:mobile_app/services/firestore.dart';

class MyResultDialog extends StatefulWidget {
  final File image;
  final String label;

  const MyResultDialog({super.key, required this.image, required this.label});

  @override
  State<MyResultDialog> createState() => _MyResultDialogState();
}

class _MyResultDialogState extends State<MyResultDialog> {
  final FirestoreService firestoreService = FirestoreService();
  bool _isLoading = false;
  String? title;
  String? description;
  Map<String, dynamic>? symptoms;
  Map<String, dynamic>? treatment;

  @override
  void initState() {
    super.initState();
    _fetchDiseaseData();
  }

  Future<void> _fetchDiseaseData() async {
    if (widget.label == 'Motile Aeromonas Septicemia' ||
        widget.label == 'Streptococcosis' ||
        widget.label == 'Tilapia Lake Virus') {
      try {
        DocumentSnapshot docSnapshot =
            await firestoreService.getDiseaseData(widget.label);
        if (docSnapshot.exists) {
          setState(() {
            title = docSnapshot['Title'];
            description = docSnapshot['Description'];
            symptoms = Map<String, dynamic>.from(docSnapshot['Symptoms']);
            treatment = Map<String, dynamic>.from(docSnapshot['Treatment']);
          });
        } else {
          devtools.log("No such document!");
        }
      } catch (e) {
        devtools.log("Error fetching document: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.label == 'Healthy') {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/image/check.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Healthy',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
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
                  await firestoreService.addLog(widget.label, imageUrl);

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
    } else if (widget.label == 'Motile Aeromonas Septicemia' ||
        widget.label == 'Streptococcosis' ||
        widget.label == 'Tilapia Lake Virus') {
      return MyDialogFormat(
        image: widget.image,
        title: title ?? 'No Title',
        description: description ?? 'No Description',
        symptoms: symptoms ?? {'No': 'Symptoms'},
        treatment: treatment ?? {'No': 'Treatment'},
      );
    } else {
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
            padding: const EdgeInsets.only(
                top: 16.0, left: 16.0, right: 16.0, bottom: 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/image/wrong.png',
                      width: 150,
                      height: 150,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not Valid Data',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
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
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.blue[300], // Set background color for Add button
                  foregroundColor: Colors.white,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ],
      );
    }
  }
}
