import 'package:my_prescription_app/services/api_service.dart';
import 'package:my_prescription_app/services/llm_service.dart';
import 'package:my_prescription_app/services/mock_api_service.dart';
import 'package:my_prescription_app/services/mock_llm_service.dart';
import 'package:my_prescription_app/services/location_service_interface.dart';
import 'package:my_prescription_app/services/location_service.dart';
import 'package:my_prescription_app/services/mock_location_service.dart';
import 'package:my_prescription_app/services/cart_service.dart';

/// A class to provide the correct service implementation based on environment
class ServiceProvider {
  // Set to true for testing with mock services
  static const bool useMockServices = false;

  static final _cartService = CartService();
  static CartService getCartService() => _cartService;

  // API Service for prescription detection
  static getApiService() {
    if (useMockServices) {
      return MockApiService();
    } else {
      return ApiService();
    }
  }

  // LLM Service for medicine information
  static getLlmService() {
    if (useMockServices) {
      return MockLlmService();
    } else {
      return GeminiService();
    }
  }

  // Location Service for getting user's location
  static LocationService getLocationService() {
    if (useMockServices) {
      return MockLocationService();
    } else {
      return RealLocationService();
    }
  }

  // Method to get the mock location service specifically (for testing)
  static MockLocationService? getMockLocationService() {
    if (useMockServices) {
      return getLocationService() as MockLocationService;
    }
    return null;
  }
}
