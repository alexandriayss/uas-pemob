// lib/views/order_create_page.dart
//
// Order Create Page (Confirm Order) dengan tema Mortava:
// - Background gradient cream–peach (MortavaDecorations.marketplaceBackgroundBox())
// - Header custom dengan back button + "Confirm Order"
// - Card ringkasan produk + card form alamat & payment
// - Teks sebagian besar bahasa Inggris agar konsisten

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product_model.dart';
import '../models/user_model.dart';
import '../controllers/order_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/product_controller.dart'; 
import '../theme/mortava_theme.dart';

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
  UserModel? _currentUser;

  final OrderController _orderController = OrderController();
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _userController.getCurrentUser();

    if (!mounted) return;

    setState(() {
      _currentUser = user;
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

    if (_currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User is not logged in')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final msg = await _orderController.createOrder(
        userId: _currentUser!.id,
        productId: widget.product.id,
        shippingPhone: _phoneC.text.trim(),
        shippingStreet: _streetC.text.trim(),
        shippingCity: _cityC.text.trim(),
        shippingState: _stateC.text.trim(),
        shippingPostalCode: _postalC.text.trim(),
        shippingCountry: _countryC.text.trim(),
        paymentMethod: _paymentMethod,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // 🔥 PENTING: sembunyikan produk dari marketplace (frontend only)
      ProductController.hideProductLocally(widget.product.id);

      // 🔥 kirim sinyal ke halaman sebelumnya (Marketplace)
      Navigator.pop(context, true);
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

  InputDecoration _fieldDecoration(String label) {
    const borderRadius = 20.0;
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(
          color: MortavaColors.bottomNavBorder,
          width: 1.1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(
          color: MortavaColors.bottomNavBorder,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: MortavaDecorations.marketplaceBackgroundBox(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ================= HEADER =================
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Confirm Order',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: MortavaColors.darkText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 130,
                    height: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ================= CARD RINGKASAN PRODUK =================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EB)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFFFD9B3).withOpacity(0.7),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: MortavaColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (p.offerPrice != null)
                              Text(
                                'Price: Rp ${p.offerPrice}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: MortavaColors.primaryOrange,
                                ),
                              )
                            else if (p.price != null)
                              Text(
                                'Price: Rp ${p.price}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: MortavaColors.primaryOrange,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ================= FORM =================
                Text(
                  'Shipping address',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A3424),
                  ),
                ),
                const SizedBox(height: 8),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _phoneC,
                        keyboardType: TextInputType.phone,
                        decoration: _fieldDecoration('Phone number'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'This field is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _streetC,
                        decoration: _fieldDecoration(
                          'Street / detailed address',
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'This field is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cityC,
                        decoration: _fieldDecoration('City / Regency'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'This field is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _stateC,
                        decoration: _fieldDecoration('Province'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'This field is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _postalC,
                        keyboardType: TextInputType.number,
                        decoration: _fieldDecoration('Postal code'),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'This field is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _countryC,
                        decoration: _fieldDecoration('Country'),
                      ),

                      const SizedBox(height: 20),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Payment method',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4A3424),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        items: const [
                          DropdownMenuItem(
                            value: 'cod',
                            child: Text('Cash on Delivery (COD)'),
                          ),
                          DropdownMenuItem(value: 'qris', child: Text('QRIS')),
                          DropdownMenuItem(
                            value: 'paylater',
                            child: Text('Paylater'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _paymentMethod = val;
                            });
                          }
                        },
                        decoration: _fieldDecoration('Choose payment method'),
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: const StadiumBorder(),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFF59D), Color(0xFFFFEB3B)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Create Order',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF2C1B10),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
