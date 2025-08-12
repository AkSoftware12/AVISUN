import 'package:upgrader/upgrader.dart';

class UpgraderConfig {
  static Upgrader getUpgrader() {
    return Upgrader(
      // Configuration for production
      debugLogging: false, // Disable debug logging in production
      
      // Set the minimum days between showing alerts
      durationUntilAlertAgain: Duration(days: 1),
      
      // Country code for app store (change based on your primary market)
      countryCode: 'IN', // Set to 'US' if targeting US market primarily
      
      // Language code
      languageCode: 'en',
      
      // Optional: Set minimum app version that requires update
      // minAppVersion: '1.0.0',
      
      // Optional: Force users to update if critical update
      // canDismissDialog: false, // Uncomment for force update
      
      // Client configuration for app stores - using default client
      
      // Messages customization (optional)
      messages: UpgraderMessages(
        code: 'en',
      ),
    );
  }
  
  // Custom upgrader for testing (with debug enabled)
  static Upgrader getTestUpgrader() {
    return Upgrader(
      debugLogging: true,
      debugDisplayAlways: true, // Only for testing
      durationUntilAlertAgain: Duration(seconds: 10), // Short duration for testing
      countryCode: 'IN',
      languageCode: 'en',
    );
  }
}
