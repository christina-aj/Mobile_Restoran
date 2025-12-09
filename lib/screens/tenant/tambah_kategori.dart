import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TambahKategoriScreen extends StatefulWidget {
  final ApiService apiService;

  const TambahKategoriScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<TambahKategoriScreen> createState() => _TambahKategoriScreenState();
}

class _TambahKategoriScreenState extends State<TambahKategoriScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kodeController = TextEditingController();
  final _namaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _kodeController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _handleTambahKategori() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'kode_kategori': _kodeController.text.trim(),
        'nama_kategori': _namaController.text.trim(),
      };

      print('Creating kategori: $data');

      await widget.apiService.createKategori(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('Error creating kategori: $e');

      if (!mounted) return;

      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambah kategori: $errorMessage'),
          backgroundColor: Colors.red,
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
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Kategori',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Icon Kategori
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade300, Colors.blue.shade600],
                  ),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Kode Kategori
              TextFormField(
                controller: _kodeController,
                enabled: !_isLoading,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.qr_code_outlined),
                  labelText: 'Kode Kategori',
                  hintText: 'Contoh: MKN, MNM, SNK',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kode kategori tidak boleh kosong';
                  }
                  if (value.length < 2) {
                    return 'Kode minimal 2 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Nama Kategori
              TextFormField(
                controller: _namaController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.label_outlined),
                  labelText: 'Nama Kategori',
                  hintText: 'Contoh: Makanan, Minuman',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tombol Tambah
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTambahKategori,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                    'Tambah Kategori',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}