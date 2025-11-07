import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:pass_point/core/utils/dev.log.dart';
import 'package:path_provider/path_provider.dart';

class FileWriter {
  static Future<String> writeCsv(
    List<Map<String, dynamic>> rows, {
    required String filename,
  }) async {
    try {
      devLog('FileWriter.writecsv called', params: {'rows': rows.length});

      final headerSet = <String>{};
      for (final r in rows) headerSet.addAll(r.keys);
      final headers = headerSet.toList();

      final csvRows = <List<dynamic>>[];
      csvRows.add(headers);

      for (final r in rows) {
        csvRows.add(
          headers.map((h) {
            final v = r[h];
            if (v == null) return '';
            if (v is Map || v is List) return jsonEncode(v);
          }).toList(),
        );
      }

      final csvStr = const ListToCsvConverter().convert(csvRows);

      final dir = await _getStorageDir();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(csvStr);
      devLog('CSV written Successfully', params: {'path': file.path});
      return file.path;
    } catch (e) {
      devLog('File Writer.writecsv error', params: {'error': e.toString()});
      rethrow;
    }
  }

  static Future<String> writeJson(
    List<Map<String, dynamic>> rows, {
    required String filename,
  }) async {
    try {
      devLog('File Writer.write json called');
      final dir = await _getStorageDir();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(jsonEncode(rows));
      devLog('JSON written Successfully', params: {'path': file.path});
      return file.path;
    } catch (e) {
      devLog('File Writer.write json error', params: {'error': e.toString()});
      rethrow;
    }
  }

  static Future<Directory> _getStorageDir() async {
    try {
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext;
    } catch (e) {
      devLog(
        'File Writer.getStorageDir error and Falling back to documents directory',
        params: {'error': e.toString()},
      );
      rethrow;
    }
    return await getApplicationDocumentsDirectory();
  }
}
