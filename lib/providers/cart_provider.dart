import 'package:flutter/material.dart';

// Model untuk Cart Item
class CartItem {
  final String idBarang;
  final String namaBarang;
  final int harga;
  final String? kategori;
  final String? foto;
  final String? deskripsi;
  int quantity;

  CartItem({
    required this.idBarang,
    required this.namaBarang,
    required this.harga,
    this.kategori,
    this.foto,
    this.deskripsi,
    this.quantity = 1,
  });

  // Total harga untuk item ini
  int get totalPrice => harga * quantity;

  // Convert to JSON untuk kirim ke API
  Map<String, dynamic> toJson() {
    return {
      'id_barang': idBarang,
      'nama_barang': namaBarang,
      'harga_default': harga,
      'quantity': quantity,
      'deskripsi': deskripsi ?? '-',
    };
  }
}

// Provider untuk manage Cart State
class CartProvider extends ChangeNotifier {
  // List untuk menyimpan cart items (in-memory)
  final List<CartItem> _items = [];

  // Getter untuk mendapatkan semua items
  List<CartItem> get items => List.unmodifiable(_items);

  // Getter untuk total items
  int get itemCount => _items.length;

  // Getter untuk total quantity
  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Getter untuk total harga
  int get totalPrice {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Cek apakah item sudah ada di cart
  bool isInCart(String idBarang) {
    return _items.any((item) => item.idBarang == idBarang);
  }

  // Get quantity untuk item tertentu
  int getQuantity(String idBarang) {
    final item = _items.firstWhere(
          (item) => item.idBarang == idBarang,
      orElse: () => CartItem(idBarang: '', namaBarang: '', harga: 0, quantity: 0),
    );
    return item.quantity;
  }

  // Tambah item ke cart
  void addItem({
    required String idBarang,
    required String namaBarang,
    required int harga,
    String? kategori,
    String? foto,
    String? deskripsi,
  }) {
    print('CartProvider: Adding item - $namaBarang (ID: $idBarang)');

    // Cek apakah item sudah ada
    final existingIndex = _items.indexWhere((item) => item.idBarang == idBarang);

    if (existingIndex >= 0) {
      // Jika sudah ada, tambah quantity
      _items[existingIndex].quantity++;
      print('CartProvider: Item exists, increased quantity to ${_items[existingIndex].quantity}');
    } else {
      // Jika belum ada, tambah item baru
      _items.add(CartItem(
        idBarang: idBarang,
        namaBarang: namaBarang,
        harga: harga,
        kategori: kategori,
        foto: foto,
        deskripsi: deskripsi,
        quantity: 1,
      ));
      print('CartProvider: New item added with quantity 1');
    }

    print('CartProvider: Total items in cart: ${_items.length}');
    notifyListeners();
    print('CartProvider: notifyListeners() called');
  }

  // Update quantity item
  void updateQuantity(String idBarang, int quantity) {
    print('CartProvider: Updating quantity for $idBarang to $quantity');

    final index = _items.indexWhere((item) => item.idBarang == idBarang);
    if (index >= 0) {
      if (quantity > 0) {
        _items[index].quantity = quantity;
        print('CartProvider: Quantity updated to $quantity');
      } else {
        // Jika quantity 0, hapus item
        final removedItem = _items[index].namaBarang;
        _items.removeAt(index);
        print('CartProvider: Item $removedItem removed (quantity 0)');
      }
      notifyListeners();
      print('CartProvider: notifyListeners() called');
    } else {
      print('CartProvider: Item not found in cart');
    }
  }

  // Increment quantity
  void incrementQuantity(String idBarang) {
    print('CartProvider: Incrementing quantity for $idBarang');

    final index = _items.indexWhere((item) => item.idBarang == idBarang);
    if (index >= 0) {
      _items[index].quantity++;
      print('CartProvider: Quantity increased to ${_items[index].quantity}');
      notifyListeners();
      print('CartProvider: notifyListeners() called');
    } else {
      print('CartProvider: Item not found for increment');
    }
  }

  // Decrement quantity
  void decrementQuantity(String idBarang) {
    print('CartProvider: Decrementing quantity for $idBarang');

    final index = _items.indexWhere((item) => item.idBarang == idBarang);
    if (index >= 0) {
      final currentQty = _items[index].quantity;
      if (currentQty > 1) {
        _items[index].quantity--;
        print('CartProvider: Quantity decreased to ${_items[index].quantity}');
      } else {
        // Jika quantity jadi 0, hapus item
        final removedItem = _items[index].namaBarang;
        _items.removeAt(index);
        print('CartProvider: Item $removedItem removed (quantity became 0)');
      }
      notifyListeners();
      print('CartProvider: notifyListeners() called');
    } else {
      print('CartProvider: Item not found for decrement');
    }
  }

  // Hapus item dari cart
  void removeItem(String idBarang) {
    print('CartProvider: Removing item $idBarang');
    final sizeBefore = _items.length;
    _items.removeWhere((item) => item.idBarang == idBarang);
    print('CartProvider: Items removed: ${sizeBefore - _items.length}');
    notifyListeners();
    print('CartProvider: notifyListeners() called');
  }

  // Clear semua cart
  void clearCart() {
    print('CartProvider: Clearing all cart items');
    _items.clear();
    notifyListeners();
    print('CartProvider: notifyListeners() called');
  }

  // Get cart items untuk dikirim ke API
  List<Map<String, dynamic>> getCartForOrder() {
    return _items.map((item) => item.toJson()).toList();
  }

  // Debug: Print semua items di cart
  void printCart() {
    print('=== CART DEBUG ===');
    print('Total items: ${_items.length}');
    for (var item in _items) {
      print('- ${item.namaBarang} (ID: ${item.idBarang}): ${item.quantity}x @ Rp${item.harga}');
    }
    print('Total quantity: $totalQuantity');
    print('Total price: Rp$totalPrice');
    print('==================');
  }
}