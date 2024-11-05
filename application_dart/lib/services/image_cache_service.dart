import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ImageCacheService {
  static const _imageKey = 'no_internet_image';

  // Download image and save it to SharedPreferences
  Future<void> downloadAndCacheImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_imageKey)) {
      final response = await http.get(Uri.parse(
          'https://media.istockphoto.com/id/1336657186/es/vector/sin-vector-plano-wi-fi.jpg?s=612x612&w=0&k=20&c=26bnFnfOgpogS2bQwCso2q3bB_gmZZ-K-ZHzvvG4d1w='));
      if (response.statusCode == 200) {
        String base64Image = base64Encode(response.bodyBytes);
        await prefs.setString(_imageKey, base64Image);
      }
    }
  }

  // Retrieve image from cache
  Future<Uint8List?> getCachedImage() async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString(_imageKey);
    if (base64Image != null) {
      return base64Decode(base64Image);
    }
    return null;
  }
}
