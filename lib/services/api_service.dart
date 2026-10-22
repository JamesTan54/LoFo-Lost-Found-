import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_item_model.dart';

class ApiService {
  final http.Client client;
  final String baseUrl;

  ApiService({required this.client, this.baseUrl = 'https://api.example.com'});

  Future<List<ApiItemModel>> fetchItems() async {
    final response = await client.get(Uri.parse('$baseUrl/items'));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> body = json.decode(response.body);
        return body.map((dynamic item) => ApiItemModel.fromJson(item)).toList();
      } catch (e) {
        throw const FormatException('JSON Corrupt / Parsing Error');
      }
    } else {
      throw Exception('HTTP Error: ${response.statusCode}');
    }
  }
}