import 'package:flutter/material.dart';
import 'models/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Товар'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: product.imageUrl != null
                ? Image.network(
                    product.imageUrl!,
                    height: 280,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 280,
                    color: Colors.orange.shade100,
                    child: const Icon(Icons.pets, size: 100),
                  ),
          ),

          const SizedBox(height: 20),

          Text(
            product.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange),
              const SizedBox(width: 6),
              Text(
                product.rating.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            '${product.price} ₽',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Добавить в корзину'),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Описание',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Описание товара скоро будет загружаться из Laravel API.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}