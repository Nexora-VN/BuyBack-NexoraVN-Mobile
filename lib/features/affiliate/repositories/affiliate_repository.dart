import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/generate_link_model.dart';

final affiliateRepositoryProvider = Provider<AffiliateRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return AffiliateRepository(client);
});

class AffiliateRepository {
  final ApiClient _client;

  AffiliateRepository(this._client);

  Future<GenerateLinkResponse> generate(String url) async {
    final response = await _client.post(
      '/generate-affiliate',
      data: {'url': url.trim()},
    );

    if (response is Map<String, dynamic>) {
      return GenerateLinkResponse.fromJson(response);
    }
    throw Exception('Không tạo được link. Vui lòng thử lại.');
  }

  Future<List<Map<String, dynamic>>> getMyLinks({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final queryParams = {
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'affiliateLinkStatus': status,
    };

    final response = await _client.get(
      '/me/affiliate-links',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data'] as List);
    }
    return [];
  }
}
