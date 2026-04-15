class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL',
    defaultValue: 'https://twpcgwlmlydmnlxymhrg.supabase.co');

  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3cGNnd2xtbHlkbW5seHltaHJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYxODkyMzUsImV4cCI6MjA5MTc2NTIzNX0.dH7bmZBVe66RF4SNOMfZpHfoEoI43KKvNIl5siowBeE');

  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1');
}
