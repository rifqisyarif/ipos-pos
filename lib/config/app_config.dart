import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  /// Base URL for API calls, loaded from .env file
  static String get baseUrl => dotenv.get(
        'BASE_URL',
        fallback: 'https://api.yourrestaurant.com',
      );
}
