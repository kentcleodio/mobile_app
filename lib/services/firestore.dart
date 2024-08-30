import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirestoreService {
  final CollectionReference logs = FirebaseFirestore.instance.collection('Log');
  final CollectionReference result =
      FirebaseFirestore.instance.collection('Disease');

  Future<void> addLog(String log, String imageUrl) {
    return logs.add({
      'ImageUrl': imageUrl,
      'Result': log,
      'Timestamp': Timestamp.now(),
    });
  }

  Future<String> uploadImage(File image) async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDir = referenceRoot.child('images');
    Reference referenceImageUpload = referenceDir.child(fileName);
    try {
      await referenceImageUpload.putFile(File(image.path));
      String imageUrl = await referenceImageUpload.getDownloadURL();
      return imageUrl;
    } catch (error) {
      throw Exception('Error uploading image: $error');
    }
  }

  Future<DocumentSnapshot> getDiseaseData(String diseaseName) {
    return result.doc(diseaseName).get();
  }
}
