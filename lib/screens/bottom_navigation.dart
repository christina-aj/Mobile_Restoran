import 'package:flutter/material.dart';
import 'package:resto_app/screens/tenant/history_pesanan.dart';
import '../screens/tenant/home_resto.dart';
import '../screens/tenant/daftar_kasir.dart';
import '../screens/tenant/profile_tenant.dart';
import '../services/api_service.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ApiService apiService;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.apiService,
  }) : super(key: key);

  void _onNavTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeRestoScreen(apiService: apiService),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryPesananScreen(apiService: apiService),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DaftarKasirScreen(apiService: apiService),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileTenantScreen(apiService: apiService),
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
              icon: Icon(Icons.receipt_long),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Kasir',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
