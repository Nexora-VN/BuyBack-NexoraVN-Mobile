class DashboardWallet {
  final String available;
  final String reserved;

  DashboardWallet({
    required this.available,
    required this.reserved,
  });

  factory DashboardWallet.fromJson(Map<String, dynamic> json) {
    return DashboardWallet(
      available: json['available']?.toString() ?? '0',
      reserved: json['reserved']?.toString() ?? '0',
    );
  }
}

class DashboardCommission {
  final String state;
  final int count;
  final String? estimatedVnd;
  final String? settledVnd;

  DashboardCommission({
    required this.state,
    required this.count,
    this.estimatedVnd,
    this.settledVnd,
  });

  factory DashboardCommission.fromJson(Map<String, dynamic> json) {
    final sum = json['_sum'] as Map<String, dynamic>?;
    return DashboardCommission(
      state: json['state']?.toString() ?? '',
      count: json['_count'] is int ? json['_count'] as int : int.tryParse(json['_count']?.toString() ?? '0') ?? 0,
      estimatedVnd: sum?['estimatedVnd']?.toString(),
      settledVnd: sum?['settledVnd']?.toString(),
    );
  }
}

class DashboardCashbackSummary {
  final String state;
  final String userAmount;

  DashboardCashbackSummary({
    required this.state,
    required this.userAmount,
  });

  factory DashboardCashbackSummary.fromJson(Map<String, dynamic> json) {
    return DashboardCashbackSummary(
      state: json['state']?.toString() ?? '',
      userAmount: json['userAmount']?.toString() ?? '0',
    );
  }
}

class DashboardModel {
  final DashboardWallet wallet;
  final int orders;
  final List<DashboardCommission> commissions;
  final List<DashboardCashbackSummary> cashbackSummary;

  DashboardModel({
    required this.wallet,
    required this.orders,
    required this.commissions,
    required this.cashbackSummary,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      wallet: DashboardWallet.fromJson(
        (json['wallet'] as Map<String, dynamic>?) ?? {},
      ),
      orders: json['orders'] is int
          ? json['orders'] as int
          : int.tryParse(json['orders']?.toString() ?? '0') ?? 0,
      commissions: (json['commissions'] as List<dynamic>?)
              ?.map((e) => DashboardCommission.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cashbackSummary: (json['cashbackSummary'] as List<dynamic>?)
              ?.map((e) => DashboardCashbackSummary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Sum of pending and validated cashback amounts
  BigInt get pendingCashback {
    BigInt sum = BigInt.zero;
    for (final row in cashbackSummary) {
      if (['PENDING', 'VALIDATED'].contains(row.state)) {
        final amount = BigInt.tryParse(row.userAmount) ?? BigInt.zero;
        sum += amount;
      }
    }
    return sum;
  }
}
