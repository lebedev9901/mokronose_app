import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<List<Map<String, dynamic>>> cartFuture;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  void loadCart() {
    cartFuture = ApiService.getCartItems();
  }

  Future<void> removeItem(int productId) async {
    await ApiService.removeFromCart(productId);

    setState(() {
      loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        title: const Text('Корзина'),
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Корзина пока пустая',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final total = items.fold<double>(
            0,
            (sum, item) => sum + double.parse(item['total'].toString()),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...items.map((item) {
                final productId = item['product_id'];
                final qty = item['qty'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: item['image_url'] != null
                            ? Image.network(
                                item['image_url'],
                                width: 64,
                                height: 64,
                                fit: BoxFit.contain,
                              )
                            : Container(
                                width: 64,
                                height: 64,
                                color: Colors.orange.shade100,
                                child: const Icon(Icons.pets),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] ?? 'Товар',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('${item['price']} ₽ × $qty'),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => removeItem(productId),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Итого',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '$total ₽',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );

                    if (result == true) {
                      setState(() {
                        loadCart();
                      });
                    }
                  },
                  child: const Text('Оформить заказ'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}