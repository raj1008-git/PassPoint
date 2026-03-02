import 'package:isar/isar.dart';

part 'staff_local_model.g.dart';

@collection
class StaffLocalModel {
  Id id = Isar.autoIncrement;

  // From API
  @Index(unique: false)
  late String branchCode;

  late String branchName;

  @Index(unique: true)
  late String phone; // mobileNo from API

  late String fullName;
  late String email;

  String? address;
  String? departmentName;
  String? provinceId;
  String? provinceName;

  // Computed: is this an HQ staff member?
  @Index()
  late bool isHQStaff; // true if branchCode is 300, 301, or 900

  // Sync metadata
  late DateTime syncedAt;
}
