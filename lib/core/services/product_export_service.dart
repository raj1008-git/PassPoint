import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/dev.log.dart';
import '../../features/export/utils/file_writer.dart';

class ProductExportService {
  /// Export all products to CSV
  static Future<String> exportAllProducts() async {
    try {
      devLog('ProductExportService.exportAllProducts called');

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        return _flattenProductData(data);
      }).toList();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'products_export_$timestamp.csv';

      final path = await FileWriter.writeCsv(products, filename: filename);

      devLog('Products exported successfully', params: {'path': path});
      return path;
    } catch (e) {
      devLog(
        'ProductExportService.exportAllProducts error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Export products by status
  static Future<String> exportProductsByStatus(String status) async {
    try {
      devLog(
        'ProductExportService.exportProductsByStatus called',
        params: {'status': status},
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('currentStatus', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        return _flattenProductData(data);
      }).toList();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'products_${status}_$timestamp.csv';

      final path = await FileWriter.writeCsv(products, filename: filename);

      devLog('Products exported successfully', params: {'path': path});
      return path;
    } catch (e) {
      devLog(
        'ProductExportService.exportProductsByStatus error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Export products assigned to specific staff member
  static Future<String> exportStaffProducts(String staffName) async {
    try {
      devLog(
        'ProductExportService.exportStaffProducts called',
        params: {'staffName': staffName},
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('currentPersonName', isEqualTo: staffName)
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        return _flattenProductData(data);
      }).toList();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'my_products_$timestamp.csv';

      final path = await FileWriter.writeCsv(products, filename: filename);

      devLog('Staff products exported successfully', params: {'path': path});
      return path;
    } catch (e) {
      devLog(
        'ProductExportService.exportStaffProducts error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Export products within date range
  static Future<String> exportProductsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      devLog('ProductExportService.exportProductsByDateRange called');

      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        return _flattenProductData(data);
      }).toList();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename =
          'products_${startDate.day}_${startDate.month}_to_${endDate.day}_${endDate.month}_$timestamp.csv';

      final path = await FileWriter.writeCsv(products, filename: filename);

      devLog('Products exported successfully', params: {'path': path});
      return path;
    } catch (e) {
      devLog(
        'ProductExportService.exportProductsByDateRange error',
        params: {'error': e.toString()},
      );
      rethrow;
    }
  }

  /// Flatten product data for CSV export
  static Map<String, dynamic> _flattenProductData(Map<String, dynamic> data) {
    return {
      'Registration Number': data['registrationNumber'] ?? '',
      'Registration Date': data['registrationDate'],
      'Received Letter Number': data['receivedLetterNumber'] ?? '',
      'Received Letter Date': data['receivedLetterDate'],
      'Sender Office': data['senderOfficeName'] ?? '',
      'Subject': data['subject'] ?? '',
      'Target Department': data['targetDepartmentName'] ?? '',
      'Target Person': data['targetPersonName'] ?? '',
      'Current Status': data['currentStatus'] ?? '',
      'Current Department': data['currentDepartmentName'] ?? '',
      'Current Person': data['currentPersonName'] ?? '',
      'Delivery Person Name': data['deliveryPersonName'] ?? '',
      'Delivery Person Contact': data['deliveryPersonContact'] ?? '',
      'Product Photo URL': data['productPhotoUrl'] ?? '',
      'Created At': data['createdAt'],
      'Completed At': data['completedAt'],
      'Total Forwards':
          (data['statusHistory'] as List?)
              ?.where((h) => h['status'] == 'forwarded')
              .length ??
          0,
      'Last Action': (data['statusHistory'] as List?)?.isNotEmpty == true
          ? (data['statusHistory'] as List).last['action'] ?? ''
          : '',
      'Last Action By': (data['statusHistory'] as List?)?.isNotEmpty == true
          ? (data['statusHistory'] as List).last['performedBy'] ?? ''
          : '',
      'Last Action Date': (data['statusHistory'] as List?)?.isNotEmpty == true
          ? (data['statusHistory'] as List).last['timestamp']
          : '',
    };
  }
}
