import 'dart:convert';
import 'package:coach_life/model/course.dart';
import 'package:coach_life/services/shared_preferances_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartManager {
  static const String _cartKey = 'cart_courses';

  /// Retrieves all courses in the cart.
  Future<List<Course>> getCartItems() async {
    final prefs = SharedPreferencesManager.instance!;
    final String? cartJson = prefs.getString(_cartKey);
    if (cartJson != null) {
      final List<dynamic> decoded = json.decode(cartJson);
      return decoded.map((item) => Course.fromJson(item)).toList();
    }
    return [];
  }

  /// Adds a course to the cart.
  Future<void> addToCart(Course course) async {
    final prefs = SharedPreferencesManager.instance!;
    List<Course> cart = await getCartItems();

    // Optionally: check if course already exists to prevent duplicates
    if (!cart.any((c) => c.id == course.id)) {
      cart.add(course);
      final String cartJson = json.encode(cart.map((c) => c.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    }
  }

  /// Removes a course from the cart using its ID.
  Future<void> removeFromCart(int courseId) async {
    final prefs = SharedPreferencesManager.instance!;
    List<Course> cart = await getCartItems();
    cart.removeWhere((course) => int.parse(course.id) == courseId);
    final String cartJson = json.encode(cart.map((c) => c.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }

  /// Clears the entire cart.
  Future<void> clearCart() async {
    final prefs = SharedPreferencesManager.instance!;
    await prefs.remove(_cartKey);
  }
}
