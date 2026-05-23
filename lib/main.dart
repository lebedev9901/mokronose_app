import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_gate.dart';
import 'product_details_screen.dart';
import 'services/api_service.dart';
import 'models/products.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: 'https://mokronos.ru/api',
    headers: {
      'Accept': 'application/json',
    },
  ),
);

const FlutterSecureStorage storage = FlutterSecureStorage();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  

  runApp(const MokronoseApp());
}

class MokronoseApp extends StatelessWidget {
  const MokronoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
class HomeScreen extends StatefulWidget {
  final VoidCallback? onLogout;

  const HomeScreen({
    super.key,
    this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 

  late Future<List<Product>> productsFuture;

  final Map<String, int> cart = {};

  @override
  void initState() {
    super.initState();
    productsFuture = ApiService.getProducts();
    
    loadCart();
   
  }

  Future<void> loadCart() async {
    final loadedCart = await ApiService.getCart();

    setState(() {
      cart.clear();
      cart.addAll(loadedCart);
    });
  }


  Future<void> addToCart(int productId) async {
    await ApiService.addToCart(productId);

    setState(() {
      final key = productId.toString();
      cart[key] = (cart[key] ?? 0) + 1;
    });
  }

  Future<void> removeFromCart(int productId) async {
    await ApiService.removeFromCart(productId);

    setState(() {
      final key = productId.toString();

      if ((cart[key] ?? 0) > 1) {
        cart[key] = cart[key]! - 1;
      } else {
        cart.remove(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'МокроНос',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Text(
                      'Лакомства для собак',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    hintText: 'Поиск товаров',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _BannerCard(text: 'Первый заказ - скидка 10%'),
                      _BannerCard(text: 'Новинки для питомцев'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Популярные товары',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                FutureBuilder<List<Product>>(
                  future: productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text('Ошибка: ${snapshot.error}');
                    }

                    final products = snapshot.data ?? [];

                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.60,
                      children: products.map((product) {
                        return ProductCard(
                          title: product.title,
                          price: '${product.price} ₽',
                          imageUrl: product.imageUrl,
                          rating: product.rating.toString(),
                          quantity: cart[product.id.toString()] ?? 0,
                          onAddToCart: () => addToCart(product.id),
                          onRemoveFromCart: () => removeFromCart(product.id),
                          onDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String text;

  const _BannerCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String rating;
  final int quantity;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;
  final String? imageUrl;
  final VoidCallback onDetails;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.quantity,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetails,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 150,
              child: Center(
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      )
                    : const Icon(
                        Icons.pets,
                        size: 90,
                        color: Colors.orange,
                      ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              price,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {},
              child: quantity > 0
                  ? Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: IconButton(
                              onPressed: onRemoveFromCart,
                              icon: const Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: IconButton(
                              onPressed: onAddToCart,
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: FilledButton(
                        onPressed: onAddToCart,
                        child: const Icon(Icons.shopping_cart_outlined),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}