// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_local_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStaffLocalModelCollection on Isar {
  IsarCollection<StaffLocalModel> get staffLocalModels => this.collection();
}

const StaffLocalModelSchema = CollectionSchema(
  name: r'StaffLocalModel',
  id: -5819461540477758476,
  properties: {
    r'address': PropertySchema(
      id: 0,
      name: r'address',
      type: IsarType.string,
    ),
    r'branchCode': PropertySchema(
      id: 1,
      name: r'branchCode',
      type: IsarType.string,
    ),
    r'branchName': PropertySchema(
      id: 2,
      name: r'branchName',
      type: IsarType.string,
    ),
    r'departmentName': PropertySchema(
      id: 3,
      name: r'departmentName',
      type: IsarType.string,
    ),
    r'email': PropertySchema(
      id: 4,
      name: r'email',
      type: IsarType.string,
    ),
    r'fullName': PropertySchema(
      id: 5,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'isHQStaff': PropertySchema(
      id: 6,
      name: r'isHQStaff',
      type: IsarType.bool,
    ),
    r'phone': PropertySchema(
      id: 7,
      name: r'phone',
      type: IsarType.string,
    ),
    r'provinceId': PropertySchema(
      id: 8,
      name: r'provinceId',
      type: IsarType.string,
    ),
    r'provinceName': PropertySchema(
      id: 9,
      name: r'provinceName',
      type: IsarType.string,
    ),
    r'syncedAt': PropertySchema(
      id: 10,
      name: r'syncedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _staffLocalModelEstimateSize,
  serialize: _staffLocalModelSerialize,
  deserialize: _staffLocalModelDeserialize,
  deserializeProp: _staffLocalModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'branchCode': IndexSchema(
      id: -828252051973447615,
      name: r'branchCode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'branchCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'phone': IndexSchema(
      id: -6308098324157559207,
      name: r'phone',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'phone',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isHQStaff': IndexSchema(
      id: 7973906647768278847,
      name: r'isHQStaff',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isHQStaff',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _staffLocalModelGetId,
  getLinks: _staffLocalModelGetLinks,
  attach: _staffLocalModelAttach,
  version: '3.1.0+1',
);

int _staffLocalModelEstimateSize(
  StaffLocalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.address;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.branchCode.length * 3;
  bytesCount += 3 + object.branchName.length * 3;
  {
    final value = object.departmentName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.email.length * 3;
  bytesCount += 3 + object.fullName.length * 3;
  bytesCount += 3 + object.phone.length * 3;
  {
    final value = object.provinceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.provinceName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _staffLocalModelSerialize(
  StaffLocalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.address);
  writer.writeString(offsets[1], object.branchCode);
  writer.writeString(offsets[2], object.branchName);
  writer.writeString(offsets[3], object.departmentName);
  writer.writeString(offsets[4], object.email);
  writer.writeString(offsets[5], object.fullName);
  writer.writeBool(offsets[6], object.isHQStaff);
  writer.writeString(offsets[7], object.phone);
  writer.writeString(offsets[8], object.provinceId);
  writer.writeString(offsets[9], object.provinceName);
  writer.writeDateTime(offsets[10], object.syncedAt);
}

StaffLocalModel _staffLocalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StaffLocalModel();
  object.address = reader.readStringOrNull(offsets[0]);
  object.branchCode = reader.readString(offsets[1]);
  object.branchName = reader.readString(offsets[2]);
  object.departmentName = reader.readStringOrNull(offsets[3]);
  object.email = reader.readString(offsets[4]);
  object.fullName = reader.readString(offsets[5]);
  object.id = id;
  object.isHQStaff = reader.readBool(offsets[6]);
  object.phone = reader.readString(offsets[7]);
  object.provinceId = reader.readStringOrNull(offsets[8]);
  object.provinceName = reader.readStringOrNull(offsets[9]);
  object.syncedAt = reader.readDateTime(offsets[10]);
  return object;
}

P _staffLocalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _staffLocalModelGetId(StaffLocalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _staffLocalModelGetLinks(StaffLocalModel object) {
  return [];
}

void _staffLocalModelAttach(
    IsarCollection<dynamic> col, Id id, StaffLocalModel object) {
  object.id = id;
}

extension StaffLocalModelByIndex on IsarCollection<StaffLocalModel> {
  Future<StaffLocalModel?> getByPhone(String phone) {
    return getByIndex(r'phone', [phone]);
  }

  StaffLocalModel? getByPhoneSync(String phone) {
    return getByIndexSync(r'phone', [phone]);
  }

  Future<bool> deleteByPhone(String phone) {
    return deleteByIndex(r'phone', [phone]);
  }

  bool deleteByPhoneSync(String phone) {
    return deleteByIndexSync(r'phone', [phone]);
  }

  Future<List<StaffLocalModel?>> getAllByPhone(List<String> phoneValues) {
    final values = phoneValues.map((e) => [e]).toList();
    return getAllByIndex(r'phone', values);
  }

  List<StaffLocalModel?> getAllByPhoneSync(List<String> phoneValues) {
    final values = phoneValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'phone', values);
  }

  Future<int> deleteAllByPhone(List<String> phoneValues) {
    final values = phoneValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'phone', values);
  }

  int deleteAllByPhoneSync(List<String> phoneValues) {
    final values = phoneValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'phone', values);
  }

  Future<Id> putByPhone(StaffLocalModel object) {
    return putByIndex(r'phone', object);
  }

  Id putByPhoneSync(StaffLocalModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'phone', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPhone(List<StaffLocalModel> objects) {
    return putAllByIndex(r'phone', objects);
  }

  List<Id> putAllByPhoneSync(List<StaffLocalModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'phone', objects, saveLinks: saveLinks);
  }
}

extension StaffLocalModelQueryWhereSort
    on QueryBuilder<StaffLocalModel, StaffLocalModel, QWhere> {
  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhere> anyIsHQStaff() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isHQStaff'),
      );
    });
  }
}

