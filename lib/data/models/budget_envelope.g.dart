// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_envelope.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBudgetEnvelopeCollection on Isar {
  IsarCollection<BudgetEnvelope> get budgetEnvelopes => this.collection();
}

const BudgetEnvelopeSchema = CollectionSchema(
  name: r'BudgetEnvelope',
  id: -3782551566095700322,
  properties: {
    r'autoRepeat': PropertySchema(
      id: 0,
      name: r'autoRepeat',
      type: IsarType.bool,
    ),
    r'categoryAllocations': PropertySchema(
      id: 1,
      name: r'categoryAllocations',
      type: IsarType.objectList,

      target: r'EnvelopeCategoryAllocation',
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'exceededNotified': PropertySchema(
      id: 3,
      name: r'exceededNotified',
      type: IsarType.bool,
    ),
    r'fundingSplits': PropertySchema(
      id: 4,
      name: r'fundingSplits',
      type: IsarType.objectList,

      target: r'EnvelopeFundingSplit',
    ),
    r'lastCycleStart': PropertySchema(
      id: 5,
      name: r'lastCycleStart',
      type: IsarType.dateTime,
    ),
    r'lastFundingCycleStart': PropertySchema(
      id: 6,
      name: r'lastFundingCycleStart',
      type: IsarType.dateTime,
    ),
    r'periodEnd': PropertySchema(
      id: 7,
      name: r'periodEnd',
      type: IsarType.dateTime,
    ),
    r'periodStart': PropertySchema(
      id: 8,
      name: r'periodStart',
      type: IsarType.dateTime,
    ),
    r'periodType': PropertySchema(
      id: 9,
      name: r'periodType',
      type: IsarType.string,
    ),
    r'profileId': PropertySchema(
      id: 10,
      name: r'profileId',
      type: IsarType.long,
    ),
    r'totalAmount': PropertySchema(
      id: 11,
      name: r'totalAmount',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'warningNotified': PropertySchema(
      id: 13,
      name: r'warningNotified',
      type: IsarType.bool,
    ),
    r'warningThreshold': PropertySchema(
      id: 14,
      name: r'warningThreshold',
      type: IsarType.double,
    ),
  },

  estimateSize: _budgetEnvelopeEstimateSize,
  serialize: _budgetEnvelopeSerialize,
  deserialize: _budgetEnvelopeDeserialize,
  deserializeProp: _budgetEnvelopeDeserializeProp,
  idName: r'id',
  indexes: {
    r'profileId': IndexSchema(
      id: 6052971939042612300,
      name: r'profileId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'profileId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {
    r'EnvelopeCategoryAllocation': EnvelopeCategoryAllocationSchema,
    r'EnvelopeFundingSplit': EnvelopeFundingSplitSchema,
  },

  getId: _budgetEnvelopeGetId,
  getLinks: _budgetEnvelopeGetLinks,
  attach: _budgetEnvelopeAttach,
  version: '3.3.2',
);

int _budgetEnvelopeEstimateSize(
  BudgetEnvelope object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.categoryAllocations.length * 3;
  {
    final offsets = allOffsets[EnvelopeCategoryAllocation]!;
    for (var i = 0; i < object.categoryAllocations.length; i++) {
      final value = object.categoryAllocations[i];
      bytesCount += EnvelopeCategoryAllocationSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.fundingSplits.length * 3;
  {
    final offsets = allOffsets[EnvelopeFundingSplit]!;
    for (var i = 0; i < object.fundingSplits.length; i++) {
      final value = object.fundingSplits[i];
      bytesCount += EnvelopeFundingSplitSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  bytesCount += 3 + object.periodType.length * 3;
  return bytesCount;
}

void _budgetEnvelopeSerialize(
  BudgetEnvelope object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.autoRepeat);
  writer.writeObjectList<EnvelopeCategoryAllocation>(
    offsets[1],
    allOffsets,
    EnvelopeCategoryAllocationSchema.serialize,
    object.categoryAllocations,
  );
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeBool(offsets[3], object.exceededNotified);
  writer.writeObjectList<EnvelopeFundingSplit>(
    offsets[4],
    allOffsets,
    EnvelopeFundingSplitSchema.serialize,
    object.fundingSplits,
  );
  writer.writeDateTime(offsets[5], object.lastCycleStart);
  writer.writeDateTime(offsets[6], object.lastFundingCycleStart);
  writer.writeDateTime(offsets[7], object.periodEnd);
  writer.writeDateTime(offsets[8], object.periodStart);
  writer.writeString(offsets[9], object.periodType);
  writer.writeLong(offsets[10], object.profileId);
  writer.writeDouble(offsets[11], object.totalAmount);
  writer.writeDateTime(offsets[12], object.updatedAt);
  writer.writeBool(offsets[13], object.warningNotified);
  writer.writeDouble(offsets[14], object.warningThreshold);
}

BudgetEnvelope _budgetEnvelopeDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BudgetEnvelope();
  object.autoRepeat = reader.readBool(offsets[0]);
  object.categoryAllocations =
      reader.readObjectList<EnvelopeCategoryAllocation>(
        offsets[1],
        EnvelopeCategoryAllocationSchema.deserialize,
        allOffsets,
        EnvelopeCategoryAllocation(),
      ) ??
      [];
  object.createdAt = reader.readDateTime(offsets[2]);
  object.exceededNotified = reader.readBool(offsets[3]);
  object.fundingSplits =
      reader.readObjectList<EnvelopeFundingSplit>(
        offsets[4],
        EnvelopeFundingSplitSchema.deserialize,
        allOffsets,
        EnvelopeFundingSplit(),
      ) ??
      [];
  object.id = id;
  object.lastCycleStart = reader.readDateTimeOrNull(offsets[5]);
  object.lastFundingCycleStart = reader.readDateTimeOrNull(offsets[6]);
  object.periodEnd = reader.readDateTime(offsets[7]);
  object.periodStart = reader.readDateTime(offsets[8]);
  object.periodType = reader.readString(offsets[9]);
  object.profileId = reader.readLong(offsets[10]);
  object.totalAmount = reader.readDouble(offsets[11]);
  object.updatedAt = reader.readDateTime(offsets[12]);
  object.warningNotified = reader.readBool(offsets[13]);
  object.warningThreshold = reader.readDouble(offsets[14]);
  return object;
}

P _budgetEnvelopeDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readObjectList<EnvelopeCategoryAllocation>(
                offset,
                EnvelopeCategoryAllocationSchema.deserialize,
                allOffsets,
                EnvelopeCategoryAllocation(),
              ) ??
              [])
          as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readObjectList<EnvelopeFundingSplit>(
                offset,
                EnvelopeFundingSplitSchema.deserialize,
                allOffsets,
                EnvelopeFundingSplit(),
              ) ??
              [])
          as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _budgetEnvelopeGetId(BudgetEnvelope object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _budgetEnvelopeGetLinks(BudgetEnvelope object) {
  return [];
}

void _budgetEnvelopeAttach(
  IsarCollection<dynamic> col,
  Id id,
  BudgetEnvelope object,
) {
  object.id = id;
}

extension BudgetEnvelopeQueryWhereSort
    on QueryBuilder<BudgetEnvelope, BudgetEnvelope, QWhere> {
  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhere> anyProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'profileId'),
      );
    });
  }
}

