import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../bottom_navigation.dart';
import 'edit_kasir.dart';
import 'tambah_kasir.dart';

class DaftarKasirScreen extends StatefulWidget {
  final ApiService apiService;

  const DaftarKasirScreen({
    Key? key,
    required this.apiService,
  }) : super(key: key);

  @override
  State<DaftarKasirScreen> createState() => _DaftarKasirScreenState();
}

class _DaftarKasirScreenState extends State<DaftarKasirScreen> {
  List<dynamic> _kasirList = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndKasir();
  }

  Future<void> _loadCurrentUserAndKasir() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userInfo = await widget.apiService.getUserInfo();
      _currentUserEmail = userInfo['email'];
      print('Current logged in user: $_currentUserEmail');
      await _loadKasirList();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadKasirList() async {
    try {
      final kasirData = await widget.apiService.getKasirByTenant();

      final filteredKasir = kasirData.where((kasir) {
        final kasirEmail = kasir['email']?.toString() ?? '';
        return kasirEmail != _currentUserEmail;
      }).toList();

      setState(() {
        _kasirList = filteredKasir;
        _isLoading = false;
      });

      print('Total kasir: ${kasirData.length}, Setelah filter: ${filteredKasir.length}');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteKasir(String userId, String nama) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus kasir "$nama"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await widget.apiService.deleteKasir(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kasir berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadKasirList();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus kasir: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildKasirCard(dynamic kasir) {
    final userId = kasir['user_id']?.toString() ?? '';
    final nama = kasir['nama'] ?? kasir['name'] ?? 'Tidak ada nama';
    final notelpon = kasir['notelfon'] ?? '-';
    final email = kasir['email'] ?? '-';
    final lokasi = kasir['lokasi'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nama Kasir: $nama',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Nomor Telp: $notelpon',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Email: $email',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
            ),
          ),
          if (lokasi != '-') ...[
            const SizedBox(height: 4),
            Text(
              'Lokasi: $lokasi',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _deleteKasir(userId, nama),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Hapus'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditKasirScreen(
                          apiService: widget.apiService,
                          kasirData: kasir,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadKasirList();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Kasir',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Kasir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TambahKasirScreen(
                          apiService: widget.apiService,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadCurrentUserAndKasir();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Tambah'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gagal memuat data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCurrentUserAndKasir,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
                : _kasirList.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    color: Colors.grey.shade400,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kasir',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tambahkan kasir baru dengan\nmenekan tombol Tambah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadCurrentUserAndKasir,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _kasirList.length,
                itemBuilder: (context, index) {
                  return _buildKasirCard(_kasirList[index]);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 2,
        apiService: widget.apiService,
      ),
    );
  }
}