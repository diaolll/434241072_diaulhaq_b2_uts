import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase service wrapper for easy access
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current user
  static dynamic get currentUser => client.auth.currentUser;

  /// Get current session
  static Session? get currentSession => client.auth.currentSession;

  /// Check if user is logged in
  static bool get isLoggedIn => currentSession != null;

  /// Get current user ID
  static String? get currentUserId => currentUser?.id;

  // ==================== STORAGE ====================

  /// Upload file bytes to Supabase Storage
  static Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    try {
      await client.storage.from(bucket).uploadBinary(
        path,
        fileBytes,
        fileOptions: FileOptions(contentType: contentType, upsert: true),
      );

      // Return public URL after successful upload
      return client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      throw Exception('Storage upload failed: $e');
    }
  }

  /// Upload file from path
  static Future<String> uploadFileFromPath({
    required String bucket,
    required String path,
    required String filePath,
    String? contentType,
  }) async {
    final file = File(filePath);
    final response = await client.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );

    if (response.isEmpty) {
      return client.storage.from(bucket).getPublicUrl(path);
    } else {
      throw Exception('Upload failed: $response');
    }
  }

  /// Get public URL for a file
  static String getPublicUrl(String bucket, String path) {
    return client.storage.from(bucket).getPublicUrl(path);
  }

  /// Delete file from Supabase Storage
  static Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await client.storage.from(bucket).remove([path]);
  }
}