extension BudgetEnvelopeQueryWhere
    on QueryBuilder<BudgetEnvelope, BudgetEnvelope, QWhereClause> {
  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause>
  profileIdEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'profileId', value: [profileId]),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause>
  profileIdNotEqualTo(int profileId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'profileId',
                lower: [],
                upper: [profileId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'profileId',
                lower: [profileId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'profileId',
                lower: [profileId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'profileId',
                lower: [],
                upper: [profileId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause>
  profileIdGreaterThan(int profileId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'profileId',
          lower: [profileId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause>
  profileIdLessThan(int profileId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'profileId',
          lower: [],
          upper: [profileId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterWhereClause>
  profileIdBetween(
    int lowerProfileId,
    int upperProfileId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'profileId',
          lower: [lowerProfileId],
          includeLower: includeLower,
          upper: [upperProfileId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BudgetEnvelopeQueryFilter
    on QueryBuilder<BudgetEnvelope, BudgetEnvelope, QFilterCondition> {
  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  autoRepeatEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoRepeat', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  categoryAllocationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categoryAllocations',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  categoryAllocationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'categoryAllocations', 0, true, 0, true);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  categoryAllocationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'categoryAllocations', 0, false, 999999, true);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  categoryAllocationsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'categoryAllocations', 0, true, length, include);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  categoryAllocationsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categoryAllocations',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  categoryAllocationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'categoryAllocations',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'createdAt', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  createdAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'createdAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'createdAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  exceededNotifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'exceededNotified', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  fundingSplitsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fundingSplits', length, true, length, true);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  fundingSplitsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fundingSplits', 0, true, 0, true);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  fundingSplitsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fundingSplits', 0, false, 999999, true);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  fundingSplitsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fundingSplits', 0, true, length, include);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  fundingSplitsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'fundingSplits', length, include, 999999, true);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  fundingSplitsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'fundingSplits',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastCycleStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastCycleStart'),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastCycleStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastCycleStart'),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastCycleStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastCycleStart', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastCycleStartGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastCycleStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastCycleStartLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastCycleStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastCycleStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastCycleStart',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastFundingCycleStartIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastFundingCycleStart'),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastFundingCycleStartIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastFundingCycleStart'),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastFundingCycleStartEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastFundingCycleStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastFundingCycleStartGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastFundingCycleStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastFundingCycleStartLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastFundingCycleStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  lastFundingCycleStartBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastFundingCycleStart',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodEndEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'periodEnd', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodEndGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'periodEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodEndLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'periodEnd',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodEndBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'periodEnd',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodStartEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'periodStart', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodStartGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'periodStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodStartLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'periodStart',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodStartBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'periodStart',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'periodType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'periodType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'periodType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'periodType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'periodType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'periodType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'periodType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'periodType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'periodType', value: ''),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  periodTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'periodType', value: ''),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  profileIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'profileId', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  profileIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'profileId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  profileIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'profileId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  profileIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'profileId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  totalAmountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totalAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  totalAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  totalAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalAmount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  totalAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalAmount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  updatedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  warningNotifiedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'warningNotified', value: value),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  warningThresholdEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'warningThreshold',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  warningThresholdGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'warningThreshold',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  warningThresholdLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'warningThreshold',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  warningThresholdBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'warningThreshold',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension BudgetEnvelopeQueryObject
    on QueryBuilder<BudgetEnvelope, BudgetEnvelope, QFilterCondition> {
  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  categoryAllocationsElement(FilterQuery<EnvelopeCategoryAllocation> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'categoryAllocations');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterFilterCondition>
  fundingSplitsElement(FilterQuery<EnvelopeFundingSplit> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'fundingSplits');
    });
  }
}

