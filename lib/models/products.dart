class Product {
  final int id;
  final String title;
  final String price;
  final double rating;
  final String? imageUrl;
  final int? categoryId;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    
    
    return Product(
      id: json['id'],
      title: json['title'] ?? '',
      price: json['price'].toString(),
      rating: double.tryParse(json['rating'].toString()) ?? 0,
      imageUrl: json['image_url'], 
      categoryId: json['category_id'],
    );
  }
}