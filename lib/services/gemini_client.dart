import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiClient {
  GeminiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<String>> listModels(String apiKey) async {
    debugPrint('GeminiClient: Modeller isteniyor... API Key uzunluğu: ${apiKey.length}');
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey',
    );
    
    try {
      final response = await _client.get(uri);
      debugPrint('GeminiClient: Model listesi yanıt kodu: ${response.statusCode}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('GeminiClient: Model listesi hatası: ${response.body}');
        throw Exception('Model listesi alınamadı: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final models = data['models'] as List<dynamic>?;
      if (models == null) {
        debugPrint('GeminiClient: Model listesi boş döndü.');
        return [];
      }

      final list = models
          .map((e) => e['name'] as String)
          .where((name) => name.contains('gemini'))
          .map((name) => name.replaceFirst('models/', ''))
          .toList();
      
      debugPrint('GeminiClient: Bulunan modeller: $list');
      return list;
    } catch (e) {
      debugPrint('GeminiClient: listModels Exception: $e');
      rethrow;
    }
  }

  Future<String> generateText({
    required String apiKey,
    required String prompt,
    String model = 'gemini-1.5-flash',
  }) async {
    debugPrint('GeminiClient: generateText çağrıldı. Model: $model');
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );
    
    try {
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
        }),
      );

      debugPrint('GeminiClient: generateText yanıt kodu: ${response.statusCode}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('GeminiClient: generateText hatası: ${response.body}');
        throw Exception('Gemini isteği başarısız: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        debugPrint('GeminiClient: Yanıt içinde candidate yok. Body: ${response.body}');
        throw Exception('Gemini yanıtı boş.');
      }
      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts == null || parts.isEmpty) {
        debugPrint('GeminiClient: Parts boş veya null.');
        throw Exception('Gemini yanıtı formatı hatalı.');
      }
      final text = parts.first['text'] as String?;
      if (text == null || text.trim().isEmpty) {
        debugPrint('GeminiClient: Yanıt metni boş. Body: ${response.body}');
        throw Exception('Gemini yanıtı okunamadı.');
      }
      return text.trim();
    } catch (e) {
      debugPrint('GeminiClient: generateText Exception: $e');
      rethrow;
    }
  }
}
