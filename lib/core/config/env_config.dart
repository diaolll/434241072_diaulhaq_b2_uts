import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Supabase Configuration
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'https://mpkcasgkzthrmkilsabf.supabase.co';

  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1wa2Nhc2drenRocm1raWxzYWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzMjI4NDQsImV4cCI6MjA5MTg5ODg0NH0.kW6IUnmo79B3ocWc6ZTi0FYFPX5km_hqsi8R7-Ciiow';

  // Backend API Configuration
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';
}
