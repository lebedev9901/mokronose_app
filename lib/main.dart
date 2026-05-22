import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'auth_gate.dart';
import 'services/api_service.dart';
import 'models/products.dart';
void main() {
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

  const HomeScreen({super.key, this.onLogout,});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int activeCategoryIndex = 0;
  late Future<List<Product>> productsFuture;
  final Map<String, int> cart = {};

  void addToCart(String title) {
    setState(() {
      cart[title] = (cart[title] ?? 0) + 1;
    });
  }

  void removeFromCart(String title) {
    setState(() {
      if ((cart[title] ?? 0) > 1) {
        cart[title] = cart[title]! - 1;
      } else {
        cart.remove(title);
      }
    });
  }

  final categories = [
    {
      'name': 'Корма',
      'children': ['Сухой корм', 'Влажный корм', 'Для щенков'],
    },
    {
      'name': 'Игрушки',
      'children': ['Мячи', 'Канаты', 'Пищалки'],
    },
    {
      'name': 'Уход',
      'children': ['Шампуни', 'Расчёски', 'Когтерезы'],
    },
  ];

 

  @override
  void initState() {
    super.initState();
    productsFuture = ApiService.getProducts();
  }
  Widget build(BuildContext context) {

    final activeCategory = categories[activeCategoryIndex];
    final subcategories = activeCategory['children'] as List<String>;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // тут будет твоя шапка, поиск, баннер
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                    'МокроНос',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      'Лакоства для собак',
                      style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      ),
                    ), IconButton(
                      onPressed: widget.onLogout,
                      icon: const Icon(Icons.logout),
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
                      Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade200,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Первый заказ - скидка 10%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ),
                      Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade200,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Новинки для питомцев',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          )
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Категории
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final isActive = index == activeCategoryIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            activeCategoryIndex = index;
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
                            categories[index]['name'] as String,
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

                const SizedBox(height: 12),

                // Подкатегории активной категории
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: subcategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(subcategories[index]),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Популярные товары',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold
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
                        image: '🐶',
                        rating: product.rating.toString(),
                        quantity: cart[product.id.toString()] ?? 0,
                        onAddToCart: () => addToCart(product.id.toString()),
                        onRemoveFromCart: () => removeFromCart(product.id.toString()),
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
class ProductCard extends StatelessWidget{
    final String title;
    final String price;
    final String image;
    final String rating;
    final int quantity;
    final VoidCallback onAddToCart;
    final VoidCallback onRemoveFromCart;

    const ProductCard({
      super.key,
      required this.title,
      required this.price,
      required this.image,
      required this.rating,
      required this.quantity,
      required this.onAddToCart,
      required this.onRemoveFromCart,
    });

    @override
    Widget build(BuildContext context){
      return Container(
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
                child: Text(
                  image,
                  style: const TextStyle(fontSize: 110),
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
                  style:  const TextStyle(fontSize: 13),
                ),
              ],
              ),

            const SizedBox(height: 6),

            Text(
              price,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [

                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: FilledButton(
                      onPressed: onAddToCart,
                      child: 
                      quantity > 0
                      ? Container(
                          height: 38,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: IconButton(
                                  onPressed: onRemoveFromCart,
                                  icon: const Icon(Icons.remove, color: Colors.white, size: 18),
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
                                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
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
                  ),
                ),
              ],
            ),
          ],
        ),
        
        );
    }
  }
