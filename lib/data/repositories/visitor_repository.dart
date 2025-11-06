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
  }) async {
    devLog(
      'Visitor Repository.createVisitor Called',
      params: {'name': name, 'phone': phone},
    );
    try {
      final photoUrl = await _cloudinary.uploadImage(photoFile);
      devLog('photoUploaded, URL obtained', params: {'photoUrl': photoUrl});

      final id = Uuid().v4();
      final visitor = Visitor(
        id: id,
        name: name,
        phone: phone,
        toMeet: toMeet,
        purpose: purpose,
        photoUrl: photoUrl,
        checkInTime: Timestamp.now(),
        status: 'pending',
      );
      await _firestore.collection('visitors').doc(id).set(visitor.toMap());
      devLog('Visitor Saved to Firestore', params: {'id': id});
    } catch (e) {
      devLog('createVisitor failed', params: {'error': e.toString()});
      rethrow;
    }
  }
}
