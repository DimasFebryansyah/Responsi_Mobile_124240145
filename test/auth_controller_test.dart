import 'package:flutter_test/flutter_test.dart';
import 'package:latres/app/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores the email session and clears it on logout', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AuthController(preferences, initialEmail: null);

    final loggedIn = await controller.login(
      email: ' player@example.com ',
      password: 'any-password',
    );

    expect(loggedIn, isTrue);
    expect(controller.isAuthenticated.value, isTrue);
    expect(controller.email.value, 'player@example.com');
    expect(preferences.getString('email'), 'player@example.com');
    expect(preferences.getBool('isLoggedIn'), isTrue);

    await controller.logout();

    expect(controller.isAuthenticated.value, isFalse);
    expect(preferences.getString('email'), isNull);
    expect(preferences.getBool('isLoggedIn'), isNull);
  });

  test('rejects an invalid email address', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AuthController(preferences, initialEmail: null);

    final loggedIn = await controller.login(
      email: 'not-an-email',
      password: 'password',
    );

    expect(loggedIn, isFalse);
    expect(controller.isAuthenticated.value, isFalse);
    expect(preferences.getBool('isLoggedIn'), isNull);
  });

  test('accepts any non-empty password and rejects an empty one', () async {
    final preferences = await SharedPreferences.getInstance();
    final controller = AuthController(preferences, initialEmail: null);

    final loggedIn = await controller.login(
      email: 'player@example.com',
      password: 'anything',
    );
    final emptyPassword = await controller.login(
      email: 'other@example.com',
      password: '',
    );

    expect(loggedIn, isTrue);
    expect(emptyPassword, isFalse);
    expect(controller.isAuthenticated.value, isTrue);
  });
}
