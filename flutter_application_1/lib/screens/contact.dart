import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'welcome.dart';
import 'product_page.dart';
import 'about.dart';

class ContactPage extends StatelessWidget {
  final String whatsappNumber = "+1234567890"; // Replace with actual number
  final String email = "contact@artisanconnect.com"; // Replace with actual email

  Future<void> _launchWhatsApp(BuildContext context) async {
    // Use WhatsApp web for better web compatibility
    final whatsappUrl = 'https://web.whatsapp.com/send?phone=$whatsappNumber';
    
    try {
      final uri = Uri.parse(whatsappUrl);
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      // Fallback: try wa.me
      try {
        final fallbackUrl = 'https://wa.me/$whatsappNumber';
        final uri = Uri.parse(fallbackUrl);
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e2) {
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open WhatsApp. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Contact from Artisan Connect',
    );
    
    try {
      await launchUrl(emailUri, mode: LaunchMode.platformDefault);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open email client. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Us"),
        backgroundColor: Color(0xFF667eea),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF667eea).withOpacity(0.1),
                  border: Border.all(
                    color: Color(0xFF667eea),
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.contact_support_rounded,
                  size: 60,
                  color: Color(0xFF667eea),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "Get in Touch",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667eea),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "We'd love to hear from you!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            // WhatsApp Card
            _buildContactCard(
              icon: Icons.chat,
              title: "WhatsApp",
              subtitle: "Chat with us on WhatsApp",
              color: Color(0xFF25D366),
              onTap: () => _launchWhatsApp(context),
            ),
            SizedBox(height: 20),
            // Email Card
            _buildContactCard(
              icon: Icons.email,
              title: "Email",
              subtitle: email,
              color: Color(0xFF667eea),
              onTap: () => _launchEmail(context),
            ),
            SizedBox(height: 40),
            // Additional Info
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF667eea).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFF667eea).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF667eea),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Contact Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Feel free to reach out to us through WhatsApp or email. We typically respond within 24 hours.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProductPage()),
              );
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
            },
          ),
        ],
      ),
    );
  }
}
