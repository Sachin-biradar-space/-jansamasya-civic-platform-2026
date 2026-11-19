/// Centralized API and application configuration for JanSamasya Mobile.
///
/// Change [baseUrl] here (or pass `--dart-define=API_BASE_URL=http://<LAN_IP>:5000`)
/// when testing on a physical Android device instead of the Android Emulator.
class ApiConfig {
  ApiConfig._();

  /// Default host URL for Android Emulator connecting to localhost:5000.
  /// - Android Emulator: `http://10.0.2.2:5000`
  /// - Physical Device (same Wi-Fi): `http://<YOUR_PC_LAN_IP>:5000`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  /// Network request timeout duration.
  static const Duration requestTimeout = Duration(seconds: 15);

  // Existing JanSamasya Express REST API endpoints (source of truth: backend/routes/)
  static String get signupUrl => '$baseUrl/api/auth/signup';
  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get profileUrl => '$baseUrl/api/user/profile';
  static String get createReportUrl => '$baseUrl/api/user/report';
  static String get myReportsUrl => '$baseUrl/api/user/my-reports';

  /// Rewrites localhost image URLs saved by web clients so they also load
  /// cleanly on the Android Emulator (where localhost refers to the emulator).
  static String resolveImageUrl(String rawUrl) {
    if (rawUrl.isEmpty) return '';
    if (rawUrl.startsWith('http://localhost:5000')) {
      return rawUrl.replaceFirst('http://localhost:5000', baseUrl);
    }
    if (rawUrl.startsWith('http://127.0.0.1:5000')) {
      return rawUrl.replaceFirst('http://127.0.0.1:5000', baseUrl);
    }
    if (rawUrl.startsWith('/uploads/')) {
      return '$baseUrl$rawUrl';
    }
    return rawUrl;
  }

  /// Issue categories matching frontend/src/pages/Report.jsx and backend Report.category.
  static const List<Map<String, String>> reportCategories = [
    {'value': 'roads', 'label': 'Roads & Infrastructure'},
    {'value': 'sanitation', 'label': 'Sanitation & Waste Management'},
    {'value': 'streetlights', 'label': 'Street Lighting'},
    {'value': 'water', 'label': 'Water Supply & Drainage'},
    {'value': 'parks', 'label': 'Parks & Public Spaces'},
    {'value': 'noise', 'label': 'Noise Pollution'},
    {'value': 'utilities', 'label': 'Public Utilities'},
    {'value': 'safety', 'label': 'Public Safety Concerns'},
    {'value': 'other', 'label': 'Other Issues'},
  ];

  /// Returns a human-readable category label for a stored backend category value.
  static String getCategoryLabel(String category) {
    final normalized = category.trim().toLowerCase();
    for (final item in reportCategories) {
      if (item['value'] == normalized) {
        return item['label']!;
      }
    }
    if (category.trim().isEmpty) return 'Other Issues';
    return category[0].toUpperCase() + category.substring(1);
  }

  /// Indian states matching the exact lowercase values used in frontend/src/pages/Signup.jsx.
  static const List<Map<String, String>> indianStates = [
    {'value': 'andhra pradesh', 'label': 'Andhra Pradesh'},
    {'value': 'arunachal pradesh', 'label': 'Arunachal Pradesh'},
    {'value': 'assam', 'label': 'Assam'},
    {'value': 'bihar', 'label': 'Bihar'},
    {'value': 'chhattisgarh', 'label': 'Chhattisgarh'},
    {'value': 'goa', 'label': 'Goa'},
    {'value': 'gujarat', 'label': 'Gujarat'},
    {'value': 'haryana', 'label': 'Haryana'},
    {'value': 'himachal pradesh', 'label': 'Himachal Pradesh'},
    {'value': 'jharkhand', 'label': 'Jharkhand'},
    {'value': 'karnataka', 'label': 'Karnataka'},
    {'value': 'kerala', 'label': 'Kerala'},
    {'value': 'madhya pradesh', 'label': 'Madhya Pradesh'},
    {'value': 'maharashtra', 'label': 'Maharashtra'},
    {'value': 'manipur', 'label': 'Manipur'},
    {'value': 'meghalaya', 'label': 'Meghalaya'},
    {'value': 'mizoram', 'label': 'Mizoram'},
    {'value': 'nagaland', 'label': 'Nagaland'},
    {'value': 'odisha', 'label': 'Odisha'},
    {'value': 'punjab', 'label': 'Punjab'},
    {'value': 'rajasthan', 'label': 'Rajasthan'},
    {'value': 'sikkim', 'label': 'Sikkim'},
    {'value': 'tamil nadu', 'label': 'Tamil Nadu'},
    {'value': 'telangana', 'label': 'Telangana'},
    {'value': 'tripura', 'label': 'Tripura'},
    {'value': 'uttar pradesh', 'label': 'Uttar Pradesh'},
    {'value': 'uttarakhand', 'label': 'Uttarakhand'},
    {'value': 'west bengal', 'label': 'West Bengal'},
  ];
}
