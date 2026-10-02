class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const ownerActorId = String.fromEnvironment('TOFAN_OWNER_ACTOR_ID');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
