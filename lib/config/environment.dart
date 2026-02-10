import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  // For Android Emulator with adb reverse, use localhost
  // Run: adb reverse tcp:4000 tcp:4000
  // For iOS Simulator, also use localhost
  static const String apiBaseUrl = "https://inkbattle.in/api";
  static const String socketUrl = "https://inkbattle.in";
  static const String appSecret = "InkBattle_Secure_2024"; // match Nginx exactly
  static const int dailyCoinsAwarded = 1000;

  // static const String apiBaseUrl =
  //     "http://ec2-35-154-241-0.ap-south-1.compute.amazonaws.com:4000/api";
  // static const String socketUrl =
  //     "http://ec2-35-154-241-0.ap-south-1.compute.amazonaws.com:4000";


// static const String apiBaseUrl = "http://192.168.1.6:4000/api";
// static const String socketUrl = "http://192.168.1.6:4000";

  // static const String apiBaseUrl =
  //     "https://inkbattle-a-backend.onrender.com/api";
  // static const String socketUrl = "https://inkbattle-a-backend.onrender.com";
//  static const String apiBaseUrl = "http://192.168.1.6:4000/api";
  //static const String socketUrl = "http://192.168.1.6:4000";
  // static const String apiBaseUrl =
  //     "https://inkbattle-a-backend.onrender.com/api";
  // static const String socketUrl = "https://inkbattle-a-backend.onrender.com";

  // For physical device on same network, use your computer's IP:
  // static const String apiBaseUrl = "http://192.168.x.x:4000/api";
  // static const String socketUrl = "http://192.168.x.x:4000";

  // For production:
  // static const String apiBaseUrl = "https://your-production-api.com/api";
  // static const String socketUrl = "https://your-production-api.com";

  // Razorpay Configuration (from .env)
  // static String get razorpayKeyId =>
  //     dotenv.env['RAZORPAY_KEY_ID'] ?? 'rzp_test_RaT4OZ1pgy4cJb';
  // static String get razorpayKeySecret =>
  //     dotenv.env['RAZORPAY_KEY_SECRET'] ?? 'szRFADGHws42Er26s5sg7ro1';
  // static int get paymentAmount =>
  //     int.tryParse(dotenv.env['PAYMENT_AMOUNT'] ?? '1000') ?? 1000;
  // static int get coinsOnPayment =>
  //     int.tryParse(dotenv.env['COINS_ON_PAYMENT'] ?? '8000') ?? 8000;
  static String get agoraAppId =>
      dotenv.env['AGORA_APP_ID'] ?? '85ed3bccf4dc4f62b3e30b834a0b5670';

  // /// Web client ID (OAuth 2.0) from Firebase/Google Cloud. Required for Google Sign-In idToken on Android.
  // static String get googleWebClientId =>
  //     dotenv.env['GOOGLE_WEB_CLIENT_ID'] ??
  //     '810403540241-ip9gtcb25f8m6f3du23riuqj5h5dbr9l.apps.googleusercontent.com';
}
