import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/products.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((item) {
        return Product.fromJson(item);
      }).toList();
    }

    throw Exception('Ошибка загрузки товаров');
  }
}