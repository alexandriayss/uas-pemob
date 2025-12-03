// lib/pages/order_detail_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<OrderModel> _futureOrder;

  Future<OrderModel> _fetchOrderDetail() async {
    final url = Uri.parse('http://mortava.biz.id/api/orders/${widget.orderId}');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

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
      final dynamic raw = jsonDecode(response.body);
      String msg = 'Gagal memuat detail order';
      if (raw is Map && raw['message'] != null) {
        msg = raw['message'];
      }
      throw Exception(msg);
    }
  }

  Future<Product> _fetchProduct(int productId) async {
    final url = Uri.parse('http://mortava.biz.id/api/products/$productId');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        return Product.fromJson(body);
      } else {
        throw Exception('Format produk tidak sesuai');
      }
    } else {
      throw Exception('Gagal memuat produk ($productId)');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureOrder = _fetchOrderDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Order')),
      body: FutureBuilder<OrderModel>(
        future: _futureOrder,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final o = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =======================
                // Info produk yang dibeli
                // =======================
                FutureBuilder<Product>(
                  future: _fetchProduct(o.productId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Memuat info produk...',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }

                    if (snap.hasError || !snap.hasData) {
                      return Text(
                        'Produk #${o.productId}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      );
                    }

                    final p = snap.data!;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: (p.image != null && p.image!.isNotEmpty)
                                ? Image.network(
                                    p.image!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                  )
                                : const Icon(Icons.image, size: 40),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (p.offerPrice != null)
                                Text('Rp ${p.offerPrice}')
                              else if (p.price != null)
                                Text('Rp ${p.price}'),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // =======================
                // Info order
                // =======================
                Text(
                  'Order #${o.id}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Status: ${o.status}'),
                const SizedBox(height: 8),
                Text('Metode Pembayaran: ${o.paymentMethod.toUpperCase()}'),
                if (o.totalPrice != null) Text('Total: Rp ${o.totalPrice}'),
                const SizedBox(height: 16),

                const Text(
                  'Alamat Pengiriman',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (o.shippingStreet != null && o.shippingStreet!.isNotEmpty)
                  Text(o.shippingStreet!),
                if (o.shippingCity != null || o.shippingState != null)
                  Text(
                    '${o.shippingCity ?? ''}'
                    '${o.shippingCity != null && o.shippingState != null ? ', ' : ''}'
                    '${o.shippingState ?? ''}',
                  ),
                if (o.shippingPostalCode != null || o.shippingCountry != null)
                  Text(
                    '${o.shippingPostalCode ?? ''}'
                    '${o.shippingPostalCode != null && o.shippingCountry != null ? ', ' : ''}'
                    '${o.shippingCountry ?? ''}',
                  ),
                if (o.shippingPhone != null && o.shippingPhone!.isNotEmpty)
                  Text('Telp: ${o.shippingPhone}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
