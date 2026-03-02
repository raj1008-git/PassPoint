import 'dart:convert';

import 'package:http/http.dart' as http;

/// Raw staff data as returned by the PMLIL API.
class StaffApiEntry {
  final String fullName;
  final String branchCode;
  final String branchName;
  final String mobileNo;
  final String email;
  final String? address;
  final String? departmentName;
  final String? provinceId;
  final String? provinceName;

  const StaffApiEntry({
    required this.fullName,
    required this.branchCode,
    required this.branchName,
    required this.mobileNo,
    required this.email,
    this.address,
    this.departmentName,
    this.provinceId,
    this.provinceName,
  });

  factory StaffApiEntry.fromJson(Map<String, dynamic> json) {
    return StaffApiEntry(
      fullName: (json['fullName'] as String? ?? '').trim(),
      branchCode: (json['branchCode'] as String? ?? '').trim(),
      branchName: (json['branchName'] as String? ?? '').trim(),
      mobileNo: (json['mobileNo'] as String? ?? '').trim(),
      email: (json['email'] as String? ?? '').trim(),
      address: (json['address'] as String?)?.trim(),
      departmentName: (json['departmentName'] as String?)?.trim(),
      provinceId: json['provinceId']?.toString().trim(),
      provinceName: (json['provinceName'] as String?)?.trim(),
    );
  }
}

class StaffApiService {
  final String baseUrl;
  final String apiUsername;
  final String apiPassword;

  // Cached token to avoid re-fetching within the same sync session
  String? _cachedToken;
  DateTime? _tokenExpiry;

  StaffApiService({
    required this.baseUrl,
    required this.apiUsername,
    required this.apiPassword,
  });

  // ---------------------------------------------------------------------------
  // Token
  // ---------------------------------------------------------------------------

  Future<String> _getToken() async {
    // Return cached token if still valid (with 1-minute buffer)
    if (_cachedToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(
          _tokenExpiry!.subtract(const Duration(minutes: 1)),
        )) {
      return _cachedToken!;
    }

    final uri = Uri.parse('$baseUrl/api/Auth/token');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userName': apiUsername, 'password': apiPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'StaffApiService: Failed to get token. '
        'Status: ${response.statusCode}, Body: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    _cachedToken = data['tokenString'] as String;

    // Parse expiry — API returns ISO 8601 string
    final expiryStr = data['expiryDate'] as String?;
    if (expiryStr != null) {
      _tokenExpiry = DateTime.tryParse(expiryStr);
    }

    return _cachedToken!;
  }

  // ---------------------------------------------------------------------------
  // Fetch all staff (paginated)
  // ---------------------------------------------------------------------------

  /// Fetches ALL active staff from the API using pagination.
  /// [pageSize] controls how many records per request (default 100).
  Future<List<StaffApiEntry>> fetchAllStaff({int pageSize = 100}) async {
    final token = await _getToken();
    final List<StaffApiEntry> all = [];
    int start = 0;

    while (true) {
      final uri = Uri.parse(
        '$baseUrl/api/OnlineUserServices/GetUserDetails?status=A',
      );

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'displayLength': pageSize,
          'displayStart': start,
          'status': 'A',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'StaffApiService: Failed to fetch staff. '
          'Status: ${response.statusCode}, Body: ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final userList = data['userList'] as List<dynamic>? ?? [];

      if (userList.isEmpty) break;

      for (final item in userList) {
        all.add(StaffApiEntry.fromJson(item as Map<String, dynamic>));
      }

      final totalRecords = data['totalRecords'] as int? ?? 0;
      start += pageSize;

      // Stop if we've fetched everything
      if (start >= totalRecords || userList.length < pageSize) break;
    }

    return all;
  }

  void clearTokenCache() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}
