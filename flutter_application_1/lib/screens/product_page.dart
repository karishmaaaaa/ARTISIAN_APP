import 'package:flutter/material.dart';

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
        title: Text("Artisan Connect"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.shopping_cart),
                SizedBox(width: 6),
                Text(cartCount.toString()),
              ],
            ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index]['name']!),
            subtitle: Text(products[index]['price']!),
            trailing: ElevatedButton(
              onPressed: addToCart,
              child: Text("Add"),
            ),
          );
        },
      ),
    );
  }
}
