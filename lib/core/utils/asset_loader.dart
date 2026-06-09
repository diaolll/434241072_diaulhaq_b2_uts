import 'dart:convert';
import 'package:flutter/services.dart';

/// Helper class for loading assets from the assets folder
class AssetLoader {
  AssetLoader._();

  /// Load a JSON file from assets and return the decoded data
  ///
  /// Usage:
  /// ```dart
  /// final config = await AssetLoader.loadJson('assets/data/config.json');
  /// ```
  static Future<Map<String, dynamic>> loadJson(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load JSON from $path: $e');
    }
  }

  /// Load a JSON file from assets and return a list
  ///
  /// Usage:
  /// ```dart
  /// final items = await AssetLoader.loadJsonList('assets/data/items.json');
  /// ```
  static Future<List<dynamic>> loadJsonList(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString) as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load JSON list from $path: $e');
    }
  }

  /// Load a text file from assets
  ///
  /// Usage:
  /// ```dart
  /// final content = await AssetLoader.loadText('assets/data/readme.txt');
  /// ```
  static Future<String> loadText(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      throw Exception('Failed to load text from $path: $e');
    }
  }

  /// Load image data from assets
  ///
  /// Usage:
  /// ```dart
  /// final bytes = await AssetLoader.loadImage('assets/images/background.png');
  /// ```
  static Future<ByteData> loadImage(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (e) {
      throw Exception('Failed to load image from $path: $e');
    }
  }
}
