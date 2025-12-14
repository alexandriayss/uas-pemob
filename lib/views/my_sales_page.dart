// lib/views/my_sales_page.dart
//
// My Sales Page dengan tema Mortava Shop + MortavaTheme:
// - Background gradient cream–peach (MortavaDecorations.marketplaceBackgroundBox())
// - Header custom (logo + "My Sales")
// - Card penjualan pakai gradient & shadow lembut, font Poppins
// - Teks dibuat bahasa Inggris agar konsisten dengan halaman lain

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';
import '../models/product_model.dart';
import '../controllers/order_controller.dart';
import '../controllers/product_controller.dart';
import '../theme/mortava_theme.dart';
import 'order_detail_page.dart';

class MySalesPage extends StatefulWidget {
  const MySalesPage({super.key});

  @override
  State<MySalesPage> createState() => _MySalesPageState();
}

class _MySalesPageState extends State<MySalesPage> {
  Future<List<OrderModel>>? _futureSales;

  final OrderController _orderController = OrderController();
  final ProductController _productController = ProductController();

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
        _futureSales = Future.error('User is not logged in');
      });
      return;
    }

    setState(() {
      _futureSales = _orderController.fetchSalesForUser(id);
    });
  }

  // Badge status order (Pending / Completed / Canceled dll.)
  Widget _statusBadge(String s) {
    final status = s.toLowerCase().trim();

    late Color bg, text;
    late String label;

    switch (status) {
      case 'pending':
        label = 'Pending';
        bg = Colors.orange.shade100;
        text = Colors.orange.shade800;
        break;

      case 'dikirim':
        label = 'Shipped';
        bg = Colors.blue.shade100;
        text = Colors.blue.shade800;
        break;

      case 'success':
        label = 'Completed';
        bg = Colors.green.shade100;
        text = Colors.green.shade800;
        break;

      default:
        label = s;
        bg = Colors.grey.shade200;
        text = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'My Sales',
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
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _futureSales == null
                    ? const Center(child: CircularProgressIndicator())
                    : FutureBuilder<List<OrderModel>>(
                        future: _futureSales,
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

                          final sales = snapshot.data ?? [];

                          if (sales.isEmpty) {
                            return Center(
                              child: Text(
                                'You have no sales yet.',
                                style: GoogleFonts.poppins(fontSize: 13),
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.all(14),
                            itemCount: sales.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final o = sales[index];

                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
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
                                      color: Colors.orange.withOpacity(0.12),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFFD9B3,
                                    ).withOpacity(0.55),
                                    width: 1.2,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(22),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            OrderDetailPage(orderId: o.id),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Top row: Buyer + Status
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (o.buyerUsername != null &&
                                                o.buyerUsername!.isNotEmpty)
                                              Text(
                                                'Buyer: ${o.buyerUsername!}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(
                                                    0xFF4A3424,
                                                  ),
                                                ),
                                              )
                                            else
                                              Text(
                                                'Buyer: -',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(
                                                    0xFF4A3424,
                                                  ),
                                                ),
                                              ),
                                            _statusBadge(o.status),
                                          ],
                                        ),

                                        const SizedBox(height: 10),

                                        // Info produk terjual
                                        FutureBuilder<Product>(
                                          future: _productController
                                              .getProductByIdCached(
                                                o.productId,
                                              ),
                                          builder: (context, snap) {
                                            if (snap.connectionState ==
                                                ConnectionState.waiting) {
                                              return Text(
                                                'Loading product info...',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              );
                                            }

                                            if (snap.hasError ||
                                                !snap.hasData) {
                                              return Text(
                                                'Product #${o.productId}',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              );
                                            }

                                            final p = snap.data!;
                                            return Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: SizedBox(
                                                    width: 70,
                                                    height: 70,
                                                    child:
                                                        (p.image != null &&
                                                            p.image!.isNotEmpty)
                                                        ? Image.network(
                                                            p.image!,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (
                                                                  _,
                                                                  __,
                                                                  ___,
                                                                ) => const Icon(
                                                                  Icons
                                                                      .image_not_supported,
                                                                ),
                                                          )
                                                        : const Icon(
                                                            Icons.image,
                                                            size: 32,
                                                          ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        p.name,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (p.offerPrice != null)
                                                        Text(
                                                          'Rp ${p.offerPrice}',
                                                          style: GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: MortavaColors
                                                                .primaryOrange,
                                                          ),
                                                        )
                                                      else if (p.price != null)
                                                        Text(
                                                          'Rp ${p.price}',
                                                          style: GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: MortavaColors
                                                                .primaryOrange,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),

                                        const SizedBox(height: 14),

                                        // Info order
                                        Text(
                                          'Order #${o.id}',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (o.totalPrice != null)
                                          Text(
                                            'Total: Rp ${o.totalPrice}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                            ),
                                          ),
                                        Text(
                                          'Payment: ${o.paymentMethod.toUpperCase()}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'Status: ${o.status}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        if (o.status.toLowerCase() == 'pending')
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                              ),
                                              onPressed: () async {
                                                // Ambil sellerId dulu (async BOLEH di sini)
                                                final prefs =
                                                    await SharedPreferences.getInstance();
                                                final sellerId =
                                                    o.userJual ??
                                                    prefs.getInt('user_id');

                                                if (sellerId == null) return;

                                                // Panggil backend
                                                await _orderController
                                                    .shipOrder(o.id);

                                                // Baru update state (TANPA await)
                                                setState(() {
                                                  _futureSales =
                                                      _orderController
                                                          .fetchSalesForUser(
                                                            sellerId,
                                                          );
                                                });
                                              },
                                              child: const Text(
                                                'Order shipped',
                                              ),
                                            ),
                                          ),

                                        const SizedBox(height: 6),

                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
