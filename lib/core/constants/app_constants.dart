// lib/core/constants/app_constants.dart
// ─────────────────────────────────────────
// Central hub for all app-wide constants.
// To switch to production: change kBaseUrl to your PHP server URL.
// ─────────────────────────────────────────

class AppConstants {
  AppConstants._();

  // ── API ──────────────────────────────────────────────────────────────────
  /// Change this to your PHP backend URL before going live.
  /// e.g. 'https://yourserver.com/attendance_api'
  //static const String kBaseUrl = 'https://admin.flashdatagh.com/myapp/attendance_api'; // Android emulator
  static const String kBaseUrl = 'http://admin.flashdatagh.com/myapp/attendance_api'; // iOS simulator

  // PHP Endpoint reference (for backend developer):
  // POST   /auth/login.php          → {email, password}
  // POST   /auth/register.php       → {fname, sname, mname, email, password, student_id}
  // GET    /classes/list.php        → [] classes
  // POST   /classes/create.php      → {name, description, lat, lng, radius_m, day_of_week, start_time, end_time}
  // PUT    /classes/update.php      → {id, ...fields}
  // DELETE /classes/delete.php      → {id}
  // POST   /attendance/checkin.php  → {class_id, student_lat, student_lng}
  // GET    /attendance/history.php  → ?student_id=X&class_id=Y
  // GET    /attendance/report.php   → ?class_id=X (admin only)

  // ── Storage Keys ─────────────────────────────────────────────────────────
  static const String kUserKey       = 'current_user';
  static const String kTokenKey      = 'auth_token';
  static const String kThemeKey      = 'is_dark_mode';
  static const String kAttendanceKey = 'offline_attendance_queue';
  static const String kLanguageKey   = 'app_language';

  // ── Geo ───────────────────────────────────────────────────────────────────
  static const double kDefaultRadius = 50.0; // metres
  static const int    kLocationTimeout = 10;  // seconds

  // ── Misc ─────────────────────────────────────────────────────────────────
  static const int kConnectTimeout   = 15000; // ms
  static const int kReceiveTimeout   = 15000; // ms
  static const String kAppName       = 'AttendEase';
  static const String kAppVersion    = '1.0.0';
}

class AppStrings {
  AppStrings._();

  // Auth
  static const String login       = 'Login';
  static const String register    = 'Create Account';
  static const String logout      = 'Logout';
  static const String email       = 'Email Address';
  static const String password    = 'Password';
  static const String confirmPass = 'Confirm Password';
  static const String firstName   = 'First Name';
  static const String surname     = 'Surname';
  static const String middleName  = 'Middle Name (Optional)';
  static const String studentId   = 'Student ID';
  static const String forgotPass  = 'Forgot Password?';

  // Navigation
  static const String home        = 'Home';
  static const String classes     = 'Classes';
  static const String attendance  = 'Attendance';
  static const String profile     = 'Profile';
  static const String analytics   = 'Analytics';

  // Check-in
  static const String checkIn         = 'Check In';
  static const String checkOut        = 'Check Out';
  static const String checkedIn       = 'Checked In ✓';
  static const String notInRange      = 'You are not in range';
  static const String locationError   = 'Location Error';
  static const String fetchingLoc     = 'Fetching your location…';
  static const String checkInSuccess  = 'Check-in Successful! 🎉';
  static const String checkInFailed   = 'Check-in Failed';

  // Errors
  static const String networkError    = 'Network error. Please check connection.';
  static const String serverError     = 'Server error. Try again later.';
  static const String unknownError    = 'Something went wrong.';
  static const String permDenied      = 'Location permission denied.';
  static const String permPermanently = 'Please enable location in settings.';
}

class AppRoutes {
  AppRoutes._();

  static const String splash      = '/splash';
  static const String login       = '/login';
  static const String register    = '/register';
  static const String studentHome = '/student-home';
  static const String adminHome   = '/admin-home';
  static const String classDetail = '/class-detail';
  static const String checkIn     = '/check-in';
  static const String history     = '/history';
  static const String createClass = '/create-class';
  static const String analytics   = '/analytics';
  static const String profile     = '/profile';
  static const String qrScan      = '/qr-scan';
  static const String report      = '/report';
}
