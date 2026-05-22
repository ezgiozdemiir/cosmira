import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/di.dart';
import '../errors/exceptions.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(supabaseClientProvider));
});

class ApiClient {
  final SupabaseClient _client;

  const ApiClient(this._client);

  SupabaseClient get client => _client;

  Future<T> query<T>(Future<T> Function(SupabaseClient client) request) async {
    try {
      return await request(_client);
    } on PostgrestException catch (e) {
      throw ServerException(e.message, int.tryParse(e.code ?? ''));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> callEdgeFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _client.functions.invoke(
        functionName,
        body: body,
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException('Edge function error: $e');
    }
  }
}
