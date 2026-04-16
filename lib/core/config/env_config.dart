class EnvConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL',
    defaultValue: 'https://mpkcasgkzthrmkilsabf.supabase.co');

  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1wa2Nhc2drenRocm1raWxzYWJmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzMjI4NDQsImV4cCI6MjA5MTg5ODg0NH0.kW6IUnmo79B3ocWc6ZTi0FYFPX5km_hqsi8R7-Ciiow');

  // Backend API Configuration
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1');
}
