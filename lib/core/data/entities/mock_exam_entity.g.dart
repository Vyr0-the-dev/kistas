// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_exam_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMockExamEntityCollection on Isar {
  IsarCollection<MockExamEntity> get mockExamEntitys => this.collection();
}

const MockExamEntitySchema = CollectionSchema(
  name: r'MockExamEntity',
  id: -8618264077468231453,
  properties: {
    r'blank': PropertySchema(
      id: 0,
      name: r'blank',
      type: IsarType.long,
    ),
    r'correct': PropertySchema(
      id: 1,
      name: r'correct',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dateLabel': PropertySchema(
      id: 3,
      name: r'dateLabel',
      type: IsarType.string,
    ),
    r'examType': PropertySchema(
      id: 4,
      name: r'examType',
      type: IsarType.string,
    ),
    r'minutes': PropertySchema(
      id: 5,
      name: r'minutes',
      type: IsarType.long,
    ),
    r'note': PropertySchema(
      id: 6,
      name: r'note',
      type: IsarType.string,
    ),
    r'originalId': PropertySchema(
      id: 7,
      name: r'originalId',
      type: IsarType.string,
    ),
    r'subjectMinutesJson': PropertySchema(
      id: 8,
      name: r'subjectMinutesJson',
      type: IsarType.string,
    ),
    r'subjectNetsJson': PropertySchema(
      id: 9,
      name: r'subjectNetsJson',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 10,
      name: r'title',
      type: IsarType.string,
    ),
    r'totalNet': PropertySchema(
      id: 11,
      name: r'totalNet',
      type: IsarType.double,
    ),
    r'wrong': PropertySchema(
      id: 12,
      name: r'wrong',
      type: IsarType.long,
    )
  },
  estimateSize: _mockExamEntityEstimateSize,
  serialize: _mockExamEntitySerialize,
  deserialize: _mockExamEntityDeserialize,
  deserializeProp: _mockExamEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'originalId': IndexSchema(
      id: -8365773424467627071,
      name: r'originalId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'originalId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _mockExamEntityGetId,
  getLinks: _mockExamEntityGetLinks,
  attach: _mockExamEntityAttach,
  version: '3.1.0+1',
);

int _mockExamEntityEstimateSize(
  MockExamEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.dateLabel.length * 3;
  bytesCount += 3 + object.examType.length * 3;
  bytesCount += 3 + object.note.length * 3;
  bytesCount += 3 + object.originalId.length * 3;
  bytesCount += 3 + object.subjectMinutesJson.length * 3;
  bytesCount += 3 + object.subjectNetsJson.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _mockExamEntitySerialize(
  MockExamEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.blank);
  writer.writeLong(offsets[1], object.correct);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.dateLabel);
  writer.writeString(offsets[4], object.examType);
  writer.writeLong(offsets[5], object.minutes);
  writer.writeString(offsets[6], object.note);
  writer.writeString(offsets[7], object.originalId);
  writer.writeString(offsets[8], object.subjectMinutesJson);
  writer.writeString(offsets[9], object.subjectNetsJson);
  writer.writeString(offsets[10], object.title);
  writer.writeDouble(offsets[11], object.totalNet);
  writer.writeLong(offsets[12], object.wrong);
}

MockExamEntity _mockExamEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MockExamEntity();
  object.blank = reader.readLong(offsets[0]);
  object.correct = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.dateLabel = reader.readString(offsets[3]);
  object.examType = reader.readString(offsets[4]);
  object.id = id;
  object.minutes = reader.readLong(offsets[5]);
  object.note = reader.readString(offsets[6]);
  object.originalId = reader.readString(offsets[7]);
  object.subjectMinutesJson = reader.readString(offsets[8]);
  object.subjectNetsJson = reader.readString(offsets[9]);
  object.title = reader.readString(offsets[10]);
  object.totalNet = reader.readDouble(offsets[11]);
  object.wrong = reader.readLong(offsets[12]);
  return object;
}

P _mockExamEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mockExamEntityGetId(MockExamEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mockExamEntityGetLinks(MockExamEntity object) {
  return [];
}

void _mockExamEntityAttach(
    IsarCollection<dynamic> col, Id id, MockExamEntity object) {
  object.id = id;
}

extension MockExamEntityByIndex on IsarCollection<MockExamEntity> {
  Future<MockExamEntity?> getByOriginalId(String originalId) {
    return getByIndex(r'originalId', [originalId]);
  }

  MockExamEntity? getByOriginalIdSync(String originalId) {
    return getByIndexSync(r'originalId', [originalId]);
  }

  Future<bool> deleteByOriginalId(String originalId) {
    return deleteByIndex(r'originalId', [originalId]);
  }

  bool deleteByOriginalIdSync(String originalId) {
    return deleteByIndexSync(r'originalId', [originalId]);
  }

  Future<List<MockExamEntity?>> getAllByOriginalId(
      List<String> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'originalId', values);
  }

  List<MockExamEntity?> getAllByOriginalIdSync(List<String> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'originalId', values);
  }

  Future<int> deleteAllByOriginalId(List<String> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'originalId', values);
  }

  int deleteAllByOriginalIdSync(List<String> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'originalId', values);
  }

  Future<Id> putByOriginalId(MockExamEntity object) {
    return putByIndex(r'originalId', object);
  }

  Id putByOriginalIdSync(MockExamEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'originalId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOriginalId(List<MockExamEntity> objects) {
    return putAllByIndex(r'originalId', objects);
  }

  List<Id> putAllByOriginalIdSync(List<MockExamEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'originalId', objects, saveLinks: saveLinks);
  }
}

