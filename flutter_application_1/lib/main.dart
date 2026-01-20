import 'package:flutter/material.dart';

void main() {
  runApp(ArtisanApp());
}

class ArtisanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artisan Connect',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: ProductPage(),
    );
  }
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int cartCount = 0;

  List<Map<String, String>> products = [
    {
      "name": "Handmade Pot",
      "price": "₹500",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQC2Ko8h5MJJGf9BCNIr8QDz_ljJSME9qWLdQ&s"
    },
    {
      "name": "Wooden Craft",
      "price": "₹800",
      "image":
          "https://www.shutterstock.com/image-photo/kalutara-sri-lanka-09-february-260nw-2428232213.jpg"
    },
    {
      "name": "Clay Lamp",
      "price": "₹200",
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSNBaXNB5Z9B4c0gl27PQbAOEIZhIIhfUAJg&s"
    }
  ];

  void addToCart() {
    setState(() {
      cartCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Artisan_Connect", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.orange[600],
        elevation: 8,
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.orange[700]),
                  SizedBox(width: 8),
                  Text(cartCount.toString(),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[700])),
                ],
              ),
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange[50]!, Colors.yellow[100]!],
          ),
        ),
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(
              name: products[index]['name']!,
              price: products[index]['price']!,
              image: products[index]['image']!,
              onAdd: addToCart,
              color: [Colors.blue, Colors.purple, Colors.green][index],
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String name;
  final String price;
  final String image;
  final VoidCallback onAdd;
  final Color color;

  ProductCard(
      {required this.name,
      required this.price,
      required this.image,
      required this.onAdd,
      required this.color});

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
      },
      child: Card(
        margin: EdgeInsets.all(12),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color.withOpacity(0.1), widget.color.withOpacity(0.3)],
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Image.network(widget.image, height: 200, width: double.infinity, fit: BoxFit.cover),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, widget.color.withOpacity(0.3)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(widget.name,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: widget.color)),
              SizedBox(height: 8),
              Text(widget.price,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[700])),
              SizedBox(height: 16),
              ScaleTransition(
                scale: Tween(begin: 1.0, end: 0.95).animate(_controller),
                child: ElevatedButton.icon(
                  onPressed: widget.onAdd,
                  icon: Icon(Icons.shopping_cart_checkout),
                  label: Text("Add to Cart", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
