import 'package:intl/intl.dart';

class Formatters {
  static final _currency =
      NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  static String price(double amount) => _currency.format(amount);

  static String priceModifier(double mod) =>
      mod == 0 ? 'Free' : '+${price(mod)}';
}
