import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TambahMenuScreen extends StatefulWidget {
  const TambahMenuScreen({Key? key, required ApiService apiService}) : super(key: key);

  @override
  State<TambahMenuScreen> createState() => _TambahMenuScreenState();
}

class _TambahMenuScreenState extends State<TambahMenuScreen> {
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  String? _selectedKategori;

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
        child: Column(
          children: [
            // Foto Placeholder
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
              onPressed: () {},
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
            // Nama Menu
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.edit_outlined),
                hintText: '(Nama Menu)',
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
            // Harga
            TextField(
              controller: _hargaController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.payments_outlined),
                hintText: '(Harga)',
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
            // Kategori Dropdown
            DropdownButtonFormField<String>(
              value: _selectedKategori,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.category_outlined),
                hintText: '(Pilih Kategori)',
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
              items: ['Makanan', 'Minuman', 'Snack']
                  .map((kategori) => DropdownMenuItem(
                value: kategori,
                child: Text(kategori),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKategori = value;
                });
              },
            ),
            const SizedBox(height: 32),
            // Tambah Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Tambah',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
