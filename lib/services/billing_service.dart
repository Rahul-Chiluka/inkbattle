import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';

class BillingService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static late StreamSubscription<List<PurchaseDetails>> _subscription;
  static Function(PurchaseDetails)? _onSuccess;
  static Function(String)? _onError;

  static void init({
    required Function(PurchaseDetails) onSuccess,
    Function(String)? onError,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased) {
          _onSuccess?.call(purchase);
          _iap.completePurchase(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          final error = purchase.error?.message ?? 'Unknown purchase error';
          _onError?.call(error);
          _iap.completePurchase(purchase);
        } else if (purchase.status == PurchaseStatus.pending) {
          // Purchase is pending, wait for it to complete
          print('Purchase pending: ${purchase.productID}');
        } else if (purchase.status == PurchaseStatus.restored) {
          // Handle restored purchases if needed
          _iap.completePurchase(purchase);
        }
      }
    });
  }

  static Future<void> buy(String productId) async {
    try {
      // Check platform support
      if (!Platform.isAndroid && !Platform.isIOS) {
        _onError?.call('In-app purchases are only supported on Android and iOS devices.');
        return;
      }
      
      final platformName = Platform.isAndroid ? 'Google Play' : 'App Store';
      print('Querying product details from $platformName for product ID: $productId');
      
      final response = await _iap.queryProductDetails({productId});

      if (response.error != null) {
        final errorMsg = response.error!.message;
        print('Error querying product: $errorMsg');
        _onError?.call('Failed to load product from $platformName: $errorMsg');
        return;
      }

      if (response.productDetails.isEmpty) {
        print('Product not found: $productId on $platformName');
        _onError?.call('Product "$productId" not found in $platformName. Please ensure the product is configured correctly.');
        return;
      }

      final productDetails = response.productDetails.first;
      print('Product found: ${productDetails.title} - ${productDetails.price}');
      
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      print('Initiating purchase...');
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      final platformName = Platform.isAndroid ? 'Google Play' : 'App Store';
      print('Exception during purchase: $e');
      _onError?.call('Failed to initiate purchase on $platformName: $e');
    }
  }

  static void dispose() {
    _subscription.cancel();
    _onSuccess = null;
    _onError = null;
  }
}
