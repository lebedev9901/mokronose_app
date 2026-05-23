import 'package:flutter/material.dart';
import 'models/products.dart';
import 'product_details_screen.dart';
import 'services/api_service.dart';
import 'main.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Product>> productsFuture;

  String search = '';
  Map<String, int> cart = {};

  List<Map<String, dynamic>> categories = [];
  int? activeCategoryId;
  int? activeSubcategoryId;

  @override
  void initState() {
    super.initState();
    productsFuture = ApiService.getProducts();
    loadCart();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await ApiService.getCategories();

    setState(() {
      categories = data;
    });
  }

  Future<void> loadCart() async {
    final data = await ApiService.getCart();

    setState(() {
      cart = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeCategory = activeCategoryId == null
        ? null
        : categories.firstWhere(
            (category) => category['id'] == activeCategoryId,
            orElse: () => {},
          );

    final subcategories = activeCategory == null || activeCategory.isEmpty
        ? []
        : activeCategory['children'] as List;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7EF),
      appBar: AppBar(
        title: const Text('Каталог'),
        backgroundColor: const Color(0xFFFFF7EF),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value.toLowerCase();
                });
              },
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
          ),

          if (categories.isNotEmpty) ...[
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isActive = activeCategoryId == null;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          activeCategoryId = null;
                          activeSubcategoryId = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.orange : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Text(
                          'Все товары',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }

                  final category = categories[index - 1];
                  final isActive = activeCategoryId == category['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        activeCategoryId = category['id'];
                        activeSubcategoryId = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        category['title'] ?? '',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (activeCategoryId != null && subcategories.isNotEmpty) ...[
              const SizedBox(height: 12),

              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: subcategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final subcategory = subcategories[index];
                    final isActive = activeSubcategoryId == subcategory['id'];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          activeSubcategoryId = subcategory['id'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.orange
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          subcategory['title'] ?? '',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 8),
          ],

          Expanded(
            child: FutureBuilder<List<Product>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = (snapshot.data ?? []).where((product) {
                final matchesSearch = product.title.toLowerCase().contains(search);

                if (!matchesSearch) {
                  return false;
                }

                if (activeCategoryId == null) {
                  return true;
                }

                if (activeSubcategoryId != null) {
                  return product.categoryId == activeSubcategoryId;
                }

                final subcategoryIds = subcategories
                    .map((item) => item['id'])
                    .toList();

                return product.categoryId == activeCategoryId ||
                    subcategoryIds.contains(product.categoryId);
              }).toList();

                if (products.isEmpty) {
                  return const Center(
                    child: Text('Товары не найдены'),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.55,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return ProductCard(
                      title: product.title,
                      price: '${product.price} ₽',
                      imageUrl: product.imageUrl,
                      rating: product.rating.toString(),
                      quantity: cart[product.id.toString()] ?? 0,
                      onAddToCart: () async {
                        await ApiService.addToCart(product.id);
                        await loadCart();
                      },
                      onRemoveFromCart: () async {
                        await ApiService.removeFromCart(product.id);
                        await loadCart();
                      },
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}