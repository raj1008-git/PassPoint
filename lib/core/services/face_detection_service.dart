import 'dart:io';
import 'dart:math';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../utils/dev.log.dart';

class FaceDetectionService {
  late final FaceDetector _faceDetector;

  FaceDetectionService() {
    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
      minFaceSize: 0.1, // Reduced for better detection at various distances
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
      final face = faces.reduce(
        (a, b) =>
            a.boundingBox.width * a.boundingBox.height >
                b.boundingBox.width * b.boundingBox.height
            ? a
            : b,
      );

      devLog(
        'Face detected',
        params: {
          'boundingBox': face.boundingBox.toString(),
          'headAngleY': face.headEulerAngleY,
          'headAngleZ': face.headEulerAngleZ,
        },
      );

      // Extract face features as embedding
      final embedding = _createEnhancedEmbedding(face);
      devLog('Face embedding created', params: {'length': embedding.length});

      return embedding;
    } catch (e) {
      devLog('Face detection error', params: {'error': e.toString()});
      return null;
    }
  }

  /// Create an enhanced embedding with normalized features
  List<double> _createEnhancedEmbedding(Face face) {
    final embedding = <double>[];

    // Get image dimensions for normalization
    final boxWidth = face.boundingBox.width;
    final boxHeight = face.boundingBox.height;
    final centerX = face.boundingBox.left + boxWidth / 2;
    final centerY = face.boundingBox.top + boxHeight / 2;

    // 1. Face size ratio (normalized) - invariant to distance
    final aspectRatio = boxWidth / boxHeight;
    embedding.add(aspectRatio);

    // 2. Head pose angles (normalized to -1 to 1 range)
    embedding.add(_normalizeAngle(face.headEulerAngleY ?? 0));
    embedding.add(_normalizeAngle(face.headEulerAngleZ ?? 0));

    // 3. Classification probabilities (already 0-1)
    embedding.add(face.smilingProbability ?? 0.5);
    embedding.add(face.leftEyeOpenProbability ?? 0.5);
    embedding.add(face.rightEyeOpenProbability ?? 0.5);

    // 4. Landmark positions (normalized relative to face center and size)
    final landmarks = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.leftCheek,
      FaceLandmarkType.rightCheek,
      FaceLandmarkType.leftMouth,
      FaceLandmarkType.rightMouth,
      FaceLandmarkType.bottomMouth,
      FaceLandmarkType.leftEar,
      FaceLandmarkType.rightEar,
    ];

    for (var landmarkType in landmarks) {
      final landmark = face.landmarks[landmarkType];
      if (landmark != null) {
        // Normalize relative to face bounding box center and size
        final relX = (landmark.position.x - centerX) / boxWidth;
        final relY = (landmark.position.y - centerY) / boxHeight;
        embedding.add(relX);
        embedding.add(relY);
      } else {
        embedding.add(0);
        embedding.add(0);
      }
    }

    // 5. Face contour distances (geometric features)
    final contours = face.contours;
    if (contours[FaceContourType.face] != null) {
      final facePoints = contours[FaceContourType.face]!.points;
      if (facePoints.length >= 4) {
        // Calculate key distances normalized by face size
        final topPoint = facePoints[facePoints.length ~/ 4];
        final bottomPoint = facePoints[3 * facePoints.length ~/ 4];
        final leftPoint = facePoints[0];
        final rightPoint = facePoints[facePoints.length ~/ 2];

        final faceLength = _distance(topPoint, bottomPoint) / boxHeight;
        final faceWidth = _distance(leftPoint, rightPoint) / boxWidth;

        embedding.add(faceLength);
        embedding.add(faceWidth);
      }
    }

    // 6. Eye distance ratio (distinctive feature)
    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];
    if (leftEye != null && rightEye != null) {
      final eyeDistance = _distance(leftEye.position, rightEye.position);
      final normalizedEyeDistance = eyeDistance / boxWidth;
      embedding.add(normalizedEyeDistance);
    } else {
      embedding.add(0.3); // Default average
    }

    devLog(
      'Enhanced embedding features',
      params: {
        'totalFeatures': embedding.length,
        'aspectRatio': aspectRatio.toStringAsFixed(3),
      },
    );

    return embedding;
  }

  /// Normalize angle from -180/180 to -1/1
  double _normalizeAngle(double angle) {
    return angle / 180.0;
  }

  /// Calculate Euclidean distance between two points
  double _distance(Point<int> p1, Point<int> p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Calculate similarity using COSINE SIMILARITY (better for face matching)
  double calculateSimilarity(List<double> embedding1, List<double> embedding2) {
    if (embedding1.length != embedding2.length) {
      devLog('Embedding length mismatch');
      return 0;
    }

    // Cosine similarity: dot product / (magnitude1 * magnitude2)
    double dotProduct = 0;
    double magnitude1 = 0;
    double magnitude2 = 0;

    for (int i = 0; i < embedding1.length; i++) {
      dotProduct += embedding1[i] * embedding2[i];
      magnitude1 += embedding1[i] * embedding1[i];
      magnitude2 += embedding2[i] * embedding2[i];
    }

    magnitude1 = sqrt(magnitude1);
    magnitude2 = sqrt(magnitude2);

    if (magnitude1 == 0 || magnitude2 == 0) {
      return 0;
    }

    // Cosine similarity ranges from -1 to 1, convert to 0-100%
    final cosineSim = dotProduct / (magnitude1 * magnitude2);
    final similarity = ((cosineSim + 1) / 2) * 100; // Normalize to 0-100

    devLog(
      'Similarity calculated',
      params: {
        'cosineSimilarity': cosineSim.toStringAsFixed(4),
        'percentage': similarity.toStringAsFixed(2),
      },
    );

    return similarity;
  }

  void dispose() {
    _faceDetector.close();
  }
}
