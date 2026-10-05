/// Kumpulan konstanta yang dipakai di seluruh aplikasi Latihan Login.
class AppConstants {
  const AppConstants._();

  // ------------------------------------------------------------------
  // Aplikasi
  // ------------------------------------------------------------------
  static const String appTitle = 'Latihan Login';

  /// Lebar maksimal form agar tidak melebar di tablet/desktop.
  static const double formMaxWidth = 420;

  // ------------------------------------------------------------------
  // Database
  // ------------------------------------------------------------------
  static const String dbName = 'latihan_login.db';
  static const int dbVersion = 1;

  // ------------------------------------------------------------------
  // Tabel & kolom
  // ------------------------------------------------------------------
  static const String tableUser = 'user';
  static const String columnId = 'id';
  static const String columnName = 'name';
  static const String columnEmail = 'email';
  static const String columnPassword = 'password';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  // ------------------------------------------------------------------
  // Label form
  // ------------------------------------------------------------------
  static const String labelName = 'Nama Lengkap';
  static const String labelEmail = 'Email';
  static const String labelPassword = 'Password';
  static const String labelConfirmPassword = 'Konfirmasi Password';

  static const String hintName = 'Masukkan nama lengkap';
  static const String hintEmail = 'Masukkan email';
  static const String hintPassword = 'Masukkan password';
  static const String hintConfirmPassword = 'Ulangi password';

  // ------------------------------------------------------------------
  // Tombol
  // ------------------------------------------------------------------
  static const String buttonLogin = 'Login';
  static const String buttonRegister = 'Daftar';
  static const String buttonLogout = 'Logout';
  static const String buttonDeleteAccount = 'Hapus Akun';
  static const String buttonRefresh = 'Muat Ulang';

  // ------------------------------------------------------------------
  // Navigasi
  // ------------------------------------------------------------------
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeHome = '/home';

  // ------------------------------------------------------------------
  // Teks pendukung
  // ------------------------------------------------------------------
  static const String tagline = 'Belajar Flutter + SQLite';
  static const String welcomeBack = 'Selamat datang kembali';
  static const String createAccount = 'Buat akun baru';
  static const String noRegisterAccount = 'Belum punya akun?';
  static const String haveAccount = 'Sudah punya akun?';
  static const String registeredUsers = 'Pengguna Terdaftar';
  static const String noUserData = 'Belum ada pengguna terdaftar.';

  // ------------------------------------------------------------------
  // Pesan validasi & snackbar
  // ------------------------------------------------------------------
  static const String msgNameEmpty = 'Nama tidak boleh kosong';
  static const String msgNameShort = 'Nama minimal 3 karakter';
  static const String msgEmailEmpty = 'Email tidak boleh kosong';
  static const String msgEmailInvalid = 'Format email tidak valid';
  static const String msgPasswordEmpty = 'Password tidak boleh kosong';
  static const String msgPasswordShort = 'Password minimal 6 karakter';
  static const String msgPasswordNotMatch = 'Konfirmasi password tidak sama';
  static const String msgEmailRegistered = 'Email sudah terdaftar';
  static const String msgLoginSuccess = 'Login berhasil, selamat datang!';
  static const String msgLoginFailed = 'Email atau password salah';
  static const String msgRegisterSuccess =
      'Pendaftaran berhasil, silakan login';
  static const String msgEmptyEmailOrPassword =
      'Email dan password wajib diisi';
  static const String msgLogoutSuccess = 'Berhasil logout';
  static const String msgAccountDeleted = 'Akun berhasil dihapus';
  static const String msgConfirmDeleteAccount =
      'Yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.';
  static const String msgDatabaseError = 'Terjadi kesalahan pada database';
}
