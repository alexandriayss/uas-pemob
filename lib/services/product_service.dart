import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import 'api_service.dart';

class ProductService {
  final ApiService _api = ApiService();

  // Ambil semua produk (dipakai di HomePage)
  Future<List<Product>> getAllProducts() async {
    final http.Response response = await _api.getRaw('/products');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      List<dynamic> list;
      if (body is List) {
        list = body;
      } else if (body is Map && body['data'] is List) {
        list = body['data'];
      } else if (body is Map && body['products'] is List) {
        list = body['products'];
      } else {
        throw Exception('Format data produk tidak dikenali');
      }

      return list.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat produk (${response.statusCode})');
    }
  }

  // Dipakai di MyProductsPage
  Future<List<Product>> getMyProducts(int userId) async {
    final http.Response response = await _api.getRaw('/products/user/$userId');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body is List) {
        return body.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception(
          'Format response Produk Saya tidak sesuai (harus List)',
        );
      }
    } else {
      throw Exception('Gagal memuat produk saya (${response.statusCode})');
    }
  }

  // Hapus produk (dipanggil dari MyProductsPage)
  Future<void> deleteProduct(int productId) async {
    final url = Uri.parse('${ApiService.baseUrl}/products/$productId');
    final response = await http.delete(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      String msg = 'Gagal menghapus produk (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          msg = body['message'];
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // Detail produk by ID (dipakai di Product Detail Page)
  Future<Product> getProductById(int productId) async {
    final http.Response response = await _api.getRaw('/products/$productId');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      Map<String, dynamic> map;
      if (body is Map && body['data'] is Map) {
        map = Map<String, dynamic>.from(body['data']);
      } else if (body is Map && body['product'] is Map) {
        map = Map<String, dynamic>.from(body['product']);
      } else if (body is Map) {
        map = Map<String, dynamic>.from(body);
      } else {
        throw Exception('Format detail produk tidak dikenali');
      }

      return Product.fromJson(map);
    } else {
      throw Exception('Gagal memuat detail produk (${response.statusCode})');
    }
  }

  Future<void> updateProductStatus({
    required int productId,
    required String status,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/products/$productId');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Gagal update status produk (${response.statusCode})');
    }
  }

  Future<void> softDeleteProduct(int productId) async {
    final response = await _api.patchRaw('/products/$productId');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete product');
    }
  }
}
