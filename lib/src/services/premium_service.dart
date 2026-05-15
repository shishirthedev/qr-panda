import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kPremiumProductId = 'remove_ads';
const _kPremiumKey = 'is_premium';

class PremiumService {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  final ValueNotifier<bool> isPremiumNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isPurchasingNotifier = ValueNotifier(false);
  final ValueNotifier<String?> priceNotifier = ValueNotifier(null);

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _productDetails;
  bool _initialized = false;

  bool get isPremium => isPremiumNotifier.value;

  /// Returns the localised price string from the store (e.g. "$3.99"),
  /// or null while still loading.
  String? get localizedPrice => priceNotifier.value;

  /// Call once from main() before runApp.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_kPremiumKey); // null / true / false

    if (stored == true) {
      isPremiumNotifier.value = true;
      _listenToPurchaseStream(); // still listen so completePurchase() works
      return;
    }

    // null or false → restore to catch cross-device purchases
    if (stored == false) {
      isPremiumNotifier.value = false;
    }

    // Fetch product details (price) regardless of premium state
    fetchProductDetails();

    _listenToPurchaseStream();
    await _restore();
  }

  Future<void> fetchProductDetails() async {
    priceNotifier.value = null; // reset so UI shows loader
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return;
    final response = await InAppPurchase.instance
        .queryProductDetails({kPremiumProductId});
    if (response.productDetails.isNotEmpty) {
      _productDetails = response.productDetails.first;
      priceNotifier.value = _productDetails!.price;
    }
  }

  void _listenToPurchaseStream() {
    _subscription?.cancel();
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (_) {},
    );
  }

  Future<void> _restore() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      await _savePremium(false);
      return;
    }
    await InAppPurchase.instance.restorePurchases();
    // Results arrive in purchaseStream — if nothing comes back within 3s,
    // treat as not purchased.
    await Future.delayed(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kPremiumKey) == null) {
      await _savePremium(false);
    }
  }

  /// Called from UI when user taps "Unlock Premium".
  Future<void> purchase() async {
    // Use cached product details; re-fetch if not yet loaded
    if (_productDetails == null) {
      await fetchProductDetails();
    }
    if (_productDetails == null) return;

    isPurchasingNotifier.value = true;
    final purchaseParam = PurchaseParam(productDetails: _productDetails!);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != kPremiumProductId) continue;

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _savePremium(true);
        isPurchasingNotifier.value = false;
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        isPurchasingNotifier.value = false;
        // Only save false if we've never stored a value (i.e. during auto-restore)
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getBool(_kPremiumKey) == null) {
          await _savePremium(false);
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        isPurchasingNotifier.value = false;
      }
    }
  }

  Future<void> _savePremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPremiumKey, value);
    isPremiumNotifier.value = value;
  }

  void dispose() {
    _subscription?.cancel();
    isPremiumNotifier.dispose();
    isPurchasingNotifier.dispose();
  }
}
