import '../models/guardian.dart';
import '../services/api_client.dart';

/// Datasource API (Laravel/MySQL) pour les tuteurs — CDC section 8.3,
/// doc/audit.md point B2.
class ApiGuardianDatasource {
  final _dio = ApiClient.instance.dio;

  Future<Guardian> addGuardian(Guardian guardian, String markazId) async {
    final response = await _dio.post('/guardians', data: {
      'name': guardian.name,
      'phone': guardian.phone,
      'email': guardian.email,
      'address': guardian.address,
    });
    return _mapJsonToGuardian(response.data as Map<String, dynamic>, markazId);
  }

  Future<Guardian> updateGuardian(Guardian guardian, String markazId) async {
    final response = await _dio.put('/guardians/${guardian.id}', data: {
      'name': guardian.name,
      'phone': guardian.phone,
      'email': guardian.email,
      'address': guardian.address,
    });
    return _mapJsonToGuardian(response.data as Map<String, dynamic>, markazId);
  }

  Future<void> deleteGuardian(String guardianId) async {
    await _dio.delete('/guardians/$guardianId');
  }

  Future<List<Guardian>> getGuardiansByMarkaz(String markazId) async {
    final response = await _dio.get('/guardians', queryParameters: {'per_page': 500});
    final data = (response.data as Map<String, dynamic>)['data'] as List<dynamic>;
    return data
        .map((json) => _mapJsonToGuardian(json as Map<String, dynamic>, markazId))
        .toList();
  }

  Guardian _mapJsonToGuardian(Map<String, dynamic> json, String markazId) {
    return Guardian(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      markazId: markazId,
      email: json['email'] as String?,
      address: json['address'] as String?,
    );
  }
}
