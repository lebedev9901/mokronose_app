import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/products.dart';

class ApiService {
  static const String baseUrl = 'https://mokronos.ru/api';
  // static const String baseUrl = 'https://127.0.0.1/api';

  static String? token;

  static Future<bool> login({
  required String email,
  required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['token'] == null) {
          print('TOKEN IS NULL');
          return false;
        }

        token = data['token'];

        return true;
      }

      throw Exception('STATUS ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('LOGIN ERROR: $e');
      return false;
    }
  }

  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Product.fromJson(item)).toList();
    }

    throw Exception('Ошибка загрузки товаров');
  }

  static Future<Map<String, int>> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final Map<String, int> cart = {};

      for (final item in data) {
        cart[item['product_id'].toString()] = item['qty'] ?? 0;
      }

      return cart;
    }

    throw Exception('Ошибка загрузки корзины');
  }

  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception('Ошибка загрузки корзины');
  }

  static Future<void> addToCart(int productId) async {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/add'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'product_id': productId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка добавления в корзину: ${response.statusCode}');
      }
    }

  static Future<void> removeFromCart(int productId) async {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/remove'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'product_id': productId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Ошибка удаления из корзины: ${response.statusCode}');
      }
    }

    static Future<Map<String, dynamic>?> getMe() async {
      if (token == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      if (response.statusCode == 401) {
        token = null;
        return null;
      }

      throw Exception('Ошибка загрузки профиля');
    }

    static Future<bool> register({
      required String lastName,
      required String firstName,
      required String middleName,
      required String email,
      required String password,
      required String passwordConfirmation,
    }) async {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'last_name': lastName,
          'first_name': firstName,
          'middle_name': middleName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      token = data['token'];
      return true;
    }

    return false;
  }

  
  static Future<List<Map<String, dynamic>>> getAddresses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/addresses'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }

    throw Exception('Ошибка загрузки адресов');
  }

  static Future<void> addAddress({
    required String city,
    required String street,
    required String house,
    String? apartment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addresses'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'city': city,
        'street': street,
        'house': house,
        'apartment': apartment,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Ошибка добавления адреса');
    }
  }

  static Future<void> deleteAddress(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/addresses/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка удаления адреса');
    }
  }

  static Future<bool> checkout({
  required String first_name,
  required String phone,
  required String deliveryMethod,
  required String paymentMethod,
  int? addressId,
  String? pickupPoint,
  String? cdekPoint,
  String? postAddress,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/checkout'),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'name': first_name,
      'phone': phone,
      'delivery_method': deliveryMethod,
      'payment_method': paymentMethod,
      'address_id': addressId,
      'pickup_point': pickupPoint,
      'cdek_point': cdekPoint,
      'post_address': postAddress,
    }),
  );

  return response.statusCode == 200;
}
static Future<List<Map<String, dynamic>>> getCategories() async {
  final response = await http.get(
    Uri.parse('$baseUrl/categories'),
    headers: {
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.cast<Map<String, dynamic>>();
  }

  throw Exception('Ошибка загрузки категорий');
}
}
