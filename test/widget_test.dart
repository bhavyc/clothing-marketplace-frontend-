import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:clothing_app/main.dart';
import 'package:clothing_app/providers/auth_provider.dart';
import 'package:clothing_app/providers/product_provider.dart';
import 'package:clothing_app/providers/cart_provider.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: const BoutiqueApp(),
      ),
    );

    // Verify splash screen or app loads
    expect(find.byType(BoutiqueApp), findsOneWidget);
  });
}
