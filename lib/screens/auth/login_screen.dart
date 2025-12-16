import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../tenant/home_resto.dart';
import '../kasir/home_kasir.dart';
import '../auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting login process...');

      // Step 1: Login untuk mendapatkan token
      final loginResult = await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('Login successful, token received');

      if (!mounted) return;

      // Step 2: Ambil user info untuk mendapatkan role
      print('Fetching user info...');
      final userInfo = await _apiService.getUserInfo();

      print('User info received: $userInfo');

      if (!mounted) return;

      // Ambil role dari userInfo
      final role = userInfo['role']?.toString().toLowerCase().trim() ?? '';
      final userName = userInfo['nama']?.toString() ?? userInfo['name']?.toString() ?? userInfo['email']?.toString() ?? 'User';
      final idTenant = userInfo['id_tenant']?.toString() ?? '';

      print('=== DEBUG LOGIN ===');
      print('User role from API: "$role"');
      print('User name: $userName');
      print('ID Tenant: $idTenant');
      print('Role type: ${userInfo['role'].runtimeType}');
      print('==================');

      // Validasi role tidak kosong
      if (role.isEmpty) {
        throw Exception('Role tidak ditemukan dalam response');
      }

      // Tampilkan success message dengan role info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login berhasil sebagai $role! Selamat datang $userName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Delay sebentar
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate berdasarkan role dengan pengecekan yang lebih spesifik
      print('Checking role for navigation: "$role"');

      if (role == 'kasir') {
        // Role Kasir -> ke HomeKasirScreen
        print('Navigating to HomeKasirScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeKasirScreen(apiService: _apiService),
          ),
        );
      } else if (role == 'tenant' || role == 'resto' || role == 'owner') {
        // Role Tenant -> ke HomeRestoScreen
        print('Navigating to HomeRestoScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeRestoScreen(apiService: _apiService),
          ),
        );
      } else {
        // Role tidak dikenali
        print('WARNING: Unknown role: "$role"');
        throw Exception('Role "$role" tidak dikenali. Hubungi administrator.');
      }

    } catch (e) {
      print('Login failed: $e');

      if (!mounted) return;

      // Login gagal
      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: $errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Logo atau Icon
                const Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 60),

                // Title
                const Text(
                  'Masuk ke Akun Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey.shade600),
                    filled: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue.shade400, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade600),
                    filled: false,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // // Forgot Password
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: TextButton(
                //     onPressed: _isLoading ? null : () {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text('Fitur reset password belum tersedia'),
                //         ),
                //       );
                //     },
                //     style: TextButton.styleFrom(
                //       padding: EdgeInsets.zero,
                //       minimumSize: const Size(0, 0),
                //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //     ),
                //     child: const Text(
                //       'Lupa Password? Reset Sekarang',
                //       style: TextStyle(
                //         fontSize: 13,
                //         color: Colors.blue,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Colors.blue.shade300,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Tidak Punya Akun? ",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}