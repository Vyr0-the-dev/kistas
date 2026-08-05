// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetQuestionEntityCollection on Isar {
  IsarCollection<QuestionEntity> get questionEntitys => this.collection();
}

const QuestionEntitySchema = CollectionSchema(
  name: r'QuestionEntity',
  id: -5718048655593194005,
  properties: {
    r'blank': PropertySchema(
      id: 0,
      name: r'blank',
      type: IsarType.long,
    ),
    r'bookName': PropertySchema(
      id: 1,
      name: r'bookName',
      type: IsarType.string,
    ),
    r'correct': PropertySchema(
      id: 2,
      name: r'correct',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'errorTags': PropertySchema(
      id: 4,
      name: r'errorTags',
      type: IsarType.stringList,
    ),
    r'examType': PropertySchema(
      id: 5,
      name: r'examType',
      type: IsarType.string,
    ),
    r'imagePaths': PropertySchema(
      id: 6,
      name: r'imagePaths',
      type: IsarType.stringList,
    ),
    r'minutes': PropertySchema(
      id: 7,
      name: r'minutes',
      type: IsarType.long,
    ),
    r'note': PropertySchema(
      id: 8,
      name: r'note',
      type: IsarType.string,
    ),
    r'originalId': PropertySchema(
      id: 9,
      name: r'originalId',
      type: IsarType.string,
    ),
    r'subject': PropertySchema(
      id: 10,
      name: r'subject',
      type: IsarType.string,
    ),
    r'topic': PropertySchema(
      id: 11,
      name: r'topic',
      type: IsarType.string,
    ),
    r'wrong': PropertySchema(
      id: 12,
      name: r'wrong',
      type: IsarType.long,
    )
  },
  estimateSize: _questionEntityEstimateSize,
  serialize: _questionEntitySerialize,
  deserialize: _questionEntityDeserialize,
  deserializeProp: _questionEntityDeserializeProp,
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
    r'topic': IndexSchema(
      id: 1007953096175763270,
      name: r'topic',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'topic',
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
  getId: _questionEntityGetId,
  getLinks: _questionEntityGetLinks,
  attach: _questionEntityAttach,
  version: '3.1.0+1',
);

int _questionEntityEstimateSize(
  QuestionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bookName.length * 3;
  bytesCount += 3 + object.errorTags.length * 3;
  {
    for (var i = 0; i < object.errorTags.length; i++) {
      final value = object.errorTags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.examType.length * 3;
  bytesCount += 3 + object.imagePaths.length * 3;
  {
    for (var i = 0; i < object.imagePaths.length; i++) {
      final value = object.imagePaths[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.note.length * 3;
  bytesCount += 3 + object.originalId.length * 3;
  bytesCount += 3 + object.subject.length * 3;
  bytesCount += 3 + object.topic.length * 3;
  return bytesCount;
}

void _questionEntitySerialize(
  QuestionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.blank);
  writer.writeString(offsets[1], object.bookName);
  writer.writeLong(offsets[2], object.correct);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeStringList(offsets[4], object.errorTags);
  writer.writeString(offsets[5], object.examType);
  writer.writeStringList(offsets[6], object.imagePaths);
  writer.writeLong(offsets[7], object.minutes);
  writer.writeString(offsets[8], object.note);
  writer.writeString(offsets[9], object.originalId);
  writer.writeString(offsets[10], object.subject);
  writer.writeString(offsets[11], object.topic);
  writer.writeLong(offsets[12], object.wrong);
}

QuestionEntity _questionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = QuestionEntity();
  object.blank = reader.readLong(offsets[0]);
  object.bookName = reader.readString(offsets[1]);
  object.correct = reader.readLong(offsets[2]);
  object.createdAt = reader.readDateTime(offsets[3]);
  object.errorTags = reader.readStringList(offsets[4]) ?? [];
  object.examType = reader.readString(offsets[5]);
  object.id = id;
  object.imagePaths = reader.readStringList(offsets[6]) ?? [];
  object.minutes = reader.readLong(offsets[7]);
  object.note = reader.readString(offsets[8]);
  object.originalId = reader.readString(offsets[9]);
  object.subject = reader.readString(offsets[10]);
  object.topic = reader.readString(offsets[11]);
  object.wrong = reader.readLong(offsets[12]);
  return object;
}

P _questionEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readStringList(offset) ?? []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _questionEntityGetId(QuestionEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _questionEntityGetLinks(QuestionEntity object) {
  return [];
}

void _questionEntityAttach(
    IsarCollection<dynamic> col, Id id, QuestionEntity object) {
  object.id = id;
}

extension QuestionEntityByIndex on IsarCollection<QuestionEntity> {
  Future<QuestionEntity?> getByOriginalId(String originalId) {
    return getByIndex(r'originalId', [originalId]);
  }

  QuestionEntity? getByOriginalIdSync(String originalId) {
    return getByIndexSync(r'originalId', [originalId]);
  }

  Future<bool> deleteByOriginalId(String originalId) {
    return deleteByIndex(r'originalId', [originalId]);
  }

  bool deleteByOriginalIdSync(String originalId) {
    return deleteByIndexSync(r'originalId', [originalId]);
  }

  Future<List<QuestionEntity?>> getAllByOriginalId(
      List<String> originalIdValues) {
    final values = originalIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'originalId', values);
  }

  List<QuestionEntity?> getAllByOriginalIdSync(List<String> originalIdValues) {
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

  Future<Id> putByOriginalId(QuestionEntity object) {
    return putByIndex(r'originalId', object);
  }

  Id putByOriginalIdSync(QuestionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'originalId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOriginalId(List<QuestionEntity> objects) {
    return putAllByIndex(r'originalId', objects);
  }

  List<Id> putAllByOriginalIdSync(List<QuestionEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'originalId', objects, saveLinks: saveLinks);
  }
}

extension QuestionEntityQueryWhereSort
    on QueryBuilder<QuestionEntity, QuestionEntity, QWhere> {
  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhere> anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
    });
  }
}

extension QuestionEntityQueryWhere
    on QueryBuilder<QuestionEntity, QuestionEntity, QWhereClause> {
  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause>
      originalIdEqualTo(String originalId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'originalId',
        value: [originalId],
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause> topicEqualTo(
      String topic) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'topic',
        value: [topic],
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause>
      topicNotEqualTo(String topic) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topic',
              lower: [],
              upper: [topic],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topic',
              lower: [topic],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topic',
              lower: [topic],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'topic',
              lower: [],
              upper: [topic],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterWhereClause>
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

extension QuestionEntityQueryFilter
    on QueryBuilder<QuestionEntity, QuestionEntity, QFilterCondition> {
  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      blankEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'blank',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bookName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bookName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bookName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bookName',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      bookNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bookName',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      correctEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'correct',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'errorTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'errorTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'errorTags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'errorTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'errorTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'errorTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'errorTags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'errorTags',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'errorTags',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      errorTagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'errorTags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      examTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'examType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      examTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'examType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      examTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'examType',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      examTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'examType',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imagePaths',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imagePaths',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imagePaths',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imagePaths',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imagePaths',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      imagePathsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'imagePaths',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      minutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minutes',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      originalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      originalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      originalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalId',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      originalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalId',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subject',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subject',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subject',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      subjectIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subject',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topic',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topic',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topic',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topic',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      topicIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topic',
        value: '',
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
      wrongEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wrong',
        value: value,
      ));
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterFilterCondition>
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

extension QuestionEntityQueryObject
    on QueryBuilder<QuestionEntity, QuestionEntity, QFilterCondition> {}

extension QuestionEntityQueryLinks
    on QueryBuilder<QuestionEntity, QuestionEntity, QFilterCondition> {}

extension QuestionEntityQuerySortBy
    on QueryBuilder<QuestionEntity, QuestionEntity, QSortBy> {
  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByBlank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blank', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByBlankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blank', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByBookName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookName', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      sortByBookNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookName', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      sortByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByExamType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      sortByExamTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutes', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      sortByMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutes', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      sortByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      sortByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      sortBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByWrong() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrong', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> sortByWrongDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrong', Sort.desc);
    });
  }
}

