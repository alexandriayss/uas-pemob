import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import 'api_service.dart';

class OrderService {
  final ApiService _api = ApiService();

  // Pesanan sebagai pembeli (My Orders)
  Future<List<OrderModel>> getOrdersForUser(int userId) async {
    final http.Response response = await _api.getRaw('/orders/buy/$userId');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body is List) {
        return body
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("Format API tidak sesuai (harus list)");
      }
    } else {
      throw Exception("Gagal memuat pesanan (${response.statusCode})");
    }
  }

  // Penjualan sebagai penjual (My Sales)
  Future<List<OrderModel>> getSalesForUser(int userId) async {
    final http.Response response = await _api.getRaw('/orders/sell/$userId');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body is List) {
        return body
            .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Format API tidak sesuai (harus list)');
      }
    } else {
      throw Exception('Gagal memuat penjualan (${response.statusCode})');
    }
  }

  // Detail Order
  Future<OrderModel> getOrderDetail(int orderId) async {
    final http.Response response = await _api.getRaw('/orders/$orderId');

    if (response.statusCode == 200) {
      final dynamic raw = jsonDecode(response.body);

      if (raw is Map) {
        final Map<String, dynamic> body = Map<String, dynamic>.from(raw);

        if (body['id'] != null) {
          return OrderModel.fromJson(body);
        } else {
          throw Exception('Format detail order tidak sesuai');
        }
      } else {
        throw Exception('Response bukan objek JSON');
      }
    } else {
      try {
        final dynamic raw = jsonDecode(response.body);
        String msg = 'Gagal memuat detail order';
        if (raw is Map && raw['message'] != null) {
          msg = raw['message'];
        }
        throw Exception(msg);
      } catch (_) {
        throw Exception('Gagal memuat detail order (${response.statusCode})');
      }
    }
  }

  // Create Order
  Future<String> createOrder({
    required int userId,
    required int productId,
    required String shippingPhone,
    required String shippingStreet,
    required String shippingCity,
    required String shippingState,
    required String shippingPostalCode,
    required String shippingCountry,
    required String paymentMethod,
  }) async {
    final Map<String, dynamic> body = {
      'user_beli': userId,
      'product_id': productId,
      'shipping_phone': shippingPhone,
      'shipping_street': shippingStreet,
      'shipping_city': shippingCity,
      'shipping_state': shippingState,
      'shipping_postal_code': shippingPostalCode,
      'shipping_country': shippingCountry,
      'payment_method': paymentMethod,
    };

    final http.Response response = await _api.postRaw(
      '/orders',
      jsonEncode(body),
    );

    final dynamic raw = jsonDecode(response.body);

    String msg = 'Order created successfully.';
    if (raw is Map && raw['message'] != null) {
      msg = raw['message'].toString();
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return msg;
    } else {
      throw Exception(msg);
    }
  }

  // COMPLETE ORDER (buyer, nanti dipakai di orders)
  Future<void> completeOrder(int orderId) async {
    final response = await _api.patchRaw('/orders/$orderId/complete');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal menyelesaikan pesanan (${response.statusCode})');
    }
  }

  // SHIP ORDER (seller, nanti dipakai di sales)
  Future<void> shipOrder(int orderId) async {
    final response = await _api.patchRaw('/orders/$orderId/ship');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal mengirim pesanan (${response.statusCode})');
    }
  }
}
