import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../bottom_navigation.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileTenantScreen extends StatefulWidget {
  final ApiService apiService;

  const ProfileTenantScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<ProfileTenantScreen> createState() => _ProfileTenantScreenState();
}

class _ProfileTenantScreenState extends State<ProfileTenantScreen> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  String _errorMessage = '';

  // Email pemilik aplikasi untuk bantuan
  static const String supportEmail = 'support@aplikasikasir.com';
  static const String supportPhone = '+6281234567890';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userInfo = await widget.apiService.getUserInfo();

      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });

      print('User info loaded: $userInfo');
    } catch (e) {
      print('Error loading user info: $e');

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });

      if (e.toString().contains('Token expired') ||
          e.toString().contains('Token tidak tersedia')) {
        _handleLogout();
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.apiService.clearToken();

      if (!mounted) return;

      // Navigate to login screen and clear all routes
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
            (route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout berhasil'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error during logout: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleBantuan() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hubungi Kami',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pilih metode untuk menghubungi tim support kami',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Email
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.email_outlined, color: Colors.blue),
              ),
              title: const Text('Email Support'),
              subtitle: Text(supportEmail),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse('mailto:$supportEmail?subject=Bantuan Aplikasi Kasir');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tidak dapat membuka aplikasi email'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),

            const Divider(height: 32),

            // WhatsApp
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.phone_outlined, color: Colors.green),
              ),
              title: const Text('WhatsApp'),
              subtitle: Text(supportPhone),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                Navigator.pop(context);
                final message = Uri.encodeComponent('Halo, saya butuh bantuan dengan aplikasi kasir');
                final uri = Uri.parse('https://wa.me/$supportPhone?text=$message');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tidak dapat membuka WhatsApp'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserInfo,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'PROFIL TOKO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Profile Image
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  width: 120,
                  height: 120,
                  color: Colors.blue.shade100,
                  child: Icon(
                    Icons.restaurant,
                    size: 60,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Nama Toko
              Text(
                _userInfo?['nama'] ?? _userInfo?['name'] ?? 'N/A',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                (_userInfo?['role'] ?? 'N/A').toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 32),

              // User Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _userInfo?['email'] ?? 'N/A',
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      icon: Icons.store_outlined,
                      label: 'ID Tenant',
                      value: _userInfo?['id_tenant']?.toString() ?? 'N/A',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Riwayat / History
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur riwayat belum tersedia'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.history, color: Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        'Riwayat / History',
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              // Bantuan
              InkWell(
                onTap: _handleBantuan,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.phone_outlined, color: Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        'Bantuan',
                        style: TextStyle(fontSize: 16),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              // Logout
              InkWell(
                onTap: _handleLogout,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.red),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 3,
        apiService: widget.apiService,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}