extension BudgetEnvelopeQueryLinks
    on QueryBuilder<BudgetEnvelope, BudgetEnvelope, QFilterCondition> {}

extension BudgetEnvelopeQuerySortBy
    on QueryBuilder<BudgetEnvelope, BudgetEnvelope, QSortBy> {
  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByAutoRepeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRepeat', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByAutoRepeatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRepeat', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByExceededNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exceededNotified', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByExceededNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exceededNotified', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByLastCycleStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCycleStart', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByLastCycleStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCycleStart', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByLastFundingCycleStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFundingCycleStart', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByLastFundingCycleStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFundingCycleStart', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> sortByPeriodEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByPeriodEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByPeriodStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByPeriodStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByPeriodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByPeriodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> sortByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByWarningNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningNotified', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByWarningNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningNotified', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByWarningThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningThreshold', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  sortByWarningThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningThreshold', Sort.desc);
    });
  }
}

extension BudgetEnvelopeQuerySortThenBy
    on QueryBuilder<BudgetEnvelope, BudgetEnvelope, QSortThenBy> {
  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByAutoRepeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRepeat', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByAutoRepeatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoRepeat', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByExceededNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exceededNotified', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByExceededNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exceededNotified', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByLastCycleStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCycleStart', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByLastCycleStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCycleStart', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByLastFundingCycleStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFundingCycleStart', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByLastFundingCycleStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastFundingCycleStart', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> thenByPeriodEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByPeriodEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodEnd', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByPeriodStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByPeriodStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodStart', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByPeriodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByPeriodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'periodType', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> thenByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByProfileIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'profileId', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByTotalAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalAmount', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByWarningNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningNotified', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByWarningNotifiedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningNotified', Sort.desc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByWarningThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningThreshold', Sort.asc);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QAfterSortBy>
  thenByWarningThresholdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'warningThreshold', Sort.desc);
    });
  }
}

