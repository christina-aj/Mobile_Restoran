import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
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




  // ===== AUTH (LOGIN REGISTER)=====
  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    try {
      print('Attempting registration: $data');

      final response = await http.post(
        Uri.parse('$baseUrl/user/register-tenant'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Registration success');
        return responseData;
      }

      throw Exception('Registrasi gagal: ${response.body}');
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Registrasi gagal: $e');
    }
  }

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
          'notelfon': data['notelfon'],
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





  // ===== MASTER TENANT =====
  Future<Map<String, dynamic>> getTenantById(String tenantId) async {
    await _ensureInitialized();

    try {
      print('Getting tenant info for ID: $tenantId');

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tenant/$tenantId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Tenant Info Status: ${response.statusCode}');
      print('Tenant Info Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final tenant = jsonResponse['data'];

        return {
          'id_tenant': tenant['id_tenant'],
          'nama_tenant': tenant['nama_tenant'],
          'lokasi': tenant['lokasi'],
          'notelp': tenant['notelp'],
          'kode_tenant': tenant['kode_tenant'],
        };
      }

      if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Token expired. Silakan login kembali.');
      }

      throw Exception('Gagal load tenant info: ${response.statusCode}');
    } catch (e) {
      print('Get tenant info error: $e');
      rethrow;
    }
  }





  // ===== KASIR MANAGEMENT =====
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






  // ===== MASTER KATEGORI =====
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





  // ===== MASTER BARANG =====
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



  // ===== MULTIPART UPLOAD METHODS =====

  /// Create barang dengan foto (multipart)
  Future<dynamic> createBarangWithImage(Map<String, dynamic> data, File? imageFile) async {
    await _ensureInitialized();

    try {
      print('Creating barang with image: $data');
      print('Image file: ${imageFile?.path}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/barang/create'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $_token';

      // Add text fields
      request.fields['nama_barang'] = data['nama_barang'].toString();
      request.fields['harga_default'] = data['harga_default'].toString();

      if (data['deskripsi'] != null) {
        request.fields['deskripsi'] = data['deskripsi'].toString();
      }

      if (data['id_kategori'] != null) {
        request.fields['id_kategori'] = data['id_kategori'].toString();
      }

      // Add image file if exists
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'foto', // field name sesuai API backend
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
        print('Image added to request: ${imageFile.path}');
      }

      print('Sending multipart request...');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Create Status: ${response.statusCode}');
      print('Create Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      }

      throw Exception('Gagal tambah barang: $responseBody');
    } catch (e) {
      print('Error creating barang with image: $e');
      rethrow;
    }
  }

  /// Update barang dengan foto (multipart)
  Future<dynamic> updateBarangWithImage(String id, Map<String, dynamic> data, File? imageFile) async {
    await _ensureInitialized();

    try {
      print('Updating barang $id with image: $data');
      print('Image file: ${imageFile?.path}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/barang/update/$id'),
      );

      // Add headers
      request.headers['Authorization'] = 'Bearer $_token';

      // Add text fields
      request.fields['nama_barang'] = data['nama_barang'].toString();
      request.fields['harga_default'] = data['harga_default'].toString();

      if (data['deskripsi'] != null) {
        request.fields['deskripsi'] = data['deskripsi'].toString();
      }

      if (data['id_kategori'] != null) {
        request.fields['id_kategori'] = data['id_kategori'].toString();
      }

      // Add image file if exists
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        var multipartFile = http.MultipartFile(
          'foto', // field name sesuai API backend
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);
        print('Image added to request: ${imageFile.path}');
      }

      print('Sending multipart request...');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Update Status: ${response.statusCode}');
      print('Update Body: $responseBody');

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      }

      throw Exception('Gagal update barang: $responseBody');
    } catch (e) {
      print('Error updating barang with image: $e');
      rethrow;
    }
  }




  // ===== TRANSAKSI =====
  Future<List<dynamic>> getTransaksiByTenant() async {
    await _ensureInitialized();

    try {
      print('Getting transaksi list...');

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/transaksi/index'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Transaksi List Status: ${response.statusCode}');
      print('Transaksi List Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      }

      if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Token expired. Silakan login kembali.');
      }

      throw Exception('Gagal load transaksi: HTTP ${response.statusCode}');
    } catch (e) {
      print('Get transaksi error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTransaksiById(String idTransaksi) async {
    await _ensureInitialized();

    try {
      print('Getting transaksi detail for ID: $idTransaksi');

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/transaksi/index/tenant?id_transaksi=$idTransaksi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Transaksi Detail Status: ${response.statusCode}');
      print('Transaksi Detail Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? {};
      }

      if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Token expired. Silakan login kembali.');
      }

      throw Exception('Gagal load detail transaksi: HTTP ${response.statusCode}');
    } catch (e) {
      print('Get transaksi detail error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTransaksi(Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      print('Creating transaksi: $data');

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/transaksi/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(data),
      );

      print('Create Transaksi Status: ${response.statusCode}');
      print('Create Transaksi Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData;
      }

      throw Exception('Gagal membuat transaksi: ${response.body}');
    } catch (e) {
      print('Error creating transaksi: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteTransaksi(String idTransaksi) async {
    await _ensureInitialized();

    try {
      print('Deleting transaksi: $idTransaksi');

      if (_token == null || _token!.isEmpty) {
        throw Exception('Token tidak tersedia. Silakan login kembali.');
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/transaksi/delete/$idTransaksi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('Delete Transaksi Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }

      throw Exception('Gagal hapus transaksi: ${response.body}');
    } catch (e) {
      print('Error deleting transaksi: $e');
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