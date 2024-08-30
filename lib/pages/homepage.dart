import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/components/result_dialog.dart';
import 'dart:developer' as devtools;

import 'package:mobile_app/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();

  String label = '';
  double confidence = 0.0;
  File? _selectedImage;
  String? _imageName;
  String imageUrl = '';
  bool _isLoading = false;

  Future<void> _tfLteInit() async {
    String? res = await Tflite.loadModel(
        model: "assets/model/my_model.tflite",
        labels: "assets/model/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  Future _pickImageFromCamera() async {
    var returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) return;

    setState(() {
      _selectedImage = File(returnedImage.path);
      _imageName = _selectedImage!.path.split('/').last;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: returnedImage.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }
    devtools.log(recognitions.toString());
    setState(() {
      confidence = (recognitions[0]['confidence'] * 100);
      label = recognitions[0]['label'].toString();
    });
  }

  Future _pickImageFromGallery() async {
    var returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;

    setState(() {
      _selectedImage = File(returnedImage.path);
      _imageName = _selectedImage!.path.split('/').last;
    });

    var recognitions = await Tflite.runModelOnImage(
        path: returnedImage.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    if (recognitions == null) {
      devtools.log("recognitions is Null");
      return;
    }
    devtools.log(recognitions.toString());
    setState(() {
      confidence = (recognitions[0]['confidence'] * 100);
      label = recognitions[0]['label'].toString();
    });
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  @override
  void initState() {
    super.initState();
    _tfLteInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Center(child: Text("FishCare")),
        backgroundColor: Colors.blue[300],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/homepage');
              },
              icon: Image.asset(
                'assets/image/Fishlogo.png',
                width: 30,
                height: 30,
              ))
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.blue[50],
        child: Column(
          children: [
            DrawerHeader(
                child: Image.asset(
              'assets/image/FishCarelogo.png',
              width: 200,
              height: 200,
            )),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("    H O M E"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/homepage');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("    A B O U T"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/aboutpage');
              },
            ),
          ],
        ),
      ),
      body: StatefulBuilder(builder: (context, setState) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(children: [
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        width: 200,
                        height: 200,
                      )
                    : const Text("Please select an image"),
                const SizedBox(
                  height: 10,
                ),
                if (_imageName != null)
                  SizedBox(
                      width: 200,
                      child: Text(
                        '$_imageName',
                        textAlign: TextAlign.center,
                      )),
              ]),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _pickImageFromCamera(),
                        child: CircleAvatar(
                          backgroundColor: Colors.blue[200],
                          radius: 50,
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 75,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Take Photo',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(width: 80),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _pickImageFromGallery(),
                        child: CircleAvatar(
                          backgroundColor: Colors.blue[200],
                          radius: 50,
                          child: const Icon(
                            Icons.photo_library_outlined,
                            size: 75,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Upload Photo',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 70,
              ),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        if (_selectedImage == null) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Please select an image.'),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        Colors.blue[300]),
                                    foregroundColor:
                                        const WidgetStatePropertyAll(
                                            Colors.white),
                                  ),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            await Future.delayed(const Duration(seconds: 1));
                            showDialog(
                              context: context,
                              builder: (context) => MyResultDialog(
                                image: _selectedImage!,
                                label: label,
                              ),
                            );
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Error'),
                                content: Text('$e'),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                          Colors.blue[300]),
                                      foregroundColor:
                                          const WidgetStatePropertyAll(
                                              Colors.white),
                                    ),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[300], // background color
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Analyze',
                        style: TextStyle(fontSize: 20),
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
