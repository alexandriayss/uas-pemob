import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';
import 'order_detail_page.dart';

class MySalesPage extends StatefulWidget {
  const MySalesPage({super.key});

  @override
  State<MySalesPage> createState() => _MySalesPageState();
}

class _MySalesPageState extends State<MySalesPage> {
  Future<List<OrderModel>>? _futureSales;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndSales();
  }

  Future<void> _loadUserAndSales() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');

    if (!mounted) return;

    if (id == null) {
      setState(() {
        _futureSales = Future.error('User belum login');
      });
      return;
    }

    setState(() {
      _userId = id;
      _futureSales = _fetchSales();
    });
  }

  Future<List<OrderModel>> _fetchSales() async {
    if (_userId == null) {
      throw Exception('User belum login');
    }

    final url = Uri.parse('http://mortava.biz.id/api/orders/sell/$_userId');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body is List) {
        return body.map((e) => OrderModel.fromJson(e)).toList();
      } else {
        throw Exception('Format API tidak sesuai (harus List)');
      }
    } else {
      throw Exception('Gagal memuat penjualan (${response.statusCode})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penjualan Saya')),
      body: _futureSales == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<OrderModel>>(
              future: _futureSales,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final sales = snapshot.data ?? [];

                if (sales.isEmpty) {
                  return const Center(child: Text('Belum ada penjualan'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: sales.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final o = sales[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          'Order #${o.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text('Produk ID: ${o.productId}'),
                            if (o.totalPrice != null)
                              Text('Total: Rp ${o.totalPrice}'),
                            Text('Metode: ${o.paymentMethod.toUpperCase()}'),
                            Text('Status: ${o.status}'),
                            const SizedBox(height: 4),
                            if (o.userBeli != null)
                              Text('Dibeli oleh User ID: ${o.userBeli}'),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OrderDetailPage(orderId: o.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
