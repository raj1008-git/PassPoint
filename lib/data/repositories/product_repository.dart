import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/utils/dev.log.dart';
import '../../features/product/model/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinary;

  ProductRepository({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinary,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudinary = cloudinary ?? CloudinaryService();

  // Create product (delivery person submission)
  Future<void> createProduct({
    required String registrationNumber,
    required DateTime registrationDate,
    required String receivedLetterNumber,
    required DateTime receivedLetterDate,
    required String senderOfficeName,
    required String subject,
    required String targetDepartmentId,
    required String targetDepartmentName,
    required String targetPersonName,
    File? productPhoto,
    String? deliveryPersonName,
    String? deliveryPersonContact,
  }) async {
    try {
      devLog(
        'Creating product',
        params: {'registrationNumber': registrationNumber, 'subject': subject},
      );

      String? photoUrl;
      if (productPhoto != null) {
        photoUrl = await _cloudinary.uploadImage(
          productPhoto,
          folder: 'pass_point/products',
        );
      }

      final id = const Uuid().v4();
      final now = Timestamp.now();

      final product = ProductModel(
        id: id,
        registrationNumber: registrationNumber,
        registrationDate: Timestamp.fromDate(registrationDate),
        receivedLetterNumber: receivedLetterNumber,
        receivedLetterDate: Timestamp.fromDate(receivedLetterDate),
        senderOfficeName: senderOfficeName,
        subject: subject,
        targetDepartmentId: targetDepartmentId,
        targetDepartmentName: targetDepartmentName,
        targetPersonName: targetPersonName,
        productPhotoUrl: photoUrl,
        deliveryPersonName: deliveryPersonName,
        deliveryPersonContact: deliveryPersonContact,
        currentStatus: 'submitted',
        createdAt: now,
        currentDepartmentId: null,
        currentDepartmentName: null,
        currentPersonName: null,
        statusHistory: [
          {
            'status': 'submitted',
            'timestamp': now,
            'action': 'Product submitted for delivery',
            'performedBy': deliveryPersonName ?? 'Delivery Person',
          },
        ],
      );

      await _firestore.collection('products').doc(id).set(product.toMap());
      devLog('Product created successfully', params: {'id': id});
    } catch (e) {
      devLog('Error creating product', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Get all products stream (for receptionist)
  Stream<List<ProductModel>> getAllProductsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromSnapshot(doc))
              .toList();
        });
  }

  // Get products assigned to staff
  Stream<List<ProductModel>> getStaffProductsStream(String staffName) {
    return _firestore
        .collection('products')
        .where('currentPersonName', isEqualTo: staffName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ProductModel.fromSnapshot(doc))
              .toList();
        });
  }

  // Receptionist receives product
  Future<void> receiveByReception(
    String productId,
    String receptionistName,
  ) async {
    try {
      devLog('Reception receiving product', params: {'productId': productId});

      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) throw Exception('Product not found');

      final product = ProductModel.fromSnapshot(doc);
      final now = Timestamp.now();

      final updatedHistory = List<Map<String, dynamic>>.from(
        product.statusHistory,
      );
      updatedHistory.add({
        'status': 'received_by_reception',
        'timestamp': now,
        'action': 'Received by reception desk',
        'performedBy': receptionistName,
        'department': 'Reception',
      });

      await _firestore.collection('products').doc(productId).update({
        'currentStatus': 'received_by_reception',
        'currentDepartmentId': product.targetDepartmentId,
        'currentDepartmentName': product.targetDepartmentName,
        'currentPersonName': product.targetPersonName,
        'statusHistory': updatedHistory,
      });

      devLog('Product received by reception');
    } catch (e) {
      devLog('Error receiving product', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Staff forwards product
  Future<void> forwardProduct({
    required String productId,
    required String fromStaffName,
    required String fromDepartment,
    required String toDepartmentId,
    required String toDepartmentName,
    required String toPersonName,
    required String feedback,
  }) async {
    try {
      devLog('Forwarding product', params: {'productId': productId});

      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) throw Exception('Product not found');

      final product = ProductModel.fromSnapshot(doc);
      final now = Timestamp.now();

      final updatedHistory = List<Map<String, dynamic>>.from(
        product.statusHistory,
      );
      updatedHistory.add({
        'status': 'forwarded',
        'timestamp': now,
        'action': 'Forwarded to another department',
        'performedBy': fromStaffName,
        'fromDepartment': fromDepartment,
        'toDepartment': toDepartmentName,
        'toPerson': toPersonName,
        'feedback': feedback,
      });

      await _firestore.collection('products').doc(productId).update({
        'currentStatus': 'forwarded',
        'currentDepartmentId': toDepartmentId,
        'currentDepartmentName': toDepartmentName,
        'currentPersonName': toPersonName,
        'statusHistory': updatedHistory,
      });

      devLog('Product forwarded successfully');
    } catch (e) {
      devLog('Error forwarding product', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Staff completes product
  Future<void> completeProduct({
    required String productId,
    required String staffName,
    required String department,
    required String feedback,
    required String signatureUrl,
  }) async {
    try {
      devLog('Completing product', params: {'productId': productId});

      final doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) throw Exception('Product not found');

      final product = ProductModel.fromSnapshot(doc);
      final now = Timestamp.now();

      final updatedHistory = List<Map<String, dynamic>>.from(
        product.statusHistory,
      );
      updatedHistory.add({
        'status': 'completed',
        'timestamp': now,
        'action': 'Product received and completed',
        'performedBy': staffName,
        'department': department,
        'feedback': feedback,
        'signatureUrl': signatureUrl,
      });

      await _firestore.collection('products').doc(productId).update({
        'currentStatus': 'completed',
        'completedAt': now,
        'statusHistory': updatedHistory,
      });

      devLog('Product completed successfully');
    } catch (e) {
      devLog('Error completing product', params: {'error': e.toString()});
      rethrow;
    }
  }

  // Upload signature to Cloudinary
  Future<String> uploadSignature(File signatureFile) async {
    return await _cloudinary.uploadImage(
      signatureFile,
      folder: 'pass_point/product_signatures',
    );
  }
}
