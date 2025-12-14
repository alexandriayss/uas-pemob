// lib/controllers/order_controller.dart
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderController {
  final OrderService _service = OrderService();

  // My Orders
  Future<List<OrderModel>> fetchOrdersForUser(int userId) {
    return _service.getOrdersForUser(userId);
  }

  // My Sales
  Future<List<OrderModel>> fetchSalesForUser(int userId) {
    return _service.getSalesForUser(userId);
  }

  // DETAIL ORDER
  Future<OrderModel> fetchOrderDetail(int orderId) {
    return _service.getOrderDetail(orderId);
  }

  // BUAT ORDER BARU
  Future<String> createOrder({
    required int userId,
    required int productId,
    required String shippingPhone,
    required String shippingStreet,
    required String shippingCity,
    required String shippingState,
    required String shippingPostalCode,
    required String shippingCountry,
    required String paymentMethod,
  }) {
    return _service.createOrder(
      userId: userId,
      productId: productId,
      shippingPhone: shippingPhone,
      shippingStreet: shippingStreet,
      shippingCity: shippingCity,
      shippingState: shippingState,
      shippingPostalCode: shippingPostalCode,
      shippingCountry: shippingCountry,
      paymentMethod: paymentMethod,
    );
  }
  
  Future<void> completeOrder(int orderId) {
    return _service.completeOrder(orderId);
  }

  Future<void> shipOrder(int orderId) {
    return _service.shipOrder(orderId);
  }
}
