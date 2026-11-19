import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jansamasya_mobile/config/api_config.dart';
import 'package:jansamasya_mobile/models/report.dart';
import 'package:jansamasya_mobile/models/user.dart';
import 'package:jansamasya_mobile/screens/splash_screen.dart';
import 'package:jansamasya_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  group('Model JSON serialization tests', () {
    test('User.fromJson parses backend profile response accurately', () {
      final user = User.fromJson({
        'id': '6739abc123',
        'username': 'rahul_citizen',
        'role': 'user',
        'state': 'uttar pradesh',
        'area': 'Gomti Nagar',
      });

      expect(user.id, '6739abc123');
      expect(user.username, 'rahul_citizen');
      expect(user.email, isNull);
      expect(user.role, 'user');
      expect(user.state, 'uttar pradesh');
      expect(user.area, 'Gomti Nagar');
    });

    test('Report.fromJson parses MongoDB Report JSON accurately', () {
      final report = Report.fromJson({
        '_id': '6739rep001',
        'title': 'Broken Streetlight',
        'description': 'Light near park gate is out',
        'category': 'streetlights',
        'imageUrl': 'http://localhost:5000/uploads/sample.jpg',
        'status': 'in-progress',
        'user': '6739abc123',
        'state': 'uttar pradesh',
        'area': 'Gomti Nagar',
        'createdAt': '2026-11-18T10:00:00.000Z',
      });

      expect(report.id, '6739rep001');
      expect(report.title, 'Broken Streetlight');
      expect(report.category, 'streetlights');
      expect(report.status, 'in-progress');
      expect(report.createdAt, isNotNull);
      expect(
        ApiConfig.resolveImageUrl(report.imageUrl),
        '${ApiConfig.baseUrl}/uploads/sample.jpg',
      );
    });
  });

  testWidgets('SplashScreen renders JanSamasya branding and tagline', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthService>(
        create: (_) => AuthService(),
        child: const MaterialApp(home: SplashScreen(autoNavigate: false)),
      ),
    );

    expect(find.text('JanSamasya'), findsOneWidget);
    expect(
      find.text('Report. Track. Resolve. Build a Better Community.'),
      findsOneWidget,
    );
  });
}
