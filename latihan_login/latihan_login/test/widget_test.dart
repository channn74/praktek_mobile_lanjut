import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:latihan_login/core/presentation/screens/login_screen.dart';
import 'package:latihan_login/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('name', () {
      test('menolak nama kosong', () {
        expect(Validators.name(''), isNotNull);
        expect(Validators.name('   '), isNotNull);
        expect(Validators.name(null), isNotNull);
      });

      test('menolak nama kurang dari 3 karakter', () {
        expect(Validators.name('ab'), isNotNull);
      });

      test('menerima nama yang valid', () {
        expect(Validators.name('Budi'), isNull);
      });
    });

    group('email', () {
      test('menolak email kosong', () {
        expect(Validators.email(''), isNotNull);
      });

      test('menolak format email tidak valid', () {
        expect(Validators.email('budi'), isNotNull);
        expect(Validators.email('budi@'), isNotNull);
        expect(Validators.email('budi@example'), isNotNull);
      });

      test('menerima format email yang valid', () {
        expect(Validators.email('budi@example.com'), isNull);
        expect(Validators.email('budi.santoso@my.co.id'), isNull);
      });
    });

    group('password', () {
      test('menolak password kosong', () {
        expect(Validators.password(''), isNotNull);
      });

      test('menolak password kurang dari 6 karakter', () {
        expect(Validators.password('12345'), isNotNull);
      });

      test('menerima password yang valid', () {
        expect(Validators.password('123456'), isNull);
      });
    });

    group('confirmPassword', () {
      test('menolak konfirmasi kosong', () {
        expect(Validators.confirmPassword('', 'secret'), isNotNull);
      });

      test('menolak konfirmasi yang tidak sama', () {
        expect(Validators.confirmPassword('salah', 'secret'), isNotNull);
      });

      test('menerima konfirmasi yang sama', () {
        expect(Validators.confirmPassword('secret', 'secret'), isNull);
      });
    });
  });

  testWidgets('halaman login menampilkan judul dan tombol login', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen(onLoginSuccess: ignoreUser)),
    );
    await tester.pump();

    expect(find.text('Latihan Login'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('validasi form login menampilkan pesan error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen(onLoginSuccess: ignoreUser)),
    );
    await tester.pump();

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Email tidak boleh kosong'), findsOneWidget);
    expect(find.text('Password tidak boleh kosong'), findsOneWidget);
  });
}

void ignoreUser(Map<String, Object?> user) {}