extension QuestionEntityQuerySortThenBy
    on QueryBuilder<QuestionEntity, QuestionEntity, QSortThenBy> {
  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByBlank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blank', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByBlankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'blank', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByBookName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookName', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      thenByBookNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bookName', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      thenByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'correct', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByExamType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      thenByExamTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'examType', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutes', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      thenByMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minutes', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      thenByOriginalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      thenByOriginalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalId', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenBySubject() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy>
      thenBySubjectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subject', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByTopic() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByTopicDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'topic', Sort.desc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByWrong() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrong', Sort.asc);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QAfterSortBy> thenByWrongDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wrong', Sort.desc);
    });
  }
}

extension QuestionEntityQueryWhereDistinct
    on QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> {
  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctByBlank() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'blank');
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctByBookName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bookName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'correct');
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct>
      distinctByErrorTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'errorTags');
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctByExamType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'examType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct>
      distinctByImagePaths() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePaths');
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctByMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minutes');
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctByOriginalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctBySubject(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subject', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctByTopic(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topic', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<QuestionEntity, QuestionEntity, QDistinct> distinctByWrong() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wrong');
    });
  }
}

extension QuestionEntityQueryProperty
    on QueryBuilder<QuestionEntity, QuestionEntity, QQueryProperty> {
  QueryBuilder<QuestionEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<QuestionEntity, int, QQueryOperations> blankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'blank');
    });
  }

  QueryBuilder<QuestionEntity, String, QQueryOperations> bookNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bookName');
    });
  }

  QueryBuilder<QuestionEntity, int, QQueryOperations> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'correct');
    });
  }

  QueryBuilder<QuestionEntity, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<QuestionEntity, List<String>, QQueryOperations>
      errorTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'errorTags');
    });
  }

  QueryBuilder<QuestionEntity, String, QQueryOperations> examTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'examType');
    });
  }

  QueryBuilder<QuestionEntity, List<String>, QQueryOperations>
      imagePathsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePaths');
    });
  }

  QueryBuilder<QuestionEntity, int, QQueryOperations> minutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minutes');
    });
  }

  QueryBuilder<QuestionEntity, String, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<QuestionEntity, String, QQueryOperations> originalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalId');
    });
  }

  QueryBuilder<QuestionEntity, String, QQueryOperations> subjectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subject');
    });
  }

  QueryBuilder<QuestionEntity, String, QQueryOperations> topicProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topic');
    });
  }

  QueryBuilder<QuestionEntity, int, QQueryOperations> wrongProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wrong');
    });
  }
}
