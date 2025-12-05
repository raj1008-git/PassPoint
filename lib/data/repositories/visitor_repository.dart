import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pass_point/core/utils/dev.log.dart';
import 'package:pass_point/data/models/visitor.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/services/face_detection_service.dart'; // NEW

class VisitorRepository {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinary;
  final FaceDetectionService _faceDetection; // NEW

  VisitorRepository({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinary,
    FaceDetectionService? faceDetection, // NEW
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _cloudinary = cloudinary ?? CloudinaryService(),
        _faceDetection = faceDetection ?? FaceDetectionService(); // NEW

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
    int numberOfVisitors = 1,
  }) async {
    devLog(
      'Visitor Repository.createVisitor Called',
      params: {
        'name': name,
        'phone': phone,
        'departmentId': departmentId,
        'departmentName': departmentName,
        'hasSignature': signatureFile != null,
        'numberOfVisitors': numberOfVisitors,
      },
    );
    try {
      // NEW - Extract face embedding before uploading
      devLog('Extracting face embedding from photo');
      final faceEmbedding = await _faceDetection.extractFaceEmbedding(photoFile);

      if (faceEmbedding != null) {
        devLog('Face embedding extracted successfully', params: {
          'embeddingLength': faceEmbedding.length
        });
      } else {
        devLog('Warning: No face detected in photo');
      }

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
        numberOfVisitors: numberOfVisitors,
        faceEmbedding: faceEmbedding, // NEW
      );
      await _firestore.collection('visitors').doc(id).set(visitor.toMap());
      devLog('Visitor Saved to Firestore', params: {'id': id, 'hasFaceEmbedding': faceEmbedding != null});
    } catch (e) {
      devLog('createVisitor failed', params: {'error': e.toString()});
      rethrow;
    }
  }

  // NEW - Search for matching face in database
  Future<Visitor?> findVisitorByFace(File photoFile, {double threshold = 75.0}) async {
    try {
      devLog('Searching for visitor by face');

      // Extract embedding from new photo
      final newEmbedding = await _faceDetection.extractFaceEmbedding(photoFile);
      if (newEmbedding == null) {
        devLog('No face detected in search photo');
        return null;
      }

      // Get all visitors with face embeddings
      final snapshot = await _firestore
          .collection('visitors')
          .where('faceEmbedding', isNull: false)
          .get();

      devLog('Found ${snapshot.docs.length} visitors with face embeddings');

      Visitor? bestMatch;
      double bestSimilarity = 0;

      for (var doc in snapshot.docs) {
        final visitor = Visitor.fromMap(doc.data());
        if (visitor.faceEmbedding == null) continue;

        final similarity = _faceDetection.calculateSimilarity(
          newEmbedding,
          visitor.faceEmbedding!,
        );

        devLog('Checking visitor: ${visitor.name}', params: {
          'similarity': similarity.toStringAsFixed(2),
        });

        if (similarity > bestSimilarity) {
          bestSimilarity = similarity;
          bestMatch = visitor;
        }
      }

      if (bestSimilarity >= threshold) {
        devLog('Match found!', params: {
          'visitor': bestMatch!.name,
          'similarity': bestSimilarity.toStringAsFixed(2),
        });
        return bestMatch;
      }

      devLog('No match found', params: {
        'bestSimilarity': bestSimilarity.toStringAsFixed(2),
        'threshold': threshold,
      });
      return null;
    } catch (e) {
      devLog('findVisitorByFace failed', params: {'error': e.toString()});
      return null;
    }
  }
}