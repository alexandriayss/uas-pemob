// lib/views/my_orders_page.dart
//
// My Orders Page dengan tema Mortava Shop:
// - Background pakai MortavaDecorations.marketplaceBackgroundBox()
// - Header teks pakai MortavaColors.darkText
// - Harga produk pakai MortavaColors.primaryOrange
// - Card masih mempertahankan gradient lembut yang sama

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_model.dart';
import '../models/product_model.dart';
import '../controllers/order_controller.dart';
import '../controllers/product_controller.dart';
import '../theme/mortava_theme.dart';
import 'order_detail_page.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  Future<List<OrderModel>>? _futureOrders;

  final OrderController _orderController = OrderController();
  final ProductController _productController = ProductController();

  @override
  void initState() {
    super.initState();
    _loadUserAndOrders();
  }

  Future<void> _loadUserAndOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (!mounted) return;

    if (userId == null) {
      setState(() {
        _futureOrders = Future.error('User belum login');
      });
      return;
    }

    setState(() {
      _futureOrders = _orderController.fetchOrdersForUser(userId);
    });
  }

  // Badge Status
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
        borderRadius: BorderRadius.circular(50),
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
      // BACKGROUND GRADIENT dari MortavaTheme
      body: Container(
        decoration: MortavaDecorations.marketplaceBackgroundBox(),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/logo.png", height: 26),
                  const SizedBox(width: 8),
                  Text(
                    "My Orders",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: MortavaColors.darkText,
                    ),
                  ),
                ],
              ),

              Container(
                margin: const EdgeInsets.only(top: 6, bottom: 10),
                height: 3,
                width: 90,
                decoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              Expanded(
                child: FutureBuilder<List<OrderModel>>(
                  future: _futureOrders,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final orders = snapshot.data ?? [];

                    if (orders.isEmpty) {
                      return const Center(
                        child: Text("You have no orders yet."),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(14),
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final o = orders[index];

                        return Card(
                          elevation: 4,
                          shadowColor: Colors.orange.withOpacity(0.12),
                          color: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),

                              // BORDER lembut
                              border: Border.all(
                                color: const Color(
                                  0xFFFFD9B3,
                                ).withOpacity(0.55),
                                width: 1.2,
                              ),

                              // GRADIENT CARD lembut (dipertahankan)
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFFFFFF), Color(0xFFFFF5EB)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.12),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                              ],
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // TOP ROW (Seller + Status Badge)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Seller: ${o.sellerUsername}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF4A3424),
                                          ),
                                        ),
                                        _statusBadge(o.status),
                                      ],
                                    ),

                                    const SizedBox(height: 12),

                                    // Product info
                                    FutureBuilder<Product>(
                                      future: _productController
                                          .getProductByIdCached(o.productId),
                                      builder: (context, snap) {
                                        if (snap.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Text(
                                            "Loading product...",
                                          );
                                        }

                                        if (!snap.hasData) {
                                          return const Text("Unknown product");
                                        }

                                        final p = snap.data!;

                                        return Row(
                                          children: [
                                            // Product Image
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: SizedBox(
                                                width: 70,
                                                height: 70,
                                                child: Image.network(
                                                  p.image ?? "",
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // Product info
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.name,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Rp ${p.offerPrice ?? p.price}",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
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

                                    const SizedBox(height: 16),

                                    // ORDER DETAILS
                                    Text(
                                      "Order #${o.id}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    if (o.totalPrice != null)
                                      Text(
                                        "Total: Rp ${o.totalPrice}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                      ),
                                    Text(
                                      "Payment: ${o.paymentMethod.toUpperCase()}",
                                      style: GoogleFonts.poppins(fontSize: 13),
                                    ),

                                    const SizedBox(height: 10),

                                    if (o.status.toLowerCase() == 'dikirim')
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          onPressed: () async {
                                            final prefs =
                                                await SharedPreferences.getInstance();
                                            final userId = prefs.getInt(
                                              'user_id',
                                            );

                                            if (userId == null) return;

                                            await _orderController
                                                .completeOrder(o.id);

                                            setState(() {
                                              _futureOrders = _orderController
                                                  .fetchOrdersForUser(userId);
                                            });
                                          },

                                          child: const Text('Order completed'),
                                        ),
                                      ),

                                    const SizedBox(height: 10),

                                    Text(
                                      "Shipping address",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),

                                    Text(o.shippingStreet ?? "-"),
                                    Text(
                                      "${o.shippingCity}, ${o.shippingState}",
                                    ),
                                    Text(
                                      "${o.shippingPostalCode}, ${o.shippingCountry}",
                                    ),
                                    Text("Phone: ${o.shippingPhone ?? '-'}"),

                                    const SizedBox(height: 10),

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
