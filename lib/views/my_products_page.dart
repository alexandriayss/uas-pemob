// lib/views/my_products_page.dart
//
// My Products Page dengan tema Mortava Shop + MortavaTheme:
// - Background gradient cream–peach (MortavaDecorations.marketplaceBackgroundBox())
// - Header custom (logo + "My Products")
// - Card produk lebih rapi, pakai Poppins, harga pakai MortavaColors.primaryOrange
// - Tombol tambah produk via FloatingActionButton warna primaryOrange

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';
import '../models/order_model.dart'; // 🔥 TAMBAHAN
import '../controllers/product_controller.dart';
import '../controllers/order_controller.dart'; // 🔥 TAMBAHAN
import '../theme/mortava_theme.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> {
  Future<List<Product>>? _futureMyProducts;
  Future<List<OrderModel>>? _futureSales; // 🔥 TAMBAHAN (MY SALES)
  List<Product> _products = []; // ← TAMBAHAN
  int? _userId;

  int _pendingOrderCount = 0; // 🔥 TAMBAHAN INI

  final ProductController _productController = ProductController();
  final OrderController _orderController = OrderController(); // 🔥 TAMBAHAN

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // delay kecil (opsional)
    await Future.delayed(const Duration(milliseconds: 100));

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (!mounted) return;

    setState(() {
      _userId = userId;
      if (userId != null) {
        _futureMyProducts = _productController.fetchMyProducts(userId);

        // 🔥 AMBIL DATA MY SALES (UNTUK BANNER)
        _futureSales = _orderController.fetchSalesForUser(userId);
      } else {
        _futureMyProducts = Future.error(
          Exception('User belum login / user_id tidak ditemukan'),
        );
      }
    });
  }

  Future<void> _refresh() async {
    if (_userId == null) return;
    setState(() {
      _futureMyProducts = _productController.fetchMyProducts(_userId!);
      _futureSales = _orderController.fetchSalesForUser(_userId!); // 🔥 REFRESH SALES
    });
  }

  Future<void> _goToCreate() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CreateEditProductPage()),
    );

    if (!mounted) return;

    if (changed == true) {
      _refresh();
    }
  }

  Future<void> _goToEdit(Product p) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CreateEditProductPage(product: p)),
    );

    if (!mounted) return;

    if (changed == true) {
      _refresh();
    }
  }

  Future<void> _deleteProduct(Product p) async {
    // 🔥 CEK DULU: SUDAH ADA YANG PESAN?
    if (p.status == 'sold' || p.status == 'terjual') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Cannot Remove Product'),
          content: const Text(
            'This product already has an order.\n'
            'You cannot remove a product that has been purchased.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Product'),
        content: Text('Are you sure you want to remove "${p.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 🔥 HIDE PRODUK SECARA LOKAL
    ProductController.hideProductLocally(p.id);

    setState(() {
      _products.removeWhere((item) => item.id == p.id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('"${p.name}" removed')));
  }

  // ===== helper untuk badge status (ID -> EN) =====
  Widget _buildStatusBadge(String? status) {
    if (status == null || status.isEmpty) {
      return const SizedBox.shrink();
    }

    String label;
    Color fg;
    Color bg;

    if (status == 'tersedia') {
      label = 'Available';
      fg = Colors.green;
      bg = Colors.green.withOpacity(0.10);
    } else if (status == 'terjual') {
      label = 'Sold';
      fg = Colors.grey.shade700;
      bg = Colors.grey.withOpacity(0.15);
    } else {
      // fallback kalau backend kirim value lain
      label = status;
      fg = Colors.grey.shade700;
      bg = Colors.grey.withOpacity(0.15);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: fg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tidak pakai AppBar bawaan, diganti header custom + background Mortava
      body: Container(
        decoration: MortavaDecorations.marketplaceBackgroundBox(),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ================= HEADER =================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 26),
                  const SizedBox(width: 8),
                  Text(
                    'My Products',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: MortavaColors.darkText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 🔥 HITUNG PENDING ORDER DARI MY SALES (BENAR)
              FutureBuilder<List<OrderModel>>(
                future: _futureSales,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  final int pending = snapshot.data!
                      .where(
                        (o) =>
                            o.status.toLowerCase() == 'pending' ||
                            o.status.toLowerCase() == 'processing' ||
                            o.status.toLowerCase() == 'dikirim' ||
                            o.status.toLowerCase() == 'shipped',
                      )
                      .length;

                  if (_pendingOrderCount != pending) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _pendingOrderCount = pending;
                        });
                      }
                    });
                  }

                  return const SizedBox.shrink();
                },
              ),

              // 🔥 BANNER INFO PESANAN (SELALU DI ATAS)
              if (_pendingOrderCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You have $_pendingOrderCount orders that are still being processed',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ================= LIST PRODUK =================
              Expanded(
                child: (_futureMyProducts == null)
                    ? const Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<Product>>(
                        future: _futureMyProducts,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Error: ${snapshot.error}',
                                style: GoogleFonts.poppins(),
                              ),
                            );
                          }

                          final allProducts = snapshot.data ?? [];

                          // 🔥 PRODUK YANG BOLEH TAMPIL DI MY PRODUCTS
                          final List<Product> products = allProducts
                              .where(
                                (p) =>
                                    p.status != 'ordered' &&
                                    p.status != 'processing' &&
                                    p.status != 'shipped',
                              )
                              .toList();

                          if (products.isEmpty) {
                            return Center(
                              child: Text(
                                'You don\'t have any products yet.',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _refresh,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(14),
                              itemCount: products.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final p = products[index];

                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
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
                                        color: Colors.orange.withOpacity(0.10),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                    border: Border.all(
                                      color: const Color(
                                        0xFFFFD9B3,
                                      ).withOpacity(0.6),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Thumbnail
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                          left: Radius.circular(20),
                                        ),
                                        child: SizedBox(
                                          height: 90,
                                          width: 90,
                                          child: p.image != null &&
                                                  p.image!.isNotEmpty
                                              ? Image.network(
                                                  p.image!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) =>
                                                          const Icon(
                                                    Icons.image_not_supported,
                                                  ),
                                                )
                                              : const Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 32,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Info produk
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ProductDetailPage(
                                                    productId: p.id,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  p.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                if (p.category != null)
                                                  Text(
                                                    p.category!,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color:
                                                          Colors.grey[600],
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                if (p.offerPrice != null)
                                                  Text(
                                                    'Rp ${p.offerPrice}',
                                                    style:
                                                        GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: MortavaColors
                                                          .primaryOrange,
                                                    ),
                                                  )
                                                else if (p.price != null)
                                                  Text(
                                                    'Rp ${p.price}',
                                                    style:
                                                        GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: MortavaColors
                                                          .primaryOrange,
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),

                                                // status badge (sudah di-translate)
                                                _buildStatusBadge(p.status),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Aksi edit / delete
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _goToEdit(p),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _deleteProduct(p),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreate,
        backgroundColor: MortavaColors.primaryOrange,
        child: const Icon(Icons.add),
      ),
    );
  }
}
