import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TambahMenuScreen extends StatefulWidget {
  final ApiService apiService;

  const TambahMenuScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  State<TambahMenuScreen> createState() => _TambahMenuScreenState();
}

class _TambahMenuScreenState extends State<TambahMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _deskripsiController = TextEditingController();

  String? _selectedKategori;
  bool _isLoading = false;
  bool _isLoadingKategori = true;
  List<dynamic> _kategoriList = [];

  @override
  void initState() {
    super.initState();
    _loadKategori();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _loadKategori() async {
    setState(() {
      _isLoadingKategori = true;
    });

    try {
      print('Loading kategori...');
      final data = await widget.apiService.getKategoriIndex();
      print('Kategori loaded: ${data.length} items');

      if (mounted) {
        setState(() {
          _kategoriList = data;
          _isLoadingKategori = false;
        });
      }
    } catch (e) {
      print('Error loading kategori: $e');

      if (mounted) {
        setState(() {
          _isLoadingKategori = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat kategori: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _handleTambahMenu() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final data = {
        'nama_barang': _namaController.text.trim(),
        'harga_default': double.parse(_hargaController.text.trim()),
        'deskripsi': _deskripsiController.text.trim().isEmpty
            ? null
            : _deskripsiController.text.trim(),
        'id_kategori': _selectedKategori != null ? int.tryParse(_selectedKategori!) : null,
      };

      print('Creating menu with data: $data');

      await widget.apiService.createBarang(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menu berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('Error creating menu: $e');

      if (!mounted) return;

      String errorMessage = e.toString();
      if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage.replaceAll('Exception:', '').trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan menu: $errorMessage'),
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
          'Tambah Menu',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.no_photography_outlined,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur upload foto belum tersedia')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add Foto'),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _namaController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.edit_outlined),
                  labelText: 'Nama Menu',
                  hintText: 'Contoh: Bakso Campur',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
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
                    return 'Nama menu tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _hargaController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.payments_outlined),
                  labelText: 'Harga',
                  hintText: 'Contoh: 15000',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
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
                    return 'Harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Harga harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _deskripsiController,
                enabled: !_isLoading,
                maxLines: 3,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.description_outlined),
                  labelText: 'Deskripsi (Opsional)',
                  hintText: 'Deskripsi menu...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown Kategori Dynamic
              _isLoadingKategori
                  ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Memuat kategori...',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
                  : DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category_outlined),
                  labelText: 'Kategori (Opsional)',
                  hintText: 'Pilih Kategori',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                items: _kategoriList.isEmpty
                    ? [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'Belum ada kategori',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  )
                ]
                    : _kategoriList.map((kategori) {
                  final id = kategori['id_kategori'].toString();
                  final nama = kategori['nama_kategori'] ?? 'Tidak ada nama';
                  final kode = kategori['kode_kategori'] ?? '';

                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text('$nama${kode.isNotEmpty ? " ($kode)" : ""}'),
                  );
                }).toList(),
                onChanged: _isLoading || _kategoriList.isEmpty
                    ? null
                    : (value) {
                  setState(() {
                    _selectedKategori = value;
                  });
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTambahMenu,
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
                    'Tambah',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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