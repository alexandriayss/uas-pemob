import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/product_model.dart';
import '../theme/mortava_theme.dart';

class CreateEditProductPage extends StatefulWidget {
  final Product? product; // null = create, not null = edit

  const CreateEditProductPage({super.key, this.product});

  @override
  State<CreateEditProductPage> createState() => _CreateEditProductPageState();
}

class _CreateEditProductPageState extends State<CreateEditProductPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameC = TextEditingController();
  final TextEditingController _categoryC = TextEditingController();
  final TextEditingController _descriptionC = TextEditingController();
  final TextEditingController _priceC = TextEditingController();
  final TextEditingController _offerPriceC = TextEditingController();

  File? _imageFile;
  bool _isSubmitting = false;

  bool get isEdit => widget.product != null;

  int? _userId;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    if (isEdit) {
      final p = widget.product!;
      _nameC.text = p.name;
      _categoryC.text = p.category ?? '';
      _descriptionC.text = p.description ?? '';
      _priceC.text = p.price?.toString() ?? '';
      _offerPriceC.text = p.offerPrice?.toString() ?? '';
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('user_id');
      _isLoadingUser = false;
    });
  }

  @override
  void dispose() {
    _nameC.dispose();
    _categoryC.dispose();
    _descriptionC.dispose();
    _priceC.dispose();
    _offerPriceC.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isEdit && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar produk')),
      );
      return;
    }

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User belum login, tidak bisa membuat produk'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (isEdit) {
        await _updateProduct();
      } else {
        await _createProduct();
      }

      if (!mounted) return;
      Navigator.pop(context, true); // kembali + tanda data berubah
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

  Future<void> _createProduct() async {
    if (_userId == null) {
      throw Exception('User belum login / user_id tidak ditemukan');
    }

    final uri = Uri.parse('http://mortava.biz.id/api/products');
    final request = http.MultipartRequest('POST', uri);

    request.fields['name'] = _nameC.text.trim();
    request.fields['category'] = _categoryC.text.trim();
    request.fields['description'] = _descriptionC.text.trim();
    request.fields['price'] = _priceC.text.trim();
    request.fields['offer_price'] = _offerPriceC.text.trim();
    request.fields['user_id'] = _userId!.toString();

    if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      debugPrint('Create product response: $body');
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product created successfully.')));
    } else {
      throw Exception('Gagal membuat produk (${response.statusCode})');
    }
  }

  Future<void> _updateProduct() async {
    final p = widget.product!;
    final uri = Uri.parse('http://mortava.biz.id/api/products/${p.id}');

    final name = _nameC.text.trim();
    final category = _categoryC.text.trim();
    final description = _descriptionC.text.trim();
    final priceText = _priceC.text.trim();
    final offerText = _offerPriceC.text.trim();

    int? price = priceText.isNotEmpty ? int.tryParse(priceText) : null;
    int? offerPrice = offerText.isNotEmpty ? int.tryParse(offerText) : null;

    if (priceText.isNotEmpty && price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Harga harus berupa angka')));
      return;
    }
    if (offerText.isNotEmpty && offerPrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga promo harus berupa angka')),
      );
      return;
    }

    final Map<String, dynamic> payload = {
      'name': name,
      'category': category,
      'description': description,
    };

    if (price != null) payload['price'] = price;
    if (offerPrice != null) payload['offer_price'] = offerPrice;

    debugPrint('Update product payload: $payload');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    debugPrint('Update status: ${response.statusCode}');
    debugPrint('Update body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final body = jsonDecode(response.body);
        debugPrint('Update product response json: $body');
      } catch (_) {}

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully.')),
      );
    } else {
      String msg = 'Gagal update produk (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          msg = body['message'].toString();
        }
      } catch (_) {}

      debugPrint('Update product error: $msg');
      throw Exception(msg);
    }
  }

  InputDecoration _inputDecoration(String label) {
    const borderRadius = 20.0;
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    if (_isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final title = isEdit ? 'Edit product' : 'Add product';
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
                // header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      title,
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
                        colors: [
                          Color(0xFFFF8A65),
                          Color(0xFFFF7043),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // form card
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFFFF5EB),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.16),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFFFD9B3).withOpacity(0.6),
                      width: 1.2,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Preview gambar (create saja yg bisa pilih)
                        if (!isEdit) ...[
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: MortavaColors.bottomNavBorder,
                                  width: 1.2,
                                ),
                                color: Colors.white,
                              ),
                              child: _imageFile != null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(18),
                                      child: Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        'Tap to choose product image',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        TextFormField(
                          controller: _nameC,
                          decoration: _inputDecoration('Product name'),
                          style: GoogleFonts.poppins(fontSize: 14),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _categoryC,
                          decoration: _inputDecoration('Category'),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionC,
                          decoration: _inputDecoration('Description'),
                          style: GoogleFonts.poppins(fontSize: 14),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _priceC,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Price'),
                          style: GoogleFonts.poppins(fontSize: 14),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Wajib diisi'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _offerPriceC,
                          keyboardType: TextInputType.number,
                          decoration:
                              _inputDecoration('Promo price (offer_price)'),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),

                        const SizedBox(height: 22),

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
                                  colors: [
                                    Color(0xFFFFF59D),
                                    Color(0xFFFFEB3B),
                                  ],
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
                                        isEdit
                                            ? 'Save changes'
                                            : 'Create product',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
