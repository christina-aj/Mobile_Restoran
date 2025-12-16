import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../bottom_navigation_kasir.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';

class HomeKasirScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeKasirScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<HomeKasirScreen> createState() => _HomeKasirScreenState();
}

class _HomeKasirScreenState extends State<HomeKasirScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _listBarang = [];
  List<dynamic> _filteredBarang = [];
  bool _isLoading = false;
  String _errorMessage = '';

  String _tenantName = 'Loading...';
  String _cashierName = 'Loading...';
  String? _tenantId;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadUserAndTenantInfo();
    await _loadBarang();
  }

  Future<void> _loadUserAndTenantInfo() async {
    try {
      final userInfo = await widget.apiService.getUserInfo();
      if (mounted) {
        setState(() {
          _tenantId = userInfo['id_tenant']?.toString();
          _cashierName = userInfo['nama'] ?? userInfo['name'] ?? userInfo['email'] ?? 'Kasir';
        });
      }
      if (_tenantId != null && _tenantId!.isNotEmpty) {
        final tenantInfo = await widget.apiService.getTenantById(_tenantId!);
        if (mounted) {
          setState(() {
            _tenantName = tenantInfo['nama_tenant'] ?? '-';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _tenantName = 'Tenant';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat info: ${e.toString()}';
          _tenantName = 'Error';
          _cashierName = 'Error';
        });
      }
    }
  }

  Future<void> _loadBarang() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await widget.apiService.getBarangByTenant();
      if (mounted) {
        setState(() {
          _listBarang = data;
          _filteredBarang = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredBarang = _listBarang;
      } else {
        _filteredBarang = _listBarang.where((barang) {
          final namaBarang = (barang['nama_barang'] ?? '').toLowerCase();
          final kategori = (barang['kategori'] ?? '').toLowerCase();
          return namaBarang.contains(query) || kategori.contains(query);
        }).toList();
      }
    });
  }

  String _formatRupiah(dynamic harga) {
    try {
      final angka = double.tryParse(harga.toString()) ?? 0;
      return 'Rp${angka.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
      )}';
    } catch (e) {
      return 'Rp0';
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
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
            (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout berhasil'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logout: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.person_outline, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _tenantName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Kasir : $_cashierName',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartScreen(apiService: widget.apiService),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.blue),
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${cartProvider.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Logout'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Nama Menu',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data...'),
                ],
              ),
            )
                : _errorMessage.isNotEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi Kesalahan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _initializeData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
                : _filteredBarang.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchController.text.isNotEmpty
                        ? Icons.search_off
                        : Icons.restaurant_menu,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isNotEmpty
                        ? 'Menu tidak ditemukan'
                        : 'Belum ada menu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
            :ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _filteredBarang.length,
              itemBuilder: (context, index) {
                final barang = _filteredBarang[index];
                final idBarang = barang['id_barang']?.toString() ?? '';
                final namaBarang = barang['nama_barang'] ?? 'Tidak ada nama';
                final hargaRaw = barang['harga_default'] ?? 0;
                final harga = (hargaRaw is int)
                    ? hargaRaw
                    : (double.tryParse(hargaRaw.toString())?.toInt() ?? 0);
                final kategori = barang['kategori'] ?? '';
                final foto = barang['foto'];
                final deskripsi = barang['deskripsi'] ?? '-';

                return Card(
                  key: ValueKey('item_$idBarang'),
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // FOTO MENU
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: barang['foto'] != null && barang['foto'] != ''
                                  ? Image.network(
                                    barang['foto'],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.grey.shade300,
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey.shade700,
                                        ),
                                      );
                                    },
                                  )
                                  : Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey.shade300,
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                            ),
                            const SizedBox(width: 12),

                            // INFO MENU
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    namaBarang,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatRupiah(harga),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    deskripsi,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (kategori.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        kategori,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // TOMBOL QUANTITY
                        _QuantityButtonRow(
                          idBarang: idBarang,
                          namaBarang: namaBarang,
                          harga: harga,
                          kategori: kategori,
                          foto: foto,
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavKasir(
        currentIndex: 0,
        apiService: widget.apiService,
      ),
    );
  }
}

class _QuantityButtonRow extends StatefulWidget {
  final String idBarang;
  final String namaBarang;
  final int harga;
  final String? kategori;
  final String? foto;
  final String? deskripsi;

  const _QuantityButtonRow({
    required this.idBarang,
    required this.namaBarang,
    required this.harga,
    this.kategori,
    this.foto,
    this.deskripsi,
  });

  @override
  State<_QuantityButtonRow> createState() => _QuantityButtonRowState();
}

class _QuantityButtonRowState extends State<_QuantityButtonRow> {
  void _handleMinus() {
    final cartProvider = context.read<CartProvider>();
    final quantity = cartProvider.getQuantity(widget.idBarang);
    if (quantity > 0) {
      cartProvider.decrementQuantity(widget.idBarang);
      cartProvider.printCart();
    }
  }

  void _handlePlus() {
    final cartProvider = context.read<CartProvider>();
    final quantity = cartProvider.getQuantity(widget.idBarang);
    if (quantity == 0) {
      cartProvider.addItem(
        idBarang: widget.idBarang,
        namaBarang: widget.namaBarang,
        harga: widget.harga,
        kategori: widget.kategori,
        foto: widget.foto,
        deskripsi: widget.deskripsi,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.namaBarang} ditambahkan'),
          duration: const Duration(milliseconds: 500),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      cartProvider.incrementQuantity(widget.idBarang);
    }
    cartProvider.printCart();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<CartProvider, int>(
      selector: (_, provider) => provider.getQuantity(widget.idBarang),
      builder: (context, quantity, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              color: quantity > 0 ? Colors.blue : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: quantity > 0 ? _handleMinus : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Icon(Icons.remove, color: Colors.white, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 20),
            SizedBox(
              width: 30,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Material(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: _handlePlus,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}