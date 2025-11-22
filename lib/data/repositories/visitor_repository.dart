import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pass_point/core/utils/dev.log.dart';
import 'package:pass_point/data/models/visitor.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/cloudinary_service.dart';

class VisitorRepository {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinary;

  VisitorRepository({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinary,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _cloudinary = cloudinary ?? CloudinaryService();

  Future<void> createVisitor({
    required String name,
    required String phone,
    String? email,
    required String toMeet,
    required String purpose,
    required File photoFile,
    File? signatureFile,
    String? departmentId,
    String? departmentName,
  }) async {
    devLog(
      'Visitor Repository.createVisitor Called',
      params: {
        'name': name,
        'phone': phone,
        'departmentId': departmentId,
        'departmentName': departmentName,
        'hasSignature': signatureFile != null,
      },
    );
    try {
      final photoUrl = await _cloudinary.uploadImage(photoFile);
      devLog('photoUploaded, URL obtained', params: {'photoUrl': photoUrl});

      String? signatureUrl;
      if (signatureFile != null) {
        signatureUrl = await _cloudinary.uploadImage(
          signatureFile,
          folder: 'pass_point/visitor_signatures',
        );
        devLog('signatureUploaded, URL obtained', params: {'signatureUrl': signatureUrl});
      }

      final id = Uuid().v4();
      final visitor = Visitor(
        id: id,
        name: name,
        phone: phone,
        email: email,
        toMeet: toMeet,
        purpose: purpose,
        photoUrl: photoUrl,
        signatureUrl: signatureUrl,
        checkInTime: Timestamp.now(),
        status: 'pending',
        departmentId: departmentId,
        departmentName: departmentName,
      );
      await _firestore.collection('visitors').doc(id).set(visitor.toMap());
      devLog('Visitor Saved to Firestore', params: {'id': id});
    } catch (e) {
      devLog('createVisitor failed', params: {'error': e.toString()});
      rethrow;
    }
  }
}