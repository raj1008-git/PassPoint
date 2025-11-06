import 'dart:io';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pass_point/core/utils/dev.log.dart';

class CloudinaryService {
  final CloudinaryPublic _client;
  CloudinaryService._(this._client);

  factory CloudinaryService() {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
    devLog(
      'Cloudinary Service Initializing',
      params: {'cloud': cloudName, 'preset': uploadPreset.isNotEmpty},
    );
    final client = CloudinaryPublic(cloudName, uploadPreset, cache: false);
    return CloudinaryService._(client);
  }

  Future<String> uploadImage(
    File file, {
    String folder = 'pass_point/visitor_photos',
  }) async {
    try {
      devLog(
        'Uploading image to Cloudinary',
        params: {'filePath': file.path, 'folder': folder},
      );
      final response = await _client.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          folder: folder,
        ),
      );
      devLog(
        'Cloudinary upload success',
        params: {
          'secureUrl': response.secureUrl,
          'publicId': response.publicId,
        },
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      devLog(
        'CloudinaryException',
        params: {'message': e.message, 'request': e.request},
      );
      rethrow;
    } catch (e, st) {
      devLog(
        'Cloudinary Upload Failed',
        params: {'error': e.toString(), 'stackTrace': st.toString()},
      );
      throw Exception('Image upload failed: $e');
    }
  }
}