extension StaffLocalModelQueryWhere
    on QueryBuilder<StaffLocalModel, StaffLocalModel, QWhereClause> {
  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause>
      branchCodeEqualTo(String branchCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'branchCode',
        value: [branchCode],
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause>
      branchCodeNotEqualTo(String branchCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'branchCode',
              lower: [],
              upper: [branchCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'branchCode',
              lower: [branchCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'branchCode',
              lower: [branchCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'branchCode',
              lower: [],
              upper: [branchCode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause>
      phoneEqualTo(String phone) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'phone',
        value: [phone],
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause>
      phoneNotEqualTo(String phone) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'phone',
              lower: [],
              upper: [phone],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'phone',
              lower: [phone],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'phone',
              lower: [phone],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'phone',
              lower: [],
              upper: [phone],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause>
      isHQStaffEqualTo(bool isHQStaff) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isHQStaff',
        value: [isHQStaff],
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterWhereClause>
      isHQStaffNotEqualTo(bool isHQStaff) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isHQStaff',
              lower: [],
              upper: [isHQStaff],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isHQStaff',
              lower: [isHQStaff],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isHQStaff',
              lower: [isHQStaff],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isHQStaff',
              lower: [],
              upper: [isHQStaff],
              includeUpper: false,
            ));
      }
    });
  }
}

extension StaffLocalModelQueryFilter
    on QueryBuilder<StaffLocalModel, StaffLocalModel, QFilterCondition> {
  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'address',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'address',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'address',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'address',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      addressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'branchCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'branchCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'branchCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'branchCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'branchCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'branchCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'branchCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'branchCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'branchCode',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'branchCode',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'branchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'branchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'branchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'branchName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'branchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'branchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'branchName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'branchName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'branchName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      branchNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'branchName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'departmentName',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'departmentName',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departmentName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departmentName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departmentName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departmentName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      departmentNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departmentName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      isHQStaffEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isHQStaff',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      phoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phone',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'provinceId',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'provinceId',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provinceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'provinceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'provinceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'provinceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'provinceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'provinceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'provinceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'provinceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provinceId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'provinceId',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'provinceName',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'provinceName',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provinceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'provinceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'provinceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'provinceName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'provinceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'provinceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'provinceName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'provinceName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'provinceName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      provinceNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'provinceName',
        value: '',
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      syncedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      syncedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      syncedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterFilterCondition>
      syncedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StaffLocalModelQueryObject
    on QueryBuilder<StaffLocalModel, StaffLocalModel, QFilterCondition> {}

extension StaffLocalModelQueryLinks
    on QueryBuilder<StaffLocalModel, StaffLocalModel, QFilterCondition> {}

extension StaffLocalModelQuerySortBy
    on QueryBuilder<StaffLocalModel, StaffLocalModel, QSortBy> {
  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy> sortByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByBranchCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchCode', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByBranchCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchCode', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByBranchName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchName', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByBranchNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchName', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByDepartmentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByDepartmentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByIsHQStaff() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHQStaff', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByIsHQStaffDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHQStaff', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy> sortByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByProvinceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provinceId', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByProvinceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provinceId', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByProvinceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provinceName', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortByProvinceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provinceName', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }
}

extension StaffLocalModelQuerySortThenBy
    on QueryBuilder<StaffLocalModel, StaffLocalModel, QSortThenBy> {
  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy> thenByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByBranchCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchCode', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByBranchCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchCode', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByBranchName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchName', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByBranchNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'branchName', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByDepartmentName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByDepartmentNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departmentName', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByIsHQStaff() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHQStaff', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByIsHQStaffDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isHQStaff', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy> thenByPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phone', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByProvinceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provinceId', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByProvinceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provinceId', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByProvinceName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provinceName', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenByProvinceNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'provinceName', Sort.desc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QAfterSortBy>
      thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }
}

extension StaffLocalModelQueryWhereDistinct
    on QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct> {
  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct> distinctByAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'address', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct>
      distinctByBranchCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'branchCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct>
      distinctByBranchName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'branchName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct>
      distinctByDepartmentName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departmentName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct> distinctByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct>
      distinctByIsHQStaff() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isHQStaff');
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct> distinctByPhone(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phone', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct>
      distinctByProvinceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'provinceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct>
      distinctByProvinceName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'provinceName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StaffLocalModel, StaffLocalModel, QDistinct>
      distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }
}

extension StaffLocalModelQueryProperty
    on QueryBuilder<StaffLocalModel, StaffLocalModel, QQueryProperty> {
  QueryBuilder<StaffLocalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StaffLocalModel, String?, QQueryOperations> addressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'address');
    });
  }

  QueryBuilder<StaffLocalModel, String, QQueryOperations> branchCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'branchCode');
    });
  }

  QueryBuilder<StaffLocalModel, String, QQueryOperations> branchNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'branchName');
    });
  }

  QueryBuilder<StaffLocalModel, String?, QQueryOperations>
      departmentNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departmentName');
    });
  }

  QueryBuilder<StaffLocalModel, String, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<StaffLocalModel, String, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<StaffLocalModel, bool, QQueryOperations> isHQStaffProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isHQStaff');
    });
  }

  QueryBuilder<StaffLocalModel, String, QQueryOperations> phoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phone');
    });
  }

  QueryBuilder<StaffLocalModel, String?, QQueryOperations>
      provinceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'provinceId');
    });
  }

  QueryBuilder<StaffLocalModel, String?, QQueryOperations>
      provinceNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'provinceName');
    });
  }

  QueryBuilder<StaffLocalModel, DateTime, QQueryOperations> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }
}
