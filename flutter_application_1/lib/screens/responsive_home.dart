import 'package:flutter/material.dart';

class ResponsiveHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    // Define breakpoints for responsive design
    bool isTablet = screenWidth > 600;
    bool isDesktop = screenWidth > 1200;
    
    return Scaffold(
      // Header Section - AppBar
      appBar: AppBar(
        title: Text(
          'Responsive Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        backgroundColor: Color(0xFF667eea),
        elevation: 2,
      ),
      
      body: SafeArea(
        child: LayoutBuilder(
          // LayoutBuilder provides constraints for more precise responsive control
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(context, isTablet),
                  
                  SizedBox(height: isTablet ? 32 : 24),
                  
                  // Main Content Area - Responsive Grid
                  _buildContentGrid(context, isTablet, isDesktop),
                  
                  SizedBox(height: isTablet ? 32 : 24),
                  
                  // Footer / Action Section
                  _buildActionSection(context, isTablet),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Welcome Section Widget
  Widget _buildWelcomeSection(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Artisan Connect',
            style: TextStyle(
              fontSize: isTablet ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Discover handcrafted products made with care and tradition',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // Responsive Content Grid
  Widget _buildContentGrid(
    BuildContext context,
    bool isTablet,
    bool isDesktop,
  ) {
    // Sample data for content cards
    List<Map<String, dynamic>> contentItems = [
      {
        'title': 'Handmade Products',
        'subtitle': 'Unique artisan crafts',
        'icon': Icons.handyman,
        'color': Color(0xFFFF6B6B),
      },
      {
        'title': 'Eco-Friendly',
        'subtitle': 'Sustainable materials',
        'icon': Icons.eco,
        'color': Color(0xFF4ECDC4),
      },
      {
        'title': 'Quality Assured',
        'subtitle': 'Premium craftsmanship',
        'icon': Icons.verified,
        'color': Color(0xFFFFE66D),
      },
      {
        'title': 'Fast Delivery',
        'subtitle': 'Quick shipping',
        'icon': Icons.local_shipping,
        'color': Color(0xFF95E1D3),
      },
    ];

    // Use GridView for tablets, Column for phones
    if (isTablet) {
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2, // 4 columns for desktop, 2 for tablet
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.1 : 1.2,
        ),
        itemCount: contentItems.length,
        itemBuilder: (context, index) {
          return _buildContentCard(
            context,
            contentItems[index],
            isTablet,
          );
        },
      );
    } else {
      // Single column layout for phones
      return Column(
        children: contentItems.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _buildContentCard(context, item, isTablet),
          );
        }).toList(),
      );
    }
  }

  // Content Card Widget
  Widget _buildContentCard(
    BuildContext context,
    Map<String, dynamic> item,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item['icon'],
              size: isTablet ? 48 : 40,
              color: item['color'],
            ),
          ),
          SizedBox(height: 16),
          Text(
            item['title'],
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            item['subtitle'],
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Footer / Action Section
  Widget _buildActionSection(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to explore our products?',
            style: TextStyle(
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          
          // Responsive button layout
          _buildResponsiveButtons(context, isTablet),
        ],
      ),
    );
  }

  // Responsive Button Layout
  Widget _buildResponsiveButtons(BuildContext context, bool isTablet) {
    // For tablets, show buttons in a row
    if (isTablet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              'Get Started',
              Color(0xFF667eea),
              () {
                // Navigation or action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Get Started clicked!')),
                );
              },
              isTablet,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              context,
              'Learn More',
              Colors.white,
              () {
                // Navigation or action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Learn More clicked!')),
                );
              },
              isTablet,
              isOutlined: true,
            ),
          ),
        ],
      );
    } else {
      // For phones, show buttons in a column
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              context,
              'Get Started',
              Color(0xFF667eea),
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Get Started clicked!')),
                );
              },
              isTablet,
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              context,
              'Learn More',
              Colors.white,
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Learn More clicked!')),
                );
              },
              isTablet,
              isOutlined: true,
            ),
          ),
        ],
      );
    }
  }

  // Action Button Widget
  Widget _buildActionButton(
    BuildContext context,
    String text,
    Color backgroundColor,
    VoidCallback onPressed,
    bool isTablet, {
    bool isOutlined = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutlined ? Colors.transparent : backgroundColor,
        foregroundColor: isOutlined ? Color(0xFF667eea) : Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 14,
          horizontal: isTablet ? 32 : 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isOutlined
              ? BorderSide(color: Color(0xFF667eea), width: 2)
              : BorderSide.none,
        ),
        elevation: isOutlined ? 0 : 4,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