extension BudgetEnvelopeQueryWhereDistinct
    on QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct> {
  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByAutoRepeat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoRepeat');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByExceededNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exceededNotified');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByLastCycleStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCycleStart');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByLastFundingCycleStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastFundingCycleStart');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByPeriodEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodEnd');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByPeriodStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodStart');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct> distinctByPeriodType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'periodType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByProfileId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'profileId');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByTotalAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalAmount');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByWarningNotified() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'warningNotified');
    });
  }

  QueryBuilder<BudgetEnvelope, BudgetEnvelope, QDistinct>
  distinctByWarningThreshold() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'warningThreshold');
    });
  }
}

extension BudgetEnvelopeQueryProperty
    on QueryBuilder<BudgetEnvelope, BudgetEnvelope, QQueryProperty> {
  QueryBuilder<BudgetEnvelope, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BudgetEnvelope, bool, QQueryOperations> autoRepeatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoRepeat');
    });
  }

  QueryBuilder<
    BudgetEnvelope,
    List<EnvelopeCategoryAllocation>,
    QQueryOperations
  >
  categoryAllocationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryAllocations');
    });
  }

  QueryBuilder<BudgetEnvelope, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<BudgetEnvelope, bool, QQueryOperations>
  exceededNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exceededNotified');
    });
  }

  QueryBuilder<BudgetEnvelope, List<EnvelopeFundingSplit>, QQueryOperations>
  fundingSplitsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fundingSplits');
    });
  }

  QueryBuilder<BudgetEnvelope, DateTime?, QQueryOperations>
  lastCycleStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCycleStart');
    });
  }

  QueryBuilder<BudgetEnvelope, DateTime?, QQueryOperations>
  lastFundingCycleStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastFundingCycleStart');
    });
  }

  QueryBuilder<BudgetEnvelope, DateTime, QQueryOperations> periodEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodEnd');
    });
  }

  QueryBuilder<BudgetEnvelope, DateTime, QQueryOperations>
  periodStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodStart');
    });
  }

  QueryBuilder<BudgetEnvelope, String, QQueryOperations> periodTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'periodType');
    });
  }

  QueryBuilder<BudgetEnvelope, int, QQueryOperations> profileIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'profileId');
    });
  }

  QueryBuilder<BudgetEnvelope, double, QQueryOperations> totalAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalAmount');
    });
  }

  QueryBuilder<BudgetEnvelope, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<BudgetEnvelope, bool, QQueryOperations>
  warningNotifiedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'warningNotified');
    });
  }

  QueryBuilder<BudgetEnvelope, double, QQueryOperations>
  warningThresholdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'warningThreshold');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const EnvelopeCategoryAllocationSchema = Schema(
  name: r'EnvelopeCategoryAllocation',
  id: -6893343906424937558,
  properties: {
    r'amount': PropertySchema(id: 0, name: r'amount', type: IsarType.double),
    r'categoryId': PropertySchema(
      id: 1,
      name: r'categoryId',
      type: IsarType.long,
    ),
  },

  estimateSize: _envelopeCategoryAllocationEstimateSize,
  serialize: _envelopeCategoryAllocationSerialize,
  deserialize: _envelopeCategoryAllocationDeserialize,
  deserializeProp: _envelopeCategoryAllocationDeserializeProp,
);

int _envelopeCategoryAllocationEstimateSize(
  EnvelopeCategoryAllocation object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _envelopeCategoryAllocationSerialize(
  EnvelopeCategoryAllocation object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeLong(offsets[1], object.categoryId);
}

EnvelopeCategoryAllocation _envelopeCategoryAllocationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EnvelopeCategoryAllocation();
  object.amount = reader.readDouble(offsets[0]);
  object.categoryId = reader.readLong(offsets[1]);
  return object;
}

