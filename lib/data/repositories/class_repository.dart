// lib/data/repositories/class_repository.dart
// ─────────────────────────────────────────
// All class CRUD operations.
// PHP endpoints:
//   GET    /classes/list.php          → [] array of classes
//   POST   /classes/create.php        → class object
//   PUT    /classes/update.php        → {id, ...fields}
//   DELETE /classes/delete.php        → {id}
//   GET    /classes/detail.php?id=X   → single class
// ─────────────────────────────────────────

import '../models/class_model.dart';
import '../providers/api_provider.dart';

class ClassRepository {
  final ApiProvider _api;

  ClassRepository(this._api);

  // ── Shared guard ─────────────────────────────────────────────────────────
  // response.data can be null (empty body) or a raw String (PHP error page).
  // Always validate before casting to avoid the
  // "null is not a subtype of Map<String, dynamic>" crash.
  Map<String, dynamic>? _toMap(dynamic raw) {
    if (raw == null || raw is! Map) return null;
    return Map<String, dynamic>.from(raw);
  }

  // ── Get Classes ──────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getClasses() async {
    try {
      final response = await _api.get('/classes/list.php');
      final data = _toMap(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Unexpected server response.'};
      }
      if (data['status'] == true) {
        final raw = data['data'];
        if (raw is! List) {
          return {'success': false, 'message': 'Invalid class list format.'};
        }
        final list = raw
            .whereType<Map>()
            .map((e) => ClassModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return {'success': true, 'classes': list};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to load classes.'};
    } catch (e) {
      return {'success': false, 'message': ApiProvider.handleError(e)};
    }
  }

  // ── Create Class ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> createClass(ClassModel model) async {
    try {
      final response = await _api.post('/classes/create.php', data: model.toJson());
      final data = _toMap(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Unexpected server response.'};
      }
      if (data['status'] == true) {
        final rawClass = data['data'];
        if (rawClass is! Map) {
          return {'success': false, 'message': 'Invalid class data returned from server.'};
        }
        return {
          'success': true,
          'class': ClassModel.fromJson(Map<String, dynamic>.from(rawClass)),
          'message': data['message'] ?? 'Class created!',
        };
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to create class.'};
    } catch (e) {
      return {'success': false, 'message': ApiProvider.handleError(e)};
    }
  }

  // ── Update Class ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> updateClass(ClassModel model) async {
    try {
      final response = await _api.put('/classes/update.php', data: model.toJson());
      final data = _toMap(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Unexpected server response.'};
      }
      if (data['status'] == true) {
        return {'success': true, 'message': data['message'] ?? 'Class updated!'};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to update class.'};
    } catch (e) {
      return {'success': false, 'message': ApiProvider.handleError(e)};
    }
  }

  // ── Delete Class ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> deleteClass(int id) async {
    try {
      final response = await _api.delete('/classes/delete.php', data: {'id': id});
      final data = _toMap(response.data);
      if (data == null) {
        return {'success': false, 'message': 'Unexpected server response.'};
      }
      return {
        'success': data['status'] == true,
        'message': data['message'] ?? 'Class deleted.',
      };
    } catch (e) {
      return {'success': false, 'message': ApiProvider.handleError(e)};
    }
  }
}