extension MockExamEntityQueryWhereSort
    on QueryBuilder<MockExamEntity, MockExamEntity, QWhere> {
  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension MockExamEntityQueryWhere
    on QueryBuilder<MockExamEntity, MockExamEntity, QWhereClause> {
  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause>
      originalIdEqualTo(String originalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'originalId',
        value: [originalId],
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause>
      originalIdNotEqualTo(String originalId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [],
              upper: [originalId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [originalId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [originalId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'originalId',
              lower: [],
              upper: [originalId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MockExamEntityQueryFilter
    on QueryBuilder<MockExamEntity, MockExamEntity, QFilterCondition> {
  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      blankEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blank',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      blankGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'blank',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      blankLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'blank',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      blankBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'blank',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      correctEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correct',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      correctGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'correct',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      correctLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'correct',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      correctBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'correct',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dateLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dateLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dateLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dateLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      dateLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dateLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'examType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'examType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examType',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      examTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'examType',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
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

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
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

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      minutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minutes',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      minutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minutes',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      minutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minutes',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      minutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalId',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      originalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalId',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectMinutesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectMinutesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectMinutesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectMinutesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectMinutesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectMinutesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectMinutesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectMinutesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectMinutesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectMinutesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectMinutesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectNetsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subjectNetsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subjectNetsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subjectNetsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subjectNetsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subjectNetsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subjectNetsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subjectNetsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subjectNetsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      subjectNetsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subjectNetsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      totalNetEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalNet',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      totalNetGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalNet',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      totalNetLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalNet',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      totalNetBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalNet',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      wrongEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wrong',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      wrongGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wrong',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      wrongLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wrong',
        value: value,
      ));
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterFilterCondition>
      wrongBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wrong',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MockExamEntityQueryObject
    on QueryBuilder<MockExamEntity, MockExamEntity, QFilterCondition> {}

extension MockExamEntityQueryLinks
    on QueryBuilder<MockExamEntity, MockExamEntity, QFilterCondition> {}

extension MockExamEntityQuerySortBy
    on QueryBuilder<MockExamEntity, MockExamEntity, QSortBy> {
  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByBlank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blank', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByBlankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blank', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByDateLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateLabel', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortByDateLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateLabel', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByExamType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortByExamTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutes', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortByMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutes', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortBySubjectMinutesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMinutesJson', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortBySubjectMinutesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMinutesJson', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortBySubjectNetsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectNetsJson', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortBySubjectNetsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectNetsJson', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByTotalNet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalNet', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      sortByTotalNetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalNet', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByWrong() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrong', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> sortByWrongDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrong', Sort.desc);
    });
  }
}

extension MockExamEntityQuerySortThenBy
    on QueryBuilder<MockExamEntity, MockExamEntity, QSortThenBy> {
  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByBlank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blank', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByBlankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blank', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByDateLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateLabel', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenByDateLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateLabel', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByExamType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenByExamTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutes', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenByMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutes', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenBySubjectMinutesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMinutesJson', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenBySubjectMinutesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectMinutesJson', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenBySubjectNetsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectNetsJson', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenBySubjectNetsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subjectNetsJson', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByTotalNet() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalNet', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy>
      thenByTotalNetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalNet', Sort.desc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByWrong() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrong', Sort.asc);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QAfterSortBy> thenByWrongDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrong', Sort.desc);
    });
  }
}

extension MockExamEntityQueryWhereDistinct
    on QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> {
  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByBlank() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blank');
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correct');
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByDateLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByExamType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minutes');
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByOriginalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct>
      distinctBySubjectMinutesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectMinutesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct>
      distinctBySubjectNetsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subjectNetsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByTotalNet() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalNet');
    });
  }

  QueryBuilder<MockExamEntity, MockExamEntity, QDistinct> distinctByWrong() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wrong');
    });
  }
}

extension MockExamEntityQueryProperty
    on QueryBuilder<MockExamEntity, MockExamEntity, QQueryProperty> {
  QueryBuilder<MockExamEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MockExamEntity, int, QQueryOperations> blankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blank');
    });
  }

  QueryBuilder<MockExamEntity, int, QQueryOperations> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correct');
    });
  }

  QueryBuilder<MockExamEntity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MockExamEntity, String, QQueryOperations> dateLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateLabel');
    });
  }

  QueryBuilder<MockExamEntity, String, QQueryOperations> examTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examType');
    });
  }

  QueryBuilder<MockExamEntity, int, QQueryOperations> minutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minutes');
    });
  }

  QueryBuilder<MockExamEntity, String, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<MockExamEntity, String, QQueryOperations> originalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalId');
    });
  }

  QueryBuilder<MockExamEntity, String, QQueryOperations>
      subjectMinutesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectMinutesJson');
    });
  }

  QueryBuilder<MockExamEntity, String, QQueryOperations>
      subjectNetsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subjectNetsJson');
    });
  }

  QueryBuilder<MockExamEntity, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<MockExamEntity, double, QQueryOperations> totalNetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalNet');
    });
  }

  QueryBuilder<MockExamEntity, int, QQueryOperations> wrongProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wrong');
    });
  }
}