P _envelopeCategoryAllocationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension EnvelopeCategoryAllocationQueryFilter
    on
        QueryBuilder<
          EnvelopeCategoryAllocation,
          EnvelopeCategoryAllocation,
          QFilterCondition
        > {
  QueryBuilder<
    EnvelopeCategoryAllocation,
    EnvelopeCategoryAllocation,
    QAfterFilterCondition
  >
  amountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeCategoryAllocation,
    EnvelopeCategoryAllocation,
    QAfterFilterCondition
  >
  amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeCategoryAllocation,
    EnvelopeCategoryAllocation,
    QAfterFilterCondition
  >
  amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeCategoryAllocation,
    EnvelopeCategoryAllocation,
    QAfterFilterCondition
  >
  amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeCategoryAllocation,
    EnvelopeCategoryAllocation,
    QAfterFilterCondition
  >
  categoryIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'categoryId', value: value),
      );
    });
  }

  QueryBuilder<
    EnvelopeCategoryAllocation,
    EnvelopeCategoryAllocation,
    QAfterFilterCondition
  >
  categoryIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'categoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeCategoryAllocation,
    EnvelopeCategoryAllocation,
    QAfterFilterCondition
  >
  categoryIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'categoryId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeCategoryAllocation,
    EnvelopeCategoryAllocation,
    QAfterFilterCondition
  >
  categoryIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'categoryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension EnvelopeCategoryAllocationQueryObject
    on
        QueryBuilder<
          EnvelopeCategoryAllocation,
          EnvelopeCategoryAllocation,
          QFilterCondition
        > {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const EnvelopeFundingSplitSchema = Schema(
  name: r'EnvelopeFundingSplit',
  id: 5214385463788507757,
  properties: {
    r'accountId': PropertySchema(
      id: 0,
      name: r'accountId',
      type: IsarType.long,
    ),
    r'amount': PropertySchema(id: 1, name: r'amount', type: IsarType.double),
  },

  estimateSize: _envelopeFundingSplitEstimateSize,
  serialize: _envelopeFundingSplitSerialize,
  deserialize: _envelopeFundingSplitDeserialize,
  deserializeProp: _envelopeFundingSplitDeserializeProp,
);

int _envelopeFundingSplitEstimateSize(
  EnvelopeFundingSplit object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _envelopeFundingSplitSerialize(
  EnvelopeFundingSplit object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.accountId);
  writer.writeDouble(offsets[1], object.amount);
}

EnvelopeFundingSplit _envelopeFundingSplitDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EnvelopeFundingSplit();
  object.accountId = reader.readLong(offsets[0]);
  object.amount = reader.readDouble(offsets[1]);
  return object;
}

P _envelopeFundingSplitDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension EnvelopeFundingSplitQueryFilter
    on
        QueryBuilder<
          EnvelopeFundingSplit,
          EnvelopeFundingSplit,
          QFilterCondition
        > {
  QueryBuilder<
    EnvelopeFundingSplit,
    EnvelopeFundingSplit,
    QAfterFilterCondition
  >
  accountIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'accountId', value: value),
      );
    });
  }

  QueryBuilder<
    EnvelopeFundingSplit,
    EnvelopeFundingSplit,
    QAfterFilterCondition
  >
  accountIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'accountId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeFundingSplit,
    EnvelopeFundingSplit,
    QAfterFilterCondition
  >
  accountIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'accountId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeFundingSplit,
    EnvelopeFundingSplit,
    QAfterFilterCondition
  >
  accountIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'accountId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeFundingSplit,
    EnvelopeFundingSplit,
    QAfterFilterCondition
  >
  amountEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeFundingSplit,
    EnvelopeFundingSplit,
    QAfterFilterCondition
  >
  amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeFundingSplit,
    EnvelopeFundingSplit,
    QAfterFilterCondition
  >
  amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'amount',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<
    EnvelopeFundingSplit,
    EnvelopeFundingSplit,
    QAfterFilterCondition
  >
  amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'amount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension EnvelopeFundingSplitQueryObject
    on
        QueryBuilder<
          EnvelopeFundingSplit,
          EnvelopeFundingSplit,
          QFilterCondition
        > {}
