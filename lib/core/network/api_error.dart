class ApiError implements Exception {
  final String message;
  final int statusCode;
  final String? code;
  final String? requestId;
  final dynamic data;

  ApiError({
    required this.message,
    this.statusCode = 0,
    this.code,
    this.requestId,
    this.data,
  });

  @override
  String toString() => message;
}
