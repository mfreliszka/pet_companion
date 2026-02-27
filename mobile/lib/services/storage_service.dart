import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

/// Client for interacting with Cloudflare R2 via Cloud Functions.
///
/// Requests presigned URLs from Cloud Functions and performs
/// direct uploads to R2.
class StorageService {
  StorageService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFunctions _functions;

  // ── Presigned URL requests ────────────────────────────────────

  /// Request a presigned upload URL from the Cloud Function.
  ///
  /// [path] — Object key, e.g. `pets/{petId}/profile/{uuid}.jpg`
  /// [contentType] — MIME type, defaults to `image/jpeg`
  ///
  /// Returns `{ 'url': uploadUrl, 'key': storageKey }`.
  Future<Map<String, String>> requestUploadUrl({
    required String path,
    String contentType = 'image/jpeg',
  }) async {
    final callable = _functions.httpsCallable('generate_r2_upload_url');
    final result = await callable.call({
      'path': path,
      'contentType': contentType,
    });

    final data = Map<String, dynamic>.from(result.data as Map);
    return {'url': data['url'] as String, 'key': data['key'] as String};
  }

  /// Request a presigned download URL from the Cloud Function.
  ///
  /// [key] — Object key in R2.
  /// Returns the presigned GET URL.
  Future<String> requestDownloadUrl({required String key}) async {
    final callable = _functions.httpsCallable('generate_r2_download_url');
    final result = await callable.call({'key': key});
    final data = Map<String, dynamic>.from(result.data as Map);
    return data['url'] as String;
  }

  // ── Upload ────────────────────────────────────────────────────

  /// Upload bytes directly to R2 using a presigned PUT URL.
  Future<void> uploadBytes({
    required String uploadUrl,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final response = await http.put(
      Uri.parse(uploadUrl),
      headers: {'Content-Type': contentType},
      body: bytes,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'R2 upload failed: ${response.statusCode} ${response.reasonPhrase}',
      );
    }
  }

  // ── Full upload flow ──────────────────────────────────────────

  /// Convenience: request presigned URL, upload bytes, return the key.
  ///
  /// Returns the object key (use with [requestDownloadUrl] to get URL).
  Future<String> uploadFile({
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final urlData = await requestUploadUrl(
      path: path,
      contentType: contentType,
    );

    await uploadBytes(
      uploadUrl: urlData['url']!,
      bytes: bytes,
      contentType: contentType,
    );

    return urlData['key']!;
  }
}
