import 'package:flutter/material.dart';
import 'screens/welcome.dart';

void main() {
  runApp(ArtisanApp());
}

class ArtisanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Artisan Connect',
      home: WelcomeScreen(),
    );
  }
}
