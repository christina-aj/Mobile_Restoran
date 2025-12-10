import 'package:flutter/material.dart';
import '../screens/kasir/home_kasir.dart';
import '../screens/kasir/cart_screen.dart';
import '../screens/kasir/order_list_screen.dart';
import '../services/api_service.dart';

class CustomBottomNavKasir extends StatelessWidget {
  final int currentIndex;
  final ApiService apiService;

  const CustomBottomNavKasir({
    Key? key,
    required this.currentIndex,
    required this.apiService,
  }) : super(key: key);

  void _onNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
      // Home Kasir
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeKasirScreen(apiService: apiService),
          ),
        );
        break;
      case 1:
      // Keranjang
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CartScreen(apiService: apiService),
          ),
        );
        break;
      case 2:
      // Daftar Pesanan
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderListScreen(apiService: apiService),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onNavTap(context, index),
          backgroundColor: Colors.blue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Keranjang',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: 'Pesanan',
            ),
          ],
        ),
      ),
    );
  }
}