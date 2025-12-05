import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import '../utils/dev.log.dart';

class FaceDetectionService {
  late final FaceDetector _faceDetector;

  FaceDetectionService() {
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
      minFaceSize: 0.15,
      performanceMode: FaceDetectorMode.accurate,
    );
    _faceDetector = FaceDetector(options: options);
  }

  /// Detects faces and extracts embedding (feature vector)
  Future<List<double>?> extractFaceEmbedding(File imageFile) async {
    try {
      devLog('Starting face detection', params: {'path': imageFile.path});

      final inputImage = InputImage.fromFile(imageFile);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        devLog('No face detected in image');
        return null;
      }

      if (faces.length > 1) {
        devLog('Multiple faces detected, using the largest one');
      }

      // Use the largest face (most prominent)
      final face = faces.reduce((a, b) =>
      a.boundingBox.width * a.boundingBox.height >
          b.boundingBox.width * b.boundingBox.height ? a : b
      );

      devLog('Face detected', params: {
        'boundingBox': face.boundingBox.toString(),
        'confidence': face.headEulerAngleY,
      });

      // Extract face features as embedding
      final embedding = _createEmbedding(face);
      devLog('Face embedding created', params: {'length': embedding.length});

      return embedding;
    } catch (e) {
      devLog('Face detection error', params: {'error': e.toString()});
      return null;
    }
  }

  /// Create a simple embedding from face landmarks
  List<double> _createEmbedding(Face face) {
    final embedding = <double>[];

    // Bounding box features (normalized)
    embedding.add(face.boundingBox.left / 1000);
    embedding.add(face.boundingBox.top / 1000);
    embedding.add(face.boundingBox.width / 1000);
    embedding.add(face.boundingBox.height / 1000);

    // Head pose angles
    embedding.add(face.headEulerAngleY ?? 0);
    embedding.add(face.headEulerAngleZ ?? 0);

    // Classification probabilities
    embedding.add(face.smilingProbability ?? 0);
    embedding.add(face.leftEyeOpenProbability ?? 0);
    embedding.add(face.rightEyeOpenProbability ?? 0);

    // Landmarks (if available)
    final landmarks = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.leftMouth,
      FaceLandmarkType.rightMouth,
    ];

    for (var landmarkType in landmarks) {
      final landmark = face.landmarks[landmarkType];
      if (landmark != null) {
        embedding.add(landmark.position.x / 1000);
        embedding.add(landmark.position.y / 1000);
      } else {
        embedding.add(0);
        embedding.add(0);
      }
    }

    return embedding;
  }

  /// Calculate similarity between two embeddings (0-100%)
  double calculateSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      devLog('Embedding length mismatch');
      return 0;
    }

    // Euclidean distance
    double sum = 0;
    for (int i = 0; i < embedding1.length; i++) {
      sum += pow(embedding1[i] - embedding2[i], 2);
    }
    final distance = sqrt(sum);

    // Convert distance to similarity percentage (closer = higher similarity)
    // Typical distance range is 0-5, so we normalize
    final similarity = max(0, (1 - (distance / 5)) * 100);

    devLog('Similarity calculated', params: {'similarity': similarity.toStringAsFixed(2)});
    return similarity.toDouble();
  }

  void dispose() {
    _faceDetector.close();
  }
}