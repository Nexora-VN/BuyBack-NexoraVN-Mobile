import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/bank_account_model.dart';
import '../models/cashback_model.dart';
import '../models/dashboard_model.dart';
import '../models/order_model.dart';
import '../models/wallet_transaction_model.dart';
import '../models/withdrawal_model.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return FinanceRepository(client);
});

class FinanceRepository {
  final ApiClient _client;

  FinanceRepository(this._client);

  Future<DashboardModel> getDashboard() async {
    final response = await _client.get('/me/dashboard');
    if (response is Map<String, dynamic>) {
      return DashboardModel.fromJson(response);
    }
    throw Exception('Không tải được thông tin bảng điều khiển');
  }

  Future<List<OrderModel>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? query,
    String? sort = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (query != null && query.isNotEmpty) queryParams['search'] = query;
    if (sort != null) queryParams['sort'] = sort;

    final response = await _client.get(
      '/me/orders',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<OrderModel> getOrderDetail(String id) async {
    final response = await _client.get('/me/orders/$id');
    if (response is Map<String, dynamic>) {
      return OrderModel.fromJson(response);
    }
    throw Exception('Không tải được chi tiết đơn hàng');
  }

  Future<List<CashbackModel>> getCashbacks({
    int page = 1,
    int limit = 20,
    String? status,
    String? query,
    String? sort = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (query != null && query.isNotEmpty) queryParams['search'] = query;
    if (sort != null) queryParams['sort'] = sort;

    final response = await _client.get(
      '/me/cashbacks',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => CashbackModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<DashboardWallet> getWallet() async {
    final response = await _client.get('/me/wallet');
    if (response is Map<String, dynamic>) {
      return DashboardWallet.fromJson(response);
    }
    throw Exception('Không tải được thông tin ví');
  }

  Future<List<WalletTransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
    String? query,
    String? sort = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (query != null && query.isNotEmpty) queryParams['search'] = query;
    if (sort != null) queryParams['sort'] = sort;

    final response = await _client.get(
      '/me/wallet/transactions',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<List<WithdrawalModel>> getWithdrawals({
    int page = 1,
    int limit = 20,
    String? status,
    String? query,
    String? sort = 'desc',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (query != null && query.isNotEmpty) queryParams['search'] = query;
    if (sort != null) queryParams['sort'] = sort;

    final response = await _client.get(
      '/me/withdrawals',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => WithdrawalModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> createWithdrawal({
    required String amount,
    required String bankId,
    required String idempotencyKey,
  }) async {
    await _client.post(
      '/me/withdrawals',
      data: {
        'amount': amount,
        'bankId': bankId,
        'idempotencyKey': idempotencyKey,
      },
    );
  }

  Future<List<BankAccountModel>> getBankAccounts({String? status}) async {
    final queryParams = {
      'limit': 100,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    final response = await _client.get(
      '/me/bank-accounts',
      queryParameters: queryParams,
    );

    if (response is Map<String, dynamic> && response['data'] is List) {
      return (response['data'] as List)
          .map((e) => BankAccountModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> createBankAccount({
    required String bankCode,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  }) async {
    await _client.post(
      '/me/bank-accounts',
      data: {
        'bankCode': bankCode,
        'bankName': bankName,
        'accountHolder': accountHolder,
        'accountNumber': accountNumber,
      },
    );
  }

  Future<void> updateBankAccount(
    String id, {
    required String bankCode,
    required String bankName,
    required String accountHolder,
  }) async {
    await _client.patch(
      '/me/bank-accounts/$id',
      data: {
        'bankCode': bankCode,
        'bankName': bankName,
        'accountHolder': accountHolder,
      },
    );
  }

  Future<void> deleteBankAccount(String id) async {
    await _client.delete('/me/bank-accounts/$id');
  }
}
