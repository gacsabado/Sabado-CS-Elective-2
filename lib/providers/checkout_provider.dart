import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/checkout_service.dart';

final checkoutServiceProvider = Provider<CheckoutService>((ref) {
  return CheckoutService();
});
