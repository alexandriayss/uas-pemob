import '../models/product_model.dart';
import '../services/product_service.dart';

/// Enum untuk filter range harga di marketplace
enum PriceRange { all, zeroTo50k, fiftyTo100k, above100k }

class ProductController {
  final ProductService _service = ProductService();

  // Beranda (all products)
  Future<List<Product>> fetchProducts() {
    return _service.getAllProducts();
  }

  // Produk milik user (My Products)
  Future<List<Product>> fetchMyProducts(int userId) async {
    final all = await _service.getMyProducts(userId);

    return all.where((p) {
      // benar-benar dihapus
      if (p.status == 'deleted') return false;

      // sedang diproses pembeli (tidak boleh diutak-atik seller)
      if (p.status == 'ordered' ||
          p.status == 'procegit statusssing' ||
          p.status == 'shipped') {
        return false;
      }

      // hide lokal (delete manual oleh user)
      if (ProductController.isProductHidden(p.id) && p.status != 'terjual') {
        return false;
      }

      // available + sold tampil
      return true;
    }).toList();
  }

  // Hapus produk milik user
  Future<void> deleteMyProduct(int productId) {
    return _service.deleteProduct(productId);
  }

  // CACHE produk by ID (dipakai di MyOrders)
  final Map<int, Future<Product>> _productFutures = {};

  Future<Product> getProductByIdCached(int productId) {
    _productFutures.putIfAbsent(
      productId,
      () => _service.getProductById(productId),
    );
    return _productFutures[productId]!;
  }

  // Product Detail
  Future<Product> getProductDetail(int productId) {
    return _service.getProductById(productId);
  }

  //  Fetch produk untuk marketplace dengan filter search + range harga
  Future<List<Product>> fetchProductsFiltered({
    String searchQuery = '',
    PriceRange priceRange = PriceRange.all,
  }) async {
    // Ambil semua produk dari service
    final List<Product> all = await _service.getAllProducts();

    final q = searchQuery.toLowerCase();

    num _getPrice(Product p) {
      return (p.offerPrice ?? p.price ?? 0);
    }

    return all.where((p) {
      // Filter nama (search)
      final nameMatch = q.isEmpty || p.name.toLowerCase().contains(q);

      // Filter range harga
      final price = _getPrice(p);
      bool priceMatch;
      switch (priceRange) {
        case PriceRange.zeroTo50k:
          priceMatch = price >= 0 && price <= 50000;
          break;
        case PriceRange.fiftyTo100k:
          priceMatch = price > 50000 && price <= 100000;
          break;
        case PriceRange.above100k:
          priceMatch = price > 100000;
          break;
        case PriceRange.all:
          priceMatch = true;
          break;
      }

      // produk yang sudah dibeli / habis tidak muncul di marketplace
      // produk dianggap tersedia kalau: status = null / tersedia / available
      final bool isAvailable =
          p.status == null || p.status == 'tersedia' || p.status == 'available';

      // produk yang di-hide secara lokal tidak muncul di marketplace
      if (ProductController.isProductHidden(p.id)) return false;

      return nameMatch && priceMatch && isAvailable;
    }).toList();
  }

  // // Soft delete product (ubah status jadi deleted)
  static final Set<int> _hiddenProductIds = {};

  // dipanggil saat user "hapus" produk
  static void hideProductLocally(int productId) {
    _hiddenProductIds.add(productId);
  }

  static bool isProductHidden(int productId) {
    return _hiddenProductIds.contains(productId);
  }
}
