import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product_model.dart';
import '../controllers/product_controller.dart';

import '../theme/mortava_theme.dart';
import 'product_detail_page.dart';
import 'profile_page.dart';
import 'my_products_page.dart';
import 'my_orders_page.dart';
import 'my_sales_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _BerandaPage(),
    MyOrdersPage(),
    MyProductsPage(),
    MySalesPage(),
    _ProfilUserPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: Container(
        decoration: MortavaDecorations.bottomNavBox(),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            elevation: 0,
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: MortavaColors.primaryOrange,
            unselectedItemColor: const Color(0x995D4037),
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: 'My Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2),
                label: 'My Products',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sell),
                label: 'My Sales',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
          ),
        ),
      ),
    );
  }
}

// BERANDA (GRID + SEARCH + FILTER HARGA)
class _BerandaPage extends StatefulWidget {
  const _BerandaPage();

  @override
  State<_BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<_BerandaPage> {
  Future<List<Product>>? _futureProducts;

  final ProductController _productController = ProductController();

  PriceRange _selectedPriceRange = PriceRange.all;
  final TextEditingController _searchC = TextEditingController();
  String _searchQuery = '';

  static const _softBorder = MortavaColors.bottomNavBorder;

  @override
  void initState() {
    super.initState();

    _futureProducts = _productController.fetchProductsFiltered(
      searchQuery: _searchQuery,
      priceRange: _selectedPriceRange,
    );
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  // Reload produk dengan filter terbaru
  void _reloadProducts() {
    setState(() {
      _futureProducts = _productController.fetchProductsFiltered(
        searchQuery: _searchQuery,
        priceRange: _selectedPriceRange,
      );
    });
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

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', height: 28),
                  const SizedBox(width: 8),
                  Text(
                    'Marketplace',
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
                width: 120,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF176), Color(0xFFFFB74D)],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: TextField(
                  controller: _searchC,
                  onChanged: (v) {
                    _searchQuery = v.trim();
                    _reloadProducts();
                  },
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search product name...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: _softBorder,
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: _softBorder,
                        width: 1.6,
                      ),
                    ),
                  ),
                ),
              ),

              // Filter harga
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    _chip(PriceRange.all, "All"),
                    const SizedBox(width: 6),
                    _chip(PriceRange.zeroTo50k, "0 - 50k"),
                    const SizedBox(width: 6),
                    _chip(PriceRange.fiftyTo100k, "50k - 100k"),
                    const SizedBox(width: 6),
                    _chip(PriceRange.above100k, "100k+"),
                  ],
                ),
              ),

              // Produk grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.18),
                          blurRadius: 24,
                          spreadRadius: -4,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: FutureBuilder<List<Product>>(
                      future:
                          _futureProducts ??
                          _productController.fetchProductsFiltered(
                            searchQuery: _searchQuery,
                            priceRange: _selectedPriceRange,
                          ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final products = snapshot.data ?? [];

                        if (products.isEmpty) {
                          return Center(
                            child: Text(
                              'No products found',
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.72,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: products.length,
                          itemBuilder: (c, i) {
                            return InkWell(
                              onTap: () async {
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailPage(
                                      productId: products[i].id,
                                    ),
                                  ),
                                );

                                if (result == true && mounted) {
                                  setState(() {
                                    _reloadProducts(); // refresh produk setelah pembelian
                                  });
                                }
                              },
                              child: _ProductCard(product: products[i]),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(PriceRange value, String label) {
    final bool selected = _selectedPriceRange == value;

    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: selected ? Colors.brown[800] : Colors.brown[400],
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFFFFF8E1),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? Colors.orange : Colors.orange.shade200,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) {
        _selectedPriceRange = value;
        _reloadProducts();
      },
    );
  }
}

// CARD PRODUK 
class _ProductCard extends StatelessWidget {
  final Product product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    String format(num? v) => v == null ? '-' : 'Rp $v';

    final bool hasDiscount =
        product.offerPrice != null &&
        product.price != null &&
        product.offerPrice! < product.price!;

    return Container(
      decoration: MortavaDecorations.productOuterCardBox(),
      child: Container(
        margin: const EdgeInsets.all(1.2),
        decoration: MortavaDecorations.productInnerCardBox(),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Gambar
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: (product.image != null && product.image!.isNotEmpty)
                        ? Image.network(
                            product.image!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFF59D), Color(0xFFFFB74D)],
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 35,
                              ),
                            ),
                          ),
                  ),

                  // BADGE kategori
                  if (product.category != null && product.category!.isNotEmpty)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.45),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.label_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              product.category!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // BADGE SALE
                  if (hasDiscount)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFF7043), Color(0xFFFFC107)],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "SALE",
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info Produk
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: MortavaColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        format(product.offerPrice ?? product.price),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: MortavaColors.primaryOrange,
                        ),
                      ),
                      if (hasDiscount)
                        Text(
                          format(product.price),
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 13,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "Tap to see details",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PROFIL WRAPPER 
class _ProfilUserPage extends StatelessWidget {
  const _ProfilUserPage();

  @override
  Widget build(BuildContext context) {
    return const ProfilePage();
  }
}
