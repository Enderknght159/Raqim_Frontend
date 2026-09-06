// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CacheEntriesTable extends CacheEntries
    with TableInfo<$CacheEntriesTable, CacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonDataMeta = const VerificationMeta(
    'jsonData',
  );
  @override
  late final GeneratedColumn<String> jsonData = GeneratedColumn<String>(
    'json_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cacheKey,
    scope,
    entityType,
    jsonData,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('json_data')) {
      context.handle(
        _jsonDataMeta,
        jsonData.isAcceptableOrUnknown(data['json_data']!, _jsonDataMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonDataMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  CacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheEntry(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      jsonData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_data'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CacheEntriesTable createAlias(String alias) {
    return $CacheEntriesTable(attachedDatabase, alias);
  }
}

class CacheEntry extends DataClass implements Insertable<CacheEntry> {
  final String cacheKey;
  final String scope;
  final String entityType;
  final String jsonData;
  final DateTime cachedAt;
  const CacheEntry({
    required this.cacheKey,
    required this.scope,
    required this.entityType,
    required this.jsonData,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['scope'] = Variable<String>(scope);
    map['entity_type'] = Variable<String>(entityType);
    map['json_data'] = Variable<String>(jsonData);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return CacheEntriesCompanion(
      cacheKey: Value(cacheKey),
      scope: Value(scope),
      entityType: Value(entityType),
      jsonData: Value(jsonData),
      cachedAt: Value(cachedAt),
    );
  }

  factory CacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheEntry(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      scope: serializer.fromJson<String>(json['scope']),
      entityType: serializer.fromJson<String>(json['entityType']),
      jsonData: serializer.fromJson<String>(json['jsonData']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'scope': serializer.toJson<String>(scope),
      'entityType': serializer.toJson<String>(entityType),
      'jsonData': serializer.toJson<String>(jsonData),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CacheEntry copyWith({
    String? cacheKey,
    String? scope,
    String? entityType,
    String? jsonData,
    DateTime? cachedAt,
  }) => CacheEntry(
    cacheKey: cacheKey ?? this.cacheKey,
    scope: scope ?? this.scope,
    entityType: entityType ?? this.entityType,
    jsonData: jsonData ?? this.jsonData,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CacheEntry copyWithCompanion(CacheEntriesCompanion data) {
    return CacheEntry(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      scope: data.scope.present ? data.scope.value : this.scope,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      jsonData: data.jsonData.present ? data.jsonData.value : this.jsonData,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntry(')
          ..write('cacheKey: $cacheKey, ')
          ..write('scope: $scope, ')
          ..write('entityType: $entityType, ')
          ..write('jsonData: $jsonData, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(cacheKey, scope, entityType, jsonData, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheEntry &&
          other.cacheKey == this.cacheKey &&
          other.scope == this.scope &&
          other.entityType == this.entityType &&
          other.jsonData == this.jsonData &&
          other.cachedAt == this.cachedAt);
}

class CacheEntriesCompanion extends UpdateCompanion<CacheEntry> {
  final Value<String> cacheKey;
  final Value<String> scope;
  final Value<String> entityType;
  final Value<String> jsonData;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CacheEntriesCompanion({
    this.cacheKey = const Value.absent(),
    this.scope = const Value.absent(),
    this.entityType = const Value.absent(),
    this.jsonData = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheEntriesCompanion.insert({
    required String cacheKey,
    required String scope,
    required String entityType,
    required String jsonData,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       scope = Value(scope),
       entityType = Value(entityType),
       jsonData = Value(jsonData);
  static Insertable<CacheEntry> custom({
    Expression<String>? cacheKey,
    Expression<String>? scope,
    Expression<String>? entityType,
    Expression<String>? jsonData,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (scope != null) 'scope': scope,
      if (entityType != null) 'entity_type': entityType,
      if (jsonData != null) 'json_data': jsonData,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheEntriesCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? scope,
    Value<String>? entityType,
    Value<String>? jsonData,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CacheEntriesCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      scope: scope ?? this.scope,
      entityType: entityType ?? this.entityType,
      jsonData: jsonData ?? this.jsonData,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (jsonData.present) {
      map['json_data'] = Variable<String>(jsonData.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheEntriesCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('scope: $scope, ')
          ..write('entityType: $entityType, ')
          ..write('jsonData: $jsonData, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangeQueueEntriesTable extends ChangeQueueEntries
    with TableInfo<$ChangeQueueEntriesTable, ChangeQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _changeIdMeta = const VerificationMeta(
    'changeId',
  );
  @override
  late final GeneratedColumn<int> changeId = GeneratedColumn<int>(
    'change_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectIdMeta = const VerificationMeta(
    'objectId',
  );
  @override
  late final GeneratedColumn<int> objectId = GeneratedColumn<int>(
    'object_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientTsMeta = const VerificationMeta(
    'clientTs',
  );
  @override
  late final GeneratedColumn<DateTime> clientTs = GeneratedColumn<DateTime>(
    'client_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    changeId,
    entity,
    objectId,
    field,
    value,
    clientTs,
    status,
    attemptCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'change_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChangeQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('change_id')) {
      context.handle(
        _changeIdMeta,
        changeId.isAcceptableOrUnknown(data['change_id']!, _changeIdMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('object_id')) {
      context.handle(
        _objectIdMeta,
        objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('client_ts')) {
      context.handle(
        _clientTsMeta,
        clientTs.isAcceptableOrUnknown(data['client_ts']!, _clientTsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {changeId};
  @override
  ChangeQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeQueueEntry(
      changeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      objectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}object_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      clientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_ts'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
    );
  }

  @override
  $ChangeQueueEntriesTable createAlias(String alias) {
    return $ChangeQueueEntriesTable(attachedDatabase, alias);
  }
}

class ChangeQueueEntry extends DataClass
    implements Insertable<ChangeQueueEntry> {
  final int changeId;
  final String entity;
  final int objectId;
  final String field;
  final String value;
  final DateTime clientTs;
  final String status;
  final int attemptCount;
  const ChangeQueueEntry({
    required this.changeId,
    required this.entity,
    required this.objectId,
    required this.field,
    required this.value,
    required this.clientTs,
    required this.status,
    required this.attemptCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['change_id'] = Variable<int>(changeId);
    map['entity'] = Variable<String>(entity);
    map['object_id'] = Variable<int>(objectId);
    map['field'] = Variable<String>(field);
    map['value'] = Variable<String>(value);
    map['client_ts'] = Variable<DateTime>(clientTs);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    return map;
  }

  ChangeQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return ChangeQueueEntriesCompanion(
      changeId: Value(changeId),
      entity: Value(entity),
      objectId: Value(objectId),
      field: Value(field),
      value: Value(value),
      clientTs: Value(clientTs),
      status: Value(status),
      attemptCount: Value(attemptCount),
    );
  }

  factory ChangeQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeQueueEntry(
      changeId: serializer.fromJson<int>(json['changeId']),
      entity: serializer.fromJson<String>(json['entity']),
      objectId: serializer.fromJson<int>(json['objectId']),
      field: serializer.fromJson<String>(json['field']),
      value: serializer.fromJson<String>(json['value']),
      clientTs: serializer.fromJson<DateTime>(json['clientTs']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'changeId': serializer.toJson<int>(changeId),
      'entity': serializer.toJson<String>(entity),
      'objectId': serializer.toJson<int>(objectId),
      'field': serializer.toJson<String>(field),
      'value': serializer.toJson<String>(value),
      'clientTs': serializer.toJson<DateTime>(clientTs),
      'status': serializer.toJson<String>(status),
      'attemptCount': serializer.toJson<int>(attemptCount),
    };
  }

  ChangeQueueEntry copyWith({
    int? changeId,
    String? entity,
    int? objectId,
    String? field,
    String? value,
    DateTime? clientTs,
    String? status,
    int? attemptCount,
  }) => ChangeQueueEntry(
    changeId: changeId ?? this.changeId,
    entity: entity ?? this.entity,
    objectId: objectId ?? this.objectId,
    field: field ?? this.field,
    value: value ?? this.value,
    clientTs: clientTs ?? this.clientTs,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
  );
  ChangeQueueEntry copyWithCompanion(ChangeQueueEntriesCompanion data) {
    return ChangeQueueEntry(
      changeId: data.changeId.present ? data.changeId.value : this.changeId,
      entity: data.entity.present ? data.entity.value : this.entity,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      field: data.field.present ? data.field.value : this.field,
      value: data.value.present ? data.value.value : this.value,
      clientTs: data.clientTs.present ? data.clientTs.value : this.clientTs,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeQueueEntry(')
          ..write('changeId: $changeId, ')
          ..write('entity: $entity, ')
          ..write('objectId: $objectId, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('clientTs: $clientTs, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    changeId,
    entity,
    objectId,
    field,
    value,
    clientTs,
    status,
    attemptCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeQueueEntry &&
          other.changeId == this.changeId &&
          other.entity == this.entity &&
          other.objectId == this.objectId &&
          other.field == this.field &&
          other.value == this.value &&
          other.clientTs == this.clientTs &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount);
}

class ChangeQueueEntriesCompanion extends UpdateCompanion<ChangeQueueEntry> {
  final Value<int> changeId;
  final Value<String> entity;
  final Value<int> objectId;
  final Value<String> field;
  final Value<String> value;
  final Value<DateTime> clientTs;
  final Value<String> status;
  final Value<int> attemptCount;
  const ChangeQueueEntriesCompanion({
    this.changeId = const Value.absent(),
    this.entity = const Value.absent(),
    this.objectId = const Value.absent(),
    this.field = const Value.absent(),
    this.value = const Value.absent(),
    this.clientTs = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
  });
  ChangeQueueEntriesCompanion.insert({
    this.changeId = const Value.absent(),
    required String entity,
    required int objectId,
    required String field,
    required String value,
    this.clientTs = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
  }) : entity = Value(entity),
       objectId = Value(objectId),
       field = Value(field),
       value = Value(value);
  static Insertable<ChangeQueueEntry> custom({
    Expression<int>? changeId,
    Expression<String>? entity,
    Expression<int>? objectId,
    Expression<String>? field,
    Expression<String>? value,
    Expression<DateTime>? clientTs,
    Expression<String>? status,
    Expression<int>? attemptCount,
  }) {
    return RawValuesInsertable({
      if (changeId != null) 'change_id': changeId,
      if (entity != null) 'entity': entity,
      if (objectId != null) 'object_id': objectId,
      if (field != null) 'field': field,
      if (value != null) 'value': value,
      if (clientTs != null) 'client_ts': clientTs,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
    });
  }

  ChangeQueueEntriesCompanion copyWith({
    Value<int>? changeId,
    Value<String>? entity,
    Value<int>? objectId,
    Value<String>? field,
    Value<String>? value,
    Value<DateTime>? clientTs,
    Value<String>? status,
    Value<int>? attemptCount,
  }) {
    return ChangeQueueEntriesCompanion(
      changeId: changeId ?? this.changeId,
      entity: entity ?? this.entity,
      objectId: objectId ?? this.objectId,
      field: field ?? this.field,
      value: value ?? this.value,
      clientTs: clientTs ?? this.clientTs,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (changeId.present) {
      map['change_id'] = Variable<int>(changeId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<int>(objectId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (clientTs.present) {
      map['client_ts'] = Variable<DateTime>(clientTs.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeQueueEntriesCompanion(')
          ..write('changeId: $changeId, ')
          ..write('entity: $entity, ')
          ..write('objectId: $objectId, ')
          ..write('field: $field, ')
          ..write('value: $value, ')
          ..write('clientTs: $clientTs, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount')
          ..write(')'))
        .toString();
  }
}

class $SyncLogEntriesTable extends SyncLogEntries
    with TableInfo<$SyncLogEntriesTable, SyncLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<int> syncId = GeneratedColumn<int>(
    'sync_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _changeIdMeta = const VerificationMeta(
    'changeId',
  );
  @override
  late final GeneratedColumn<int> changeId = GeneratedColumn<int>(
    'change_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _objectIdMeta = const VerificationMeta(
    'objectId',
  );
  @override
  late final GeneratedColumn<int> objectId = GeneratedColumn<int>(
    'object_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    changeId,
    entity,
    objectId,
    status,
    message,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_log_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncLogEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('change_id')) {
      context.handle(
        _changeIdMeta,
        changeId.isAcceptableOrUnknown(data['change_id']!, _changeIdMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('object_id')) {
      context.handle(
        _objectIdMeta,
        objectId.isAcceptableOrUnknown(data['object_id']!, _objectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_objectIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {syncId};
  @override
  SyncLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncLogEntry(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_id'],
      )!,
      changeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}change_id'],
      ),
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      objectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}object_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $SyncLogEntriesTable createAlias(String alias) {
    return $SyncLogEntriesTable(attachedDatabase, alias);
  }
}

class SyncLogEntry extends DataClass implements Insertable<SyncLogEntry> {
  final int syncId;
  final int? changeId;
  final String entity;
  final int objectId;
  final String status;
  final String? message;
  final DateTime syncedAt;
  const SyncLogEntry({
    required this.syncId,
    this.changeId,
    required this.entity,
    required this.objectId,
    required this.status,
    this.message,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<int>(syncId);
    if (!nullToAbsent || changeId != null) {
      map['change_id'] = Variable<int>(changeId);
    }
    map['entity'] = Variable<String>(entity);
    map['object_id'] = Variable<int>(objectId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  SyncLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncLogEntriesCompanion(
      syncId: Value(syncId),
      changeId: changeId == null && nullToAbsent
          ? const Value.absent()
          : Value(changeId),
      entity: Value(entity),
      objectId: Value(objectId),
      status: Value(status),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      syncedAt: Value(syncedAt),
    );
  }

  factory SyncLogEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncLogEntry(
      syncId: serializer.fromJson<int>(json['syncId']),
      changeId: serializer.fromJson<int?>(json['changeId']),
      entity: serializer.fromJson<String>(json['entity']),
      objectId: serializer.fromJson<int>(json['objectId']),
      status: serializer.fromJson<String>(json['status']),
      message: serializer.fromJson<String?>(json['message']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<int>(syncId),
      'changeId': serializer.toJson<int?>(changeId),
      'entity': serializer.toJson<String>(entity),
      'objectId': serializer.toJson<int>(objectId),
      'status': serializer.toJson<String>(status),
      'message': serializer.toJson<String?>(message),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  SyncLogEntry copyWith({
    int? syncId,
    Value<int?> changeId = const Value.absent(),
    String? entity,
    int? objectId,
    String? status,
    Value<String?> message = const Value.absent(),
    DateTime? syncedAt,
  }) => SyncLogEntry(
    syncId: syncId ?? this.syncId,
    changeId: changeId.present ? changeId.value : this.changeId,
    entity: entity ?? this.entity,
    objectId: objectId ?? this.objectId,
    status: status ?? this.status,
    message: message.present ? message.value : this.message,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  SyncLogEntry copyWithCompanion(SyncLogEntriesCompanion data) {
    return SyncLogEntry(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      changeId: data.changeId.present ? data.changeId.value : this.changeId,
      entity: data.entity.present ? data.entity.value : this.entity,
      objectId: data.objectId.present ? data.objectId.value : this.objectId,
      status: data.status.present ? data.status.value : this.status,
      message: data.message.present ? data.message.value : this.message,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogEntry(')
          ..write('syncId: $syncId, ')
          ..write('changeId: $changeId, ')
          ..write('entity: $entity, ')
          ..write('objectId: $objectId, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    changeId,
    entity,
    objectId,
    status,
    message,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncLogEntry &&
          other.syncId == this.syncId &&
          other.changeId == this.changeId &&
          other.entity == this.entity &&
          other.objectId == this.objectId &&
          other.status == this.status &&
          other.message == this.message &&
          other.syncedAt == this.syncedAt);
}

class SyncLogEntriesCompanion extends UpdateCompanion<SyncLogEntry> {
  final Value<int> syncId;
  final Value<int?> changeId;
  final Value<String> entity;
  final Value<int> objectId;
  final Value<String> status;
  final Value<String?> message;
  final Value<DateTime> syncedAt;
  const SyncLogEntriesCompanion({
    this.syncId = const Value.absent(),
    this.changeId = const Value.absent(),
    this.entity = const Value.absent(),
    this.objectId = const Value.absent(),
    this.status = const Value.absent(),
    this.message = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  SyncLogEntriesCompanion.insert({
    this.syncId = const Value.absent(),
    this.changeId = const Value.absent(),
    required String entity,
    required int objectId,
    required String status,
    this.message = const Value.absent(),
    this.syncedAt = const Value.absent(),
  }) : entity = Value(entity),
       objectId = Value(objectId),
       status = Value(status);
  static Insertable<SyncLogEntry> custom({
    Expression<int>? syncId,
    Expression<int>? changeId,
    Expression<String>? entity,
    Expression<int>? objectId,
    Expression<String>? status,
    Expression<String>? message,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (changeId != null) 'change_id': changeId,
      if (entity != null) 'entity': entity,
      if (objectId != null) 'object_id': objectId,
      if (status != null) 'status': status,
      if (message != null) 'message': message,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  SyncLogEntriesCompanion copyWith({
    Value<int>? syncId,
    Value<int?>? changeId,
    Value<String>? entity,
    Value<int>? objectId,
    Value<String>? status,
    Value<String?>? message,
    Value<DateTime>? syncedAt,
  }) {
    return SyncLogEntriesCompanion(
      syncId: syncId ?? this.syncId,
      changeId: changeId ?? this.changeId,
      entity: entity ?? this.entity,
      objectId: objectId ?? this.objectId,
      status: status ?? this.status,
      message: message ?? this.message,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<int>(syncId.value);
    }
    if (changeId.present) {
      map['change_id'] = Variable<int>(changeId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (objectId.present) {
      map['object_id'] = Variable<int>(objectId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncLogEntriesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('changeId: $changeId, ')
          ..write('entity: $entity, ')
          ..write('objectId: $objectId, ')
          ..write('status: $status, ')
          ..write('message: $message, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CacheEntriesTable cacheEntries = $CacheEntriesTable(this);
  late final $ChangeQueueEntriesTable changeQueueEntries =
      $ChangeQueueEntriesTable(this);
  late final $SyncLogEntriesTable syncLogEntries = $SyncLogEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cacheEntries,
    changeQueueEntries,
    syncLogEntries,
  ];
}

typedef $$CacheEntriesTableCreateCompanionBuilder =
    CacheEntriesCompanion Function({
      required String cacheKey,
      required String scope,
      required String entityType,
      required String jsonData,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });
typedef $$CacheEntriesTableUpdateCompanionBuilder =
    CacheEntriesCompanion Function({
      Value<String> cacheKey,
      Value<String> scope,
      Value<String> entityType,
      Value<String> jsonData,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonData => $composableBuilder(
    column: $table.jsonData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheEntriesTable> {
  $$CacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsonData =>
      $composableBuilder(column: $table.jsonData, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheEntriesTable,
          CacheEntry,
          $$CacheEntriesTableFilterComposer,
          $$CacheEntriesTableOrderingComposer,
          $$CacheEntriesTableAnnotationComposer,
          $$CacheEntriesTableCreateCompanionBuilder,
          $$CacheEntriesTableUpdateCompanionBuilder,
          (
            CacheEntry,
            BaseReferences<_$AppDatabase, $CacheEntriesTable, CacheEntry>,
          ),
          CacheEntry,
          PrefetchHooks Function()
        > {
  $$CacheEntriesTableTableManager(_$AppDatabase db, $CacheEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> jsonData = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion(
                cacheKey: cacheKey,
                scope: scope,
                entityType: entityType,
                jsonData: jsonData,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String scope,
                required String entityType,
                required String jsonData,
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheEntriesCompanion.insert(
                cacheKey: cacheKey,
                scope: scope,
                entityType: entityType,
                jsonData: jsonData,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheEntriesTable,
      CacheEntry,
      $$CacheEntriesTableFilterComposer,
      $$CacheEntriesTableOrderingComposer,
      $$CacheEntriesTableAnnotationComposer,
      $$CacheEntriesTableCreateCompanionBuilder,
      $$CacheEntriesTableUpdateCompanionBuilder,
      (
        CacheEntry,
        BaseReferences<_$AppDatabase, $CacheEntriesTable, CacheEntry>,
      ),
      CacheEntry,
      PrefetchHooks Function()
    >;
typedef $$ChangeQueueEntriesTableCreateCompanionBuilder =
    ChangeQueueEntriesCompanion Function({
      Value<int> changeId,
      required String entity,
      required int objectId,
      required String field,
      required String value,
      Value<DateTime> clientTs,
      Value<String> status,
      Value<int> attemptCount,
    });
typedef $$ChangeQueueEntriesTableUpdateCompanionBuilder =
    ChangeQueueEntriesCompanion Function({
      Value<int> changeId,
      Value<String> entity,
      Value<int> objectId,
      Value<String> field,
      Value<String> value,
      Value<DateTime> clientTs,
      Value<String> status,
      Value<int> attemptCount,
    });

class $$ChangeQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ChangeQueueEntriesTable> {
  $$ChangeQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChangeQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChangeQueueEntriesTable> {
  $$ChangeQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChangeQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChangeQueueEntriesTable> {
  $$ChangeQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get changeId =>
      $composableBuilder(column: $table.changeId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<int> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get clientTs =>
      $composableBuilder(column: $table.clientTs, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );
}

class $$ChangeQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChangeQueueEntriesTable,
          ChangeQueueEntry,
          $$ChangeQueueEntriesTableFilterComposer,
          $$ChangeQueueEntriesTableOrderingComposer,
          $$ChangeQueueEntriesTableAnnotationComposer,
          $$ChangeQueueEntriesTableCreateCompanionBuilder,
          $$ChangeQueueEntriesTableUpdateCompanionBuilder,
          (
            ChangeQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $ChangeQueueEntriesTable,
              ChangeQueueEntry
            >,
          ),
          ChangeQueueEntry,
          PrefetchHooks Function()
        > {
  $$ChangeQueueEntriesTableTableManager(
    _$AppDatabase db,
    $ChangeQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangeQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChangeQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChangeQueueEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> changeId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<int> objectId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> clientTs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
              }) => ChangeQueueEntriesCompanion(
                changeId: changeId,
                entity: entity,
                objectId: objectId,
                field: field,
                value: value,
                clientTs: clientTs,
                status: status,
                attemptCount: attemptCount,
              ),
          createCompanionCallback:
              ({
                Value<int> changeId = const Value.absent(),
                required String entity,
                required int objectId,
                required String field,
                required String value,
                Value<DateTime> clientTs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
              }) => ChangeQueueEntriesCompanion.insert(
                changeId: changeId,
                entity: entity,
                objectId: objectId,
                field: field,
                value: value,
                clientTs: clientTs,
                status: status,
                attemptCount: attemptCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChangeQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChangeQueueEntriesTable,
      ChangeQueueEntry,
      $$ChangeQueueEntriesTableFilterComposer,
      $$ChangeQueueEntriesTableOrderingComposer,
      $$ChangeQueueEntriesTableAnnotationComposer,
      $$ChangeQueueEntriesTableCreateCompanionBuilder,
      $$ChangeQueueEntriesTableUpdateCompanionBuilder,
      (
        ChangeQueueEntry,
        BaseReferences<
          _$AppDatabase,
          $ChangeQueueEntriesTable,
          ChangeQueueEntry
        >,
      ),
      ChangeQueueEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncLogEntriesTableCreateCompanionBuilder =
    SyncLogEntriesCompanion Function({
      Value<int> syncId,
      Value<int?> changeId,
      required String entity,
      required int objectId,
      required String status,
      Value<String?> message,
      Value<DateTime> syncedAt,
    });
typedef $$SyncLogEntriesTableUpdateCompanionBuilder =
    SyncLogEntriesCompanion Function({
      Value<int> syncId,
      Value<int?> changeId,
      Value<String> entity,
      Value<int> objectId,
      Value<String> status,
      Value<String?> message,
      Value<DateTime> syncedAt,
    });

class $$SyncLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncLogEntriesTable> {
  $$SyncLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncLogEntriesTable> {
  $$SyncLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get objectId => $composableBuilder(
    column: $table.objectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncLogEntriesTable> {
  $$SyncLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<int> get changeId =>
      $composableBuilder(column: $table.changeId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<int> get objectId =>
      $composableBuilder(column: $table.objectId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$SyncLogEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncLogEntriesTable,
          SyncLogEntry,
          $$SyncLogEntriesTableFilterComposer,
          $$SyncLogEntriesTableOrderingComposer,
          $$SyncLogEntriesTableAnnotationComposer,
          $$SyncLogEntriesTableCreateCompanionBuilder,
          $$SyncLogEntriesTableUpdateCompanionBuilder,
          (
            SyncLogEntry,
            BaseReferences<_$AppDatabase, $SyncLogEntriesTable, SyncLogEntry>,
          ),
          SyncLogEntry,
          PrefetchHooks Function()
        > {
  $$SyncLogEntriesTableTableManager(
    _$AppDatabase db,
    $SyncLogEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> syncId = const Value.absent(),
                Value<int?> changeId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<int> objectId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
              }) => SyncLogEntriesCompanion(
                syncId: syncId,
                changeId: changeId,
                entity: entity,
                objectId: objectId,
                status: status,
                message: message,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> syncId = const Value.absent(),
                Value<int?> changeId = const Value.absent(),
                required String entity,
                required int objectId,
                required String status,
                Value<String?> message = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
              }) => SyncLogEntriesCompanion.insert(
                syncId: syncId,
                changeId: changeId,
                entity: entity,
                objectId: objectId,
                status: status,
                message: message,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncLogEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncLogEntriesTable,
      SyncLogEntry,
      $$SyncLogEntriesTableFilterComposer,
      $$SyncLogEntriesTableOrderingComposer,
      $$SyncLogEntriesTableAnnotationComposer,
      $$SyncLogEntriesTableCreateCompanionBuilder,
      $$SyncLogEntriesTableUpdateCompanionBuilder,
      (
        SyncLogEntry,
        BaseReferences<_$AppDatabase, $SyncLogEntriesTable, SyncLogEntry>,
      ),
      SyncLogEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CacheEntriesTableTableManager get cacheEntries =>
      $$CacheEntriesTableTableManager(_db, _db.cacheEntries);
  $$ChangeQueueEntriesTableTableManager get changeQueueEntries =>
      $$ChangeQueueEntriesTableTableManager(_db, _db.changeQueueEntries);
  $$SyncLogEntriesTableTableManager get syncLogEntries =>
      $$SyncLogEntriesTableTableManager(_db, _db.syncLogEntries);
}
