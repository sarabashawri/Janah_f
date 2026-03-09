import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

/// FlaskApiService — Janah SAR System
///
/// Connects Flutter to the TypeFly Python Flask backend.
/// Phase 1 & 2: health check + mission setup only.
///
/// ← Change this IP to match the computer running TypeFly:
/// (must be on the same WiFi network)
class FlaskApiService {
  static String baseUrl = 'http://192.168.1.9:50000';

  // ─────────────────────────────────────────────
  // Phase 1 — Health Check
  // ─────────────────────────────────────────────

  /// GET /health
  /// Returns true if the Janah Flask server is reachable.
  /// Call this FIRST before any other method.
  static Future<bool> isHealthy() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Phase 2 — Mission Setup
  // ─────────────────────────────────────────────

  /// POST /upload-reference
  ///
  /// Fetches the missing child's report from Firestore, then uploads
  /// the reference photo + metadata to the Flask CV pipeline.
  ///
  /// Handles both field names used in Firestore:
  ///   Guardian reports  → 'description'
  ///   Rescuer reports   → 'extraDescription'
  static Future<Map<String, dynamic>> setupMission(String reportId) async {
    // 1. Fetch report from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('reports')
        .doc(reportId)
        .get();

    if (!doc.exists) {
      throw Exception('البلاغ غير موجود في قاعدة البيانات');
    }

    final report = doc.data()!;

    // 2. Decode base64 image → bytes
    final imageBase64 = (report['imageBase64'] as String?) ?? '';
    if (imageBase64.isEmpty) {
      throw Exception('لا توجد صورة مرجعية للطفل في البلاغ');
    }
    final bytes = base64Decode(imageBase64);

    // 3. Build multipart request
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-reference'),
    );

    // Attach image file
    req.files.add(http.MultipartFile.fromBytes(
      'file', // ← must match Flask's request.files['file']
      bytes,
      filename: 'child.jpg',
    ));

    // Attach metadata fields
    req.fields['name'] = (report['childName'] as String?) ?? '';
    req.fields['clothing_color'] = (report['clothingColor'] as String?) ?? '';
    // Handle both Guardian ('description') and Rescuer ('extraDescription')
    req.fields['description'] =
        ((report['description'] ?? report['extraDescription']) as String?) ?? '';

    // 4. Send and await response
    final streamedResponse =
        await req.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'فشل رفع بيانات الطفل (${response.statusCode}): ${response.body}');
    }
  }

  /// GET /get-reference-status
  ///
  /// Checks if FaceNet has finished processing the 80 augmented
  /// reference embeddings. Poll this after setupMission() until
  /// the returned map contains {'setup': true}.
  ///
  /// Example usage:
  /// ```dart
  /// while (true) {
  ///   final status = await FlaskApiService.getReferenceStatus();
  ///   if (status['setup'] == true) break;
  ///   await Future.delayed(Duration(seconds: 1));
  /// }
  /// ```
  static Future<Map<String, dynamic>> getReferenceStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/get-reference-status'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Return not-ready on any error; caller will retry
    }
    return {'setup': false};
  }

  // ─────────────────────────────────────────────
  // Phase 3+ — Commands (implement after Phase 1/2 succeed)
  // ─────────────────────────────────────────────

  /// POST /chat — send Arabic instruction, returns SSE stream
  /// (Implement in Phase 3)
  // static Stream<String> sendCommand(String message) { ... }

  /// GET /alerts — SSE stream of detection alerts
  /// (Implement in Phase 5)
  // static Stream<Map<String, dynamic>> alertStream() { ... }

  /// POST /emergency-land
  /// (Implement in Phase 4)
  // static Future<void> emergencyLand() { ... }

  /// POST /confirm-target
  /// (Implement in Phase 6)
  // static Future<void> confirmTarget() { ... }

  /// POST /reject-target
  /// (Implement in Phase 6)
  // static Future<void> rejectTarget() { ... }

  /// POST /approve-plan
  /// (Implement in Phase 6)
  // static Future<void> approvePlan() { ... }
}
