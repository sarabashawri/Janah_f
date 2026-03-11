import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

/// FlaskApiService — Janah SAR System
///
/// Connects Flutter to the TypeFly Python Flask backend.
///
/// ← Change this IP to match the computer running TypeFly:
/// (must be on the same WiFi network)
class FlaskApiService {
  // ← Android emulator: 10.0.2.2 | Real device on WiFi: 192.168.1.9
  static String baseUrl = 'http://10.0.2.2:50000';

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
      'photo', // ← must match Flask's request.files['photo']
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
        await req.send().timeout(const Duration(minutes: 20));
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
  // Phase 3 — Chat (SSE stream)
  // ─────────────────────────────────────────────

  /// POST /chat
  ///
  /// Sends an Arabic instruction to the LLM controller.
  /// Returns a Stream of parsed SSE events until [DONE].
  ///
  /// Each event map has:
  ///   { 'type': 'text' | 'image' | 'code', 'content': '...' }
  static Stream<Map<String, dynamic>> sendCommand(String message) async* {
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse('$baseUrl/chat'));
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.headers['Accept'] = 'text/event-stream';
      request.body = jsonEncode({'message': message});

      final streamed = await client
          .send(request)
          .timeout(const Duration(seconds: 10));

      yield* _parseSSE(streamed.stream);
    } finally {
      client.close();
    }
  }

  // ─────────────────────────────────────────────
  // Phase 4 — Emergency Land
  // ─────────────────────────────────────────────

  /// POST /emergency-land
  ///
  /// Sends an immediate emergency landing command to the drone.
  /// Throws if the server is unreachable or returns an error.
  static Future<void> emergencyLand() async {
    await http
        .post(Uri.parse('$baseUrl/emergency-land'))
        .timeout(const Duration(seconds: 5));
  }

  // ─────────────────────────────────────────────
  // Phase 5 — Alert Stream (continuous SSE)
  // ─────────────────────────────────────────────

  /// GET /alerts
  ///
  /// Subscribes to the continuous alert SSE stream.
  /// Yields detection alerts (TARGET FOUND, NEEDS_REVIEW, etc.)
  /// as they arrive from the CV pipeline.
  ///
  /// The stream is long-lived — it stays open for the duration
  /// of the mission. Reconnects automatically if disconnected.
  static Stream<Map<String, dynamic>> alertStream() async* {
    while (true) {
      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse('$baseUrl/alerts'));
        request.headers['Accept'] = 'text/event-stream';
        request.headers['Cache-Control'] = 'no-cache';

        final streamed = await client
            .send(request)
            .timeout(const Duration(seconds: 10));

        yield* _parseSSE(streamed.stream);

        // If _parseSSE returns normally (stream ended), reconnect
        await Future.delayed(const Duration(seconds: 3));
      } catch (_) {
        // On any error, wait and reconnect
        client.close();
        await Future.delayed(const Duration(seconds: 3));
      } finally {
        client.close();
      }
    }
  }

  // ─────────────────────────────────────────────
  // Video Feed URL
  // ─────────────────────────────────────────────

  /// MJPEG live video feed URL from the drone camera.
  static String get videoFeedUrl => '$baseUrl/robot-pov/sim_tello';

  // ─────────────────────────────────────────────
  // Phase 6 — Target Confirmation
  // ─────────────────────────────────────────────

  /// POST /confirm-target
  static Future<void> confirmTarget() async {
    try {
      await http
          .post(Uri.parse('$baseUrl/confirm-target'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// POST /reject-target
  static Future<void> rejectTarget() async {
    try {
      await http
          .post(Uri.parse('$baseUrl/reject-target'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  /// POST /approve-plan
  static Future<void> approvePlan() async {
    try {
      await http
          .post(Uri.parse('$baseUrl/approve-plan'))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  // ─────────────────────────────────────────────
  // Private — SSE Parser
  // ─────────────────────────────────────────────

  /// Parses a raw HTTP byte stream into SSE events.
  ///
  /// - Buffers incomplete chunks
  /// - Ignores empty lines and events without 'data:'
  /// - Stops on data: [DONE]
  static Stream<Map<String, dynamic>> _parseSSE(
      Stream<List<int>> byteStream) async* {
    final buffer = StringBuffer();

    await for (final chunk in byteStream.transform(utf8.decoder)) {
      buffer.write(chunk);
      String text = buffer.toString();
      buffer.clear();

      // Process only complete SSE events (delimited by blank line \n\n)
      while (text.contains('\n\n')) {
        final idx = text.indexOf('\n\n');
        final event = text.substring(0, idx);
        text = text.substring(idx + 2);

        for (final line in event.split('\n')) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data: ')) continue;

          final data = trimmed.substring(6).trim();
          if (data.isEmpty) continue;
          if (data == '[DONE]') return;

          try {
            final parsed = jsonDecode(data);
            if (parsed is Map<String, dynamic>) yield parsed;
          } catch (_) {
            // Skip malformed events
          }
        }
      }

      // Keep any incomplete event in the buffer for the next chunk
      if (text.isNotEmpty) buffer.write(text);
    }
  }
}
