import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/order_model.dart';
import '../models/product_model.dart';
import '../controllers/order_controller.dart';
import '../controllers/product_controller.dart';
import '../theme/mortava_theme.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Future<OrderModel> _futureOrder;

  final OrderController _orderController = OrderController();
  final ProductController _productController = ProductController();

  @override
  void initState() {
    super.initState();
    _futureOrder = _orderController.fetchOrderDetail(widget.orderId);
  }

  String _formatPrice(num? value) {
    if (value == null) return '-';
    return 'Rp ${value.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: MortavaDecorations.marketplaceBackgroundBox(),
        child: SafeArea(
          child: FutureBuilder<OrderModel>(
            future: _futureOrder,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: GoogleFonts.poppins(),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return Center(
                  child: Text(
                    'Order not found',
                    style: GoogleFonts.poppins(),
                  ),
                );
              }

              final o = snapshot.data!;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final bottomInset = MediaQuery.of(context).padding.bottom;

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 14,
                      bottom: 24 + bottomInset,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight - (14 + 24 + bottomInset),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ============== HEADER ==============
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Order Details',
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
                              width: 120,
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
                          const SizedBox(height: 18),

                          // Content card
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
                                color:
                                    const Color(0xFFFFD9B3).withOpacity(0.6),
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // produk
                                FutureBuilder<Product>(
                                  future: _productController
                                      .getProductDetail(o.productId),
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

                                    if (snap.hasError || !snap.hasData) {
                                      return Text(
                                        'Product #${o.productId}',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      );
                                    }

                                    final p = snap.data!;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(22),
                                          child: SizedBox(
                                            height: 230,
                                            width: double.infinity,
                                            child: Container(
                                              color: Colors.white,
                                              child: (p.image != null &&
                                                      p.image!.isNotEmpty)
                                                  ? Image.network(
                                                      p.image!,
                                                      fit: BoxFit.contain,
                                                      errorBuilder:
                                                          (_, __, ___) =>
                                                              const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                    )
                                                  : const Center(
                                                      child: Icon(
                                                        Icons.image,
                                                        size: 40,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          p.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: MortavaColors.darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatPrice(
                                              p.offerPrice ?? p.price),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                MortavaColors.primaryOrange,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 18),
                                Divider(
                                  color: Colors.grey.shade400,
                                  height: 24,
                                ),

                                // seller & buyer
                                if (o.sellerUsername != null &&
                                    o.sellerUsername!.isNotEmpty) ...[
                                  Text(
                                    'Seller',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    o.sellerUsername!,
                                    style:
                                        GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                if (o.buyerUsername != null &&
                                    o.buyerUsername!.isNotEmpty) ...[
                                  Text(
                                    'Buyer',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    o.buyerUsername!,
                                    style:
                                        GoogleFonts.poppins(fontSize: 13),
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                // order info
                                Text(
                                  'Order Info',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Order ID: #${o.id}',
                                  style:
                                      GoogleFonts.poppins(fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${o.status}',
                                  style:
                                      GoogleFonts.poppins(fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Payment method: ${o.paymentMethod.toUpperCase()}',
                                  style:
                                      GoogleFonts.poppins(fontSize: 13),
                                ),
                                if (o.totalPrice != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Total amount: ${_formatPrice(o.totalPrice)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 18),
                                Divider(
                                  color: Colors.grey.shade400,
                                  height: 24,
                                ),

                                // shipping address
                                Text(
                                  'Shipping address',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (o.shippingStreet != null &&
                                    o.shippingStreet!.isNotEmpty)
                                  Text(
                                    o.shippingStreet!,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13),
                                  ),
                                if (o.shippingCity != null ||
                                    o.shippingState != null)
                                  Text(
                                    '${o.shippingCity ?? ''}'
                                    '${o.shippingCity != null && o.shippingState != null ? ', ' : ''}'
                                    '${o.shippingState ?? ''}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13),
                                  ),
                                if (o.shippingPostalCode != null ||
                                    o.shippingCountry != null)
                                  Text(
                                    '${o.shippingPostalCode ?? ''}'
                                    '${o.shippingPostalCode != null && o.shippingCountry != null ? ', ' : ''}'
                                    '${o.shippingCountry ?? ''}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13),
                                  ),
                                if (o.shippingPhone != null &&
                                    o.shippingPhone!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Phone: ${o.shippingPhone}',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}