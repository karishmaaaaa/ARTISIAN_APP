import 'package:flutter/material.dart';
import 'product_details.dart';
import 'about.dart';
import 'contact.dart';
import 'welcome.dart';

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Map<String, dynamic>> products = [
    {
      "name": "Handmade Pot",
      "price": "₹500",
      "images": [
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQC2Ko8h5MJJGf9BCNIr8QDz_ljJSME9qWLdQ&s",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQC2Ko8h5MJJGf9BCNIr8QDz_ljJSME9qWLdQ&s",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQC2Ko8h5MJJGf9BCNIr8QDz_ljJSME9qWLdQ&s",
      ],
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQC2Ko8h5MJJGf9BCNIr8QDz_ljJSME9qWLdQ&s",
      "description": "Beautiful handcrafted clay pot, perfect for home decoration. Made with traditional techniques and natural materials. Handmade, eco-friendly, artisan crafted."
    },
    {
      "name": "Wooden Craft",
      "price": "₹800",
      "images": [
        "https://www.shutterstock.com/image-photo/kalutara-sri-lanka-09-february-260nw-2428232213.jpg",
        "https://www.shutterstock.com/image-photo/kalutara-sri-lanka-09-february-260nw-2428232213.jpg",
        "https://www.shutterstock.com/image-photo/kalutara-sri-lanka-09-february-260nw-2428232213.jpg",
      ],
      "image":
          "https://www.shutterstock.com/image-photo/kalutara-sri-lanka-09-february-260nw-2428232213.jpg",
      "description": "Exquisite wooden craft item, carefully carved by skilled artisans. Each piece is unique and showcases traditional craftsmanship. Handmade, eco-friendly, artisan crafted."
    },
    {
      "name": "Clay Lamp",
      "price": "₹200",
      "images": [
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSNBaXNB5Z9B4c0gl27PQbAOEIZhIIhfUAJg&s",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSNBaXNB5Z9B4c0gl27PQbAOEIZhIIhfUAJg&s",
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSNBaXNB5Z9B4c0gl27PQbAOEIZhIIhfUAJg&s",
      ],
      "image":
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRSNBaXNB5Z9B4c0gl27PQbAOEIZhIIhfUAJg&s",
      "description": "Elegant clay lamp with intricate designs. Handmade with love and attention to detail, perfect for adding warmth to your space. Handmade, eco-friendly, artisan crafted."
    },
    {
      "name": "Handloom Hand Bags",
      "price": "₹1200",
      "images": [
        "https://via.placeholder.com/400x300/8B4513/FFFFFF?text=Handloom+Bag+1",
        "https://via.placeholder.com/400x300/8B4513/FFFFFF?text=Handloom+Bag+2",
        "https://via.placeholder.com/400x300/8B4513/FFFFFF?text=Handloom+Bag+3",
      ],
      "image":
          "https://via.placeholder.com/400x300/8B4513/FFFFFF?text=Handloom+Bag+1",
      "description": "Handwoven using traditional handloom techniques with eco-friendly fabrics. Durable, stylish, and unique for everyday use. Handmade, eco-friendly, artisan crafted."
    },
    {
      "name": "Palm Leaf Basket (Handmade)",
      "price": "₹650",
      "images": [
        "https://via.placeholder.com/400x300/228B22/FFFFFF?text=Palm+Basket+1",
        "https://via.placeholder.com/400x300/228B22/FFFFFF?text=Palm+Basket+2",
        "https://via.placeholder.com/400x300/228B22/FFFFFF?text=Palm+Basket+3",
      ],
      "image":
          "https://via.placeholder.com/400x300/228B22/FFFFFF?text=Palm+Basket+1",
      "description": "Handmade using natural palm leaves, woven by skilled artisans. Lightweight, sustainable, and perfect for storage or decor. Handmade, eco-friendly, artisan crafted."
    },
    {
      "name": "Decor Craft",
      "price": "₹900",
      "images": [
        "https://via.placeholder.com/400x300/CD853F/FFFFFF?text=Decor+Craft+1",
        "https://via.placeholder.com/400x300/CD853F/FFFFFF?text=Decor+Craft+2",
        "https://via.placeholder.com/400x300/CD853F/FFFFFF?text=Decor+Craft+3",
      ],
      "image":
          "https://via.placeholder.com/400x300/CD853F/FFFFFF?text=Decor+Craft+1",
      "description": "Artistic handcrafted decor made with natural materials. Designed to enhance home aesthetics with a traditional touch. Handmade, eco-friendly, artisan crafted."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Artisan Connect"),
        backgroundColor: Color(0xFF667eea),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.handyman_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Artisan Connect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => WelcomeScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_bag),
              title: Text('Products'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name and Price Header
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name']!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              product['price']!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF667eea),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsPage(
                                product: product,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF667eea),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text("View"),
                      ),
                    ],
                  ),
                ),
                // Multiple Product Images in Horizontal Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: List.generate(
                      (product['images'] as List<String>).length,
                      (imgIndex) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: imgIndex < (product['images'] as List<String>).length - 1 ? 8 : 0,
                          ),
                          child: _buildHoverableImage(
                            imageUrl: (product['images'] as List<String>)[imgIndex],
                            productName: product['name']!,
                            productPrice: product['price']!,
                            productDescription: product['description']!,
                            product: product,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHoverableImage({
    required String imageUrl,
    required String productName,
    required String productPrice,
    required String productDescription,
    required Map<String, dynamic> product,
  }) {
    return _HoverableImageWidget(
      imageUrl: imageUrl,
      productName: productName,
      productPrice: productPrice,
      productDescription: productDescription,
      product: product,
    );
  }
}

class _HoverableImageWidget extends StatefulWidget {
  final String imageUrl;
  final String productName;
  final String productPrice;
  final String productDescription;
  final Map<String, dynamic> product;

  _HoverableImageWidget({
    required this.imageUrl,
    required this.productName,
    required this.productPrice,
    required this.productDescription,
    required this.product,
  });

  @override
  _HoverableImageWidgetState createState() => _HoverableImageWidgetState();
}

class _HoverableImageWidgetState extends State<_HoverableImageWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsPage(
                product: widget.product,
                selectedImage: widget.imageUrl,
              ),
            ),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()
                ..scale(_isHovered ? 1.05 : 1.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: Offset(0, 5),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported, size: 40),
                    );
                  },
                ),
              ),
            ),
            // Hover Popup/Tooltip
            if (_isHovered)
              Positioned(
                top: -130,
                left: 0,
                right: 0,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.productName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.productPrice,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF667eea),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          widget.productDescription,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
