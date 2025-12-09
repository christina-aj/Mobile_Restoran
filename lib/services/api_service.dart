import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.250:8000/api/v1';

  String? _token;
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      if (_token != null) {
        print('Token loaded from storage');
      } else {
        print('No token found in storage');
      }
      _isInitialized = true;
    } catch (e) {
      print('Error loading token: $e');
      _isInitialized = true;
    }
  }

  // AUTH
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting login for: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        final token = data['token'] ?? data['access_token'];

        if (token != null) {
          await setToken(token);
          print('Login success - Token saved');
        } else {
          print('Warning: No token in response');
        }

        return data;
      }

      throw Exception('Login gagal: ${response.body}');
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login gagal: $e');
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    await _ensureInitialized();

    try {
      print('Getting user info...');
      print('Current token exists: ${_token != null}');

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/userinfo'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('UserInfo Status: ${response.statusCode}');
      print('UserInfo Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        return {
          'user_id': data['user_id'] ?? data['id'],
          'nama': data['nama'] ?? data['name'],
          'name': data['nama'] ?? data['name'],
          'email': data['email'],
          'role': data['role'],
          'id_tenant': data['id_tenant'],
        };
      }

      if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Token expired. Silakan login kembali.');
      }

      throw Exception('Gagal load user info: ${response.statusCode}');
    } catch (e) {
      print('Get user info error: $e');
      rethrow;
    }
  }

  // KASIR MANAGEMENT
  Future<List<dynamic>> getKasirByTenant() async {
    await _ensureInitialized();

    try {
      print('Getting kasir list by tenant...');

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user/index'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Kasir List Status: ${response.statusCode}');
      print('Kasir List Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> allUsers = data['data'] ?? [];

        List<dynamic> kasirList = allUsers.where((user) {
          String role = (user['role'] ?? '').toString().toLowerCase();
          return role == 'kasir' || role == 'tenant';
        }).toList();

        print('Found ${kasirList.length} kasir from ${allUsers.length} total users');

        return kasirList;
      }

      if (response.statusCode == 404) {
        print('Endpoint /user/index not found, trying /user/kasir');
        return await _getKasirAlternative();
      }

      if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Token expired. Silakan login kembali.');
      }

      throw Exception('Gagal load kasir: HTTP ${response.statusCode}');
    } catch (e) {
      print('Get kasir error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> _getKasirAlternative() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/kasir'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Alternative endpoint status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }

      throw Exception('Both endpoints failed');
    } catch (e) {
      print('Alternative endpoint also failed: $e');
      rethrow;
    }
  }

  Future<dynamic> createKasir(Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      print('Creating kasir: $data');

      final response = await http.post(
        Uri.parse('$baseUrl/user/create/kasir'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );

      print('Create Kasir Status: ${response.statusCode}');
      print('Create Kasir Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }

      throw Exception('Gagal tambah kasir: ${response.body}');
    } catch (e) {
      print('Error creating kasir: $e');
      rethrow;
    }
  }

  Future<dynamic> updateKasir(String userId, Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      print('Updating kasir $userId: $data');

      final response = await http.put(
        Uri.parse('$baseUrl/user/update/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );

      print('Update Kasir Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw Exception('Gagal update kasir: ${response.body}');
    } catch (e) {
      print('Error updating kasir: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteKasir(String userId) async {
    await _ensureInitialized();

    try {
      print('Deleting kasir: $userId');

      final response = await http.delete(
        Uri.parse('$baseUrl/user/delete/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Delete Kasir Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw Exception('Gagal hapus kasir: ${response.body}');
    } catch (e) {
      print('Error deleting kasir: $e');
      rethrow;
    }
  }

  // MASTER KATEGORI
  Future<List<dynamic>> getKategoriIndex() async {
    await _ensureInitialized();

    try {
      print('Getting kategori index...');

      final response = await http.get(
        Uri.parse('$baseUrl/kategori/index'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Kategori Status: ${response.statusCode}');
      print('Kategori Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }

      if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Token expired. Silakan login kembali.');
      }

      throw Exception('Gagal load kategori: ${response.statusCode}');
    } catch (e) {
      print('Get kategori error: $e');
      rethrow;
    }
  }

  Future<dynamic> createKategori(Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      print('Creating kategori: $data');

      final response = await http.post(
        Uri.parse('$baseUrl/kategori/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );

      print('Create Kategori Status: ${response.statusCode}');
      print('Create Kategori Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }

      throw Exception('Gagal tambah kategori: ${response.body}');
    } catch (e) {
      print('Error creating kategori: $e');
      rethrow;
    }
  }

  Future<dynamic> updateKategori(String id, Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      print('Updating kategori $id: $data');

      final response = await http.put(
        Uri.parse('$baseUrl/kategori/update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );

      print('Update Kategori Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw Exception('Gagal update kategori: ${response.body}');
    } catch (e) {
      print('Error updating kategori: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteKategori(String id) async {
    await _ensureInitialized();

    try {
      print('Deleting kategori: $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/kategori/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Delete Kategori Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw Exception('Gagal hapus kategori: ${response.body}');
    } catch (e) {
      print('Error deleting kategori: $e');
      rethrow;
    }
  }

  // MASTER BARANG
  Future<List<dynamic>> getBarangByTenant() async {
    await _ensureInitialized();

    try {
      print('Getting barang by tenant...');
      print('Token exists: ${_token != null}');

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/barang/index'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Barang Status: ${response.statusCode}');
      print('Barang Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final barangList = data['data'] ?? [];

        print('Found ${barangList.length} items');

        if (barangList.isEmpty) {
          print('Data kosong - Belum ada menu di database');
        }

        return barangList;
      }

      if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Token expired. Silakan login kembali.');
      }

      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    } catch (e) {
      print('Get barang error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getBarangGlobal() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/barang/global'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      throw Exception('Gagal load barang global');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<dynamic> createBarang(Map<String, dynamic> data) async {
    try {
      print('Creating barang: $data');

      final response = await http.post(
        Uri.parse('$baseUrl/barang/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );

      print('Create Status: ${response.statusCode}');
      print('Create Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Gagal tambah barang: ${response.body}');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<dynamic> updateBarang(String id, Map<String, dynamic> data) async {
    try {
      print('Updating barang $id: $data');

      final response = await http.post(
        Uri.parse('$baseUrl/barang/update/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );

      print('Update Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Gagal update barang: ${response.body}');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteBarang(String id) async {
    try {
      print('Deleting barang: $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/barang/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Delete Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Gagal hapus barang: ${response.body}');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> filterBarang(String idKategori) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/barang/filter/$idKategori'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      throw Exception('Gagal filter barang');
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  // DETAIL BARANG
  Future<List<dynamic>> getDetailBarangGlobal() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Detail_Barang/DetailBarangGlobal'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      throw Exception('Gagal load detail barang');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getDetailBarangByTenant() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Detail_Barang/DetailBarangbytenant'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }
      throw Exception('Gagal load detail barang');
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createDetailBarang(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Detail_Barang/CreateDetailBarang'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Gagal tambah detail barang');
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateDetailBarang(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/Detail_Barang/UpdateDetailBarang/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception('Gagal update detail barang');
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteDetailBarang(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/Detail_Barang/DeleteDetailBarang/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      if (response.statusCode == 200) return json.decode(response.body);
      throw Exception('Gagal hapus detail barang');
    } catch (e) {
      rethrow;
    }
  }

  // HELPER
  String? get token => _token;

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('Token saved to storage');
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('Token cleared from storage');
  }

  Future<bool> isLoggedIn() async {
    await _ensureInitialized();
    return _token != null && _token!.isNotEmpty;
  }
}