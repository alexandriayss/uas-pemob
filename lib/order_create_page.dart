import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';

class OrderCreatePage extends StatefulWidget {
  final Product product;

  const OrderCreatePage({super.key, required this.product});

  @override
  State<OrderCreatePage> createState() => _OrderCreatePageState();
}

class _OrderCreatePageState extends State<OrderCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _phoneC = TextEditingController();
  final TextEditingController _streetC = TextEditingController();
  final TextEditingController _cityC = TextEditingController();
  final TextEditingController _stateC = TextEditingController();
  final TextEditingController _postalC = TextEditingController();
  final TextEditingController _countryC = TextEditingController(
    text: 'Indonesia',
  );

  String _paymentMethod = 'cod';
  bool _isSubmitting = false;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
    });
  }

  @override
  void dispose() {
    _phoneC.dispose();
    _streetC.dispose();
    _cityC.dispose();
    _stateC.dispose();
    _postalC.dispose();
    _countryC.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User belum login')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final url = Uri.parse('http://mortava.biz.id/api/orders');
      final body = {
        'user_beli': _userId,
        'product_id': widget.product.id,
        'shipping_phone': _phoneC.text.trim(),
        'shipping_street': _streetC.text.trim(),
        'shipping_city': _cityC.text.trim(),
        'shipping_state': _stateC.text.trim(),
        'shipping_postal_code': _postalC.text.trim(),
        'shipping_country': _countryC.text.trim(),
        'payment_method': _paymentMethod,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // sukses
        final msg = data['message'] ?? 'Order berhasil dibuat.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        Navigator.pop(context, true); // balik ke detail / sebelumnya
      } else {
        // gagal
        String msg = data['message'] ?? 'Gagal membuat order';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Order')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ringkasan produk
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (p.offerPrice != null)
                        Text('Harga: Rp ${p.offerPrice}')
                      else if (p.price != null)
                        Text('Harga: Rp ${p.price}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Alamat Pengiriman',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _phoneC,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _streetC,
                decoration: const InputDecoration(
                  labelText: 'Jalan / Detail alamat',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cityC,
                decoration: const InputDecoration(
                  labelText: 'Kota / Kabupaten',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _stateC,
                decoration: const InputDecoration(
                  labelText: 'Provinsi',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _postalC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kode Pos',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _countryC,
                decoration: const InputDecoration(
                  labelText: 'Negara',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Metode Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                items: const [
                  DropdownMenuItem(
                    value: 'cod',
                    child: Text('Bayar di Tempat (COD)'),
                  ),
                  DropdownMenuItem(value: 'qris', child: Text('QRIS')),
                  DropdownMenuItem(value: 'paylater', child: Text('Paylater')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _paymentMethod = val;
                    });
                  }
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Buat Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
