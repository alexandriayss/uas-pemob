import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/order_model.dart';

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
        final Map<String, dynamic> body = Map<String, dynamic>.from(
          raw,
        ); // <-- cast rapi

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
                const SizedBox(height: 8),
                Text('Produk ID: ${o.productId}'),
                if (o.userBeli != null) Text('User Pembeli ID: ${o.userBeli}'),
                if (o.userJual != null) Text('User Penjual ID: ${o.userJual}'),
                const SizedBox(height: 16),
                const Text(
                  'Alamat Pengiriman',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                if (o.shippingStreet != null) Text(o.shippingStreet!),
                if (o.shippingCity != null || o.shippingState != null)
                  Text(
                    '${o.shippingCity ?? ''}${o.shippingCity != null && o.shippingState != null ? ', ' : ''}${o.shippingState ?? ''}',
                  ),
                if (o.shippingPostalCode != null || o.shippingCountry != null)
                  Text(
                    '${o.shippingPostalCode ?? ''}${o.shippingPostalCode != null && o.shippingCountry != null ? ', ' : ''}${o.shippingCountry ?? ''}',
                  ),
                if (o.shippingPhone != null) Text('Telp: ${o.shippingPhone}'),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
