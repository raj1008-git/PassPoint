import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/staff_local_model.dart';

class IsarService {
  static Isar? _isar;

  static Isar get instance {
    if (_isar == null || !_isar!.isOpen) {
      throw StateError(
        'Isar is not initialized. Call IsarService.init() first.',
      );
    }
    return _isar!;
  }

  static Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return;

    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [StaffLocalModelSchema],
      directory: dir.path,
      name: 'passpoint_local',
    );
  }

  static Future<void> close() async {
    await _isar?.close();
  }
}
