// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_database.dart';

// ignore_for_file: type=lint
class $CoursesTable extends Courses with TableInfo<$CoursesTable, Course> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goodPointsMeta = const VerificationMeta(
    'goodPoints',
  );
  @override
  late final GeneratedColumn<int> goodPoints = GeneratedColumn<int>(
    'good_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _veryGoodPointsMeta = const VerificationMeta(
    'veryGoodPoints',
  );
  @override
  late final GeneratedColumn<int> veryGoodPoints = GeneratedColumn<int>(
    'very_good_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _excellentPointsMeta = const VerificationMeta(
    'excellentPoints',
  );
  @override
  late final GeneratedColumn<int> excellentPoints = GeneratedColumn<int>(
    'excellent_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _certificatePointsMeta = const VerificationMeta(
    'certificatePoints',
  );
  @override
  late final GeneratedColumn<int> certificatePoints = GeneratedColumn<int>(
    'certificate_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    startDate,
    endDate,
    goodPoints,
    veryGoodPoints,
    excellentPoints,
    certificatePoints,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Course> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('good_points')) {
      context.handle(
        _goodPointsMeta,
        goodPoints.isAcceptableOrUnknown(data['good_points']!, _goodPointsMeta),
      );
    }
    if (data.containsKey('very_good_points')) {
      context.handle(
        _veryGoodPointsMeta,
        veryGoodPoints.isAcceptableOrUnknown(
          data['very_good_points']!,
          _veryGoodPointsMeta,
        ),
      );
    }
    if (data.containsKey('excellent_points')) {
      context.handle(
        _excellentPointsMeta,
        excellentPoints.isAcceptableOrUnknown(
          data['excellent_points']!,
          _excellentPointsMeta,
        ),
      );
    }
    if (data.containsKey('certificate_points')) {
      context.handle(
        _certificatePointsMeta,
        certificatePoints.isAcceptableOrUnknown(
          data['certificate_points']!,
          _certificatePointsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Course map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Course(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      )!,
      goodPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}good_points'],
      )!,
      veryGoodPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}very_good_points'],
      )!,
      excellentPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}excellent_points'],
      )!,
      certificatePoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}certificate_points'],
      )!,
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class Course extends DataClass implements Insertable<Course> {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final int goodPoints;
  final int veryGoodPoints;
  final int excellentPoints;
  final int certificatePoints;
  const Course({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.goodPoints,
    required this.veryGoodPoints,
    required this.excellentPoints,
    required this.certificatePoints,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['good_points'] = Variable<int>(goodPoints);
    map['very_good_points'] = Variable<int>(veryGoodPoints);
    map['excellent_points'] = Variable<int>(excellentPoints);
    map['certificate_points'] = Variable<int>(certificatePoints);
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      name: Value(name),
      startDate: Value(startDate),
      endDate: Value(endDate),
      goodPoints: Value(goodPoints),
      veryGoodPoints: Value(veryGoodPoints),
      excellentPoints: Value(excellentPoints),
      certificatePoints: Value(certificatePoints),
    );
  }

  factory Course.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Course(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      goodPoints: serializer.fromJson<int>(json['goodPoints']),
      veryGoodPoints: serializer.fromJson<int>(json['veryGoodPoints']),
      excellentPoints: serializer.fromJson<int>(json['excellentPoints']),
      certificatePoints: serializer.fromJson<int>(json['certificatePoints']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'goodPoints': serializer.toJson<int>(goodPoints),
      'veryGoodPoints': serializer.toJson<int>(veryGoodPoints),
      'excellentPoints': serializer.toJson<int>(excellentPoints),
      'certificatePoints': serializer.toJson<int>(certificatePoints),
    };
  }

  Course copyWith({
    int? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    int? goodPoints,
    int? veryGoodPoints,
    int? excellentPoints,
    int? certificatePoints,
  }) => Course(
    id: id ?? this.id,
    name: name ?? this.name,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    goodPoints: goodPoints ?? this.goodPoints,
    veryGoodPoints: veryGoodPoints ?? this.veryGoodPoints,
    excellentPoints: excellentPoints ?? this.excellentPoints,
    certificatePoints: certificatePoints ?? this.certificatePoints,
  );
  Course copyWithCompanion(CoursesCompanion data) {
    return Course(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      goodPoints: data.goodPoints.present
          ? data.goodPoints.value
          : this.goodPoints,
      veryGoodPoints: data.veryGoodPoints.present
          ? data.veryGoodPoints.value
          : this.veryGoodPoints,
      excellentPoints: data.excellentPoints.present
          ? data.excellentPoints.value
          : this.excellentPoints,
      certificatePoints: data.certificatePoints.present
          ? data.certificatePoints.value
          : this.certificatePoints,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Course(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('goodPoints: $goodPoints, ')
          ..write('veryGoodPoints: $veryGoodPoints, ')
          ..write('excellentPoints: $excellentPoints, ')
          ..write('certificatePoints: $certificatePoints')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    startDate,
    endDate,
    goodPoints,
    veryGoodPoints,
    excellentPoints,
    certificatePoints,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Course &&
          other.id == this.id &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.goodPoints == this.goodPoints &&
          other.veryGoodPoints == this.veryGoodPoints &&
          other.excellentPoints == this.excellentPoints &&
          other.certificatePoints == this.certificatePoints);
}

class CoursesCompanion extends UpdateCompanion<Course> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<int> goodPoints;
  final Value<int> veryGoodPoints;
  final Value<int> excellentPoints;
  final Value<int> certificatePoints;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.goodPoints = const Value.absent(),
    this.veryGoodPoints = const Value.absent(),
    this.excellentPoints = const Value.absent(),
    this.certificatePoints = const Value.absent(),
  });
  CoursesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    this.goodPoints = const Value.absent(),
    this.veryGoodPoints = const Value.absent(),
    this.excellentPoints = const Value.absent(),
    this.certificatePoints = const Value.absent(),
  }) : name = Value(name),
       startDate = Value(startDate),
       endDate = Value(endDate);
  static Insertable<Course> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<int>? goodPoints,
    Expression<int>? veryGoodPoints,
    Expression<int>? excellentPoints,
    Expression<int>? certificatePoints,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (goodPoints != null) 'good_points': goodPoints,
      if (veryGoodPoints != null) 'very_good_points': veryGoodPoints,
      if (excellentPoints != null) 'excellent_points': excellentPoints,
      if (certificatePoints != null) 'certificate_points': certificatePoints,
    });
  }

  CoursesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? startDate,
    Value<DateTime>? endDate,
    Value<int>? goodPoints,
    Value<int>? veryGoodPoints,
    Value<int>? excellentPoints,
    Value<int>? certificatePoints,
  }) {
    return CoursesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      goodPoints: goodPoints ?? this.goodPoints,
      veryGoodPoints: veryGoodPoints ?? this.veryGoodPoints,
      excellentPoints: excellentPoints ?? this.excellentPoints,
      certificatePoints: certificatePoints ?? this.certificatePoints,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (goodPoints.present) {
      map['good_points'] = Variable<int>(goodPoints.value);
    }
    if (veryGoodPoints.present) {
      map['very_good_points'] = Variable<int>(veryGoodPoints.value);
    }
    if (excellentPoints.present) {
      map['excellent_points'] = Variable<int>(excellentPoints.value);
    }
    if (certificatePoints.present) {
      map['certificate_points'] = Variable<int>(certificatePoints.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('goodPoints: $goodPoints, ')
          ..write('veryGoodPoints: $veryGoodPoints, ')
          ..write('excellentPoints: $excellentPoints, ')
          ..write('certificatePoints: $certificatePoints')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<int> courseId = GeneratedColumn<int>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earlyPointsMeta = const VerificationMeta(
    'earlyPoints',
  );
  @override
  late final GeneratedColumn<int> earlyPoints = GeneratedColumn<int>(
    'early_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _midPointsMeta = const VerificationMeta(
    'midPoints',
  );
  @override
  late final GeneratedColumn<int> midPoints = GeneratedColumn<int>(
    'mid_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _latePointsMeta = const VerificationMeta(
    'latePoints',
  );
  @override
  late final GeneratedColumn<int> latePoints = GeneratedColumn<int>(
    'late_points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _earlyUntilMeta = const VerificationMeta(
    'earlyUntil',
  );
  @override
  late final GeneratedColumn<String> earlyUntil = GeneratedColumn<String>(
    'early_until',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('16:00'),
  );
  static const VerificationMeta _lateFromMeta = const VerificationMeta(
    'lateFrom',
  );
  @override
  late final GeneratedColumn<String> lateFrom = GeneratedColumn<String>(
    'late_from',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('16:30'),
  );
  static const VerificationMeta _orderInCourseMeta = const VerificationMeta(
    'orderInCourse',
  );
  @override
  late final GeneratedColumn<int> orderInCourse = GeneratedColumn<int>(
    'order_in_course',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseId,
    date,
    earlyPoints,
    midPoints,
    latePoints,
    earlyUntil,
    lateFrom,
    orderInCourse,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('early_points')) {
      context.handle(
        _earlyPointsMeta,
        earlyPoints.isAcceptableOrUnknown(
          data['early_points']!,
          _earlyPointsMeta,
        ),
      );
    }
    if (data.containsKey('mid_points')) {
      context.handle(
        _midPointsMeta,
        midPoints.isAcceptableOrUnknown(data['mid_points']!, _midPointsMeta),
      );
    }
    if (data.containsKey('late_points')) {
      context.handle(
        _latePointsMeta,
        latePoints.isAcceptableOrUnknown(data['late_points']!, _latePointsMeta),
      );
    }
    if (data.containsKey('early_until')) {
      context.handle(
        _earlyUntilMeta,
        earlyUntil.isAcceptableOrUnknown(data['early_until']!, _earlyUntilMeta),
      );
    }
    if (data.containsKey('late_from')) {
      context.handle(
        _lateFromMeta,
        lateFrom.isAcceptableOrUnknown(data['late_from']!, _lateFromMeta),
      );
    }
    if (data.containsKey('order_in_course')) {
      context.handle(
        _orderInCourseMeta,
        orderInCourse.isAcceptableOrUnknown(
          data['order_in_course']!,
          _orderInCourseMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}course_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      earlyPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}early_points'],
      )!,
      midPoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mid_points'],
      )!,
      latePoints: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}late_points'],
      )!,
      earlyUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}early_until'],
      )!,
      lateFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}late_from'],
      )!,
      orderInCourse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_in_course'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final int courseId;
  final DateTime date;
  final int earlyPoints;
  final int midPoints;
  final int latePoints;
  final String earlyUntil;
  final String lateFrom;
  final int orderInCourse;
  const Session({
    required this.id,
    required this.courseId,
    required this.date,
    required this.earlyPoints,
    required this.midPoints,
    required this.latePoints,
    required this.earlyUntil,
    required this.lateFrom,
    required this.orderInCourse,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['course_id'] = Variable<int>(courseId);
    map['date'] = Variable<DateTime>(date);
    map['early_points'] = Variable<int>(earlyPoints);
    map['mid_points'] = Variable<int>(midPoints);
    map['late_points'] = Variable<int>(latePoints);
    map['early_until'] = Variable<String>(earlyUntil);
    map['late_from'] = Variable<String>(lateFrom);
    map['order_in_course'] = Variable<int>(orderInCourse);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      courseId: Value(courseId),
      date: Value(date),
      earlyPoints: Value(earlyPoints),
      midPoints: Value(midPoints),
      latePoints: Value(latePoints),
      earlyUntil: Value(earlyUntil),
      lateFrom: Value(lateFrom),
      orderInCourse: Value(orderInCourse),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      courseId: serializer.fromJson<int>(json['courseId']),
      date: serializer.fromJson<DateTime>(json['date']),
      earlyPoints: serializer.fromJson<int>(json['earlyPoints']),
      midPoints: serializer.fromJson<int>(json['midPoints']),
      latePoints: serializer.fromJson<int>(json['latePoints']),
      earlyUntil: serializer.fromJson<String>(json['earlyUntil']),
      lateFrom: serializer.fromJson<String>(json['lateFrom']),
      orderInCourse: serializer.fromJson<int>(json['orderInCourse']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'courseId': serializer.toJson<int>(courseId),
      'date': serializer.toJson<DateTime>(date),
      'earlyPoints': serializer.toJson<int>(earlyPoints),
      'midPoints': serializer.toJson<int>(midPoints),
      'latePoints': serializer.toJson<int>(latePoints),
      'earlyUntil': serializer.toJson<String>(earlyUntil),
      'lateFrom': serializer.toJson<String>(lateFrom),
      'orderInCourse': serializer.toJson<int>(orderInCourse),
    };
  }

  Session copyWith({
    int? id,
    int? courseId,
    DateTime? date,
    int? earlyPoints,
    int? midPoints,
    int? latePoints,
    String? earlyUntil,
    String? lateFrom,
    int? orderInCourse,
  }) => Session(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    date: date ?? this.date,
    earlyPoints: earlyPoints ?? this.earlyPoints,
    midPoints: midPoints ?? this.midPoints,
    latePoints: latePoints ?? this.latePoints,
    earlyUntil: earlyUntil ?? this.earlyUntil,
    lateFrom: lateFrom ?? this.lateFrom,
    orderInCourse: orderInCourse ?? this.orderInCourse,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      date: data.date.present ? data.date.value : this.date,
      earlyPoints: data.earlyPoints.present
          ? data.earlyPoints.value
          : this.earlyPoints,
      midPoints: data.midPoints.present ? data.midPoints.value : this.midPoints,
      latePoints: data.latePoints.present
          ? data.latePoints.value
          : this.latePoints,
      earlyUntil: data.earlyUntil.present
          ? data.earlyUntil.value
          : this.earlyUntil,
      lateFrom: data.lateFrom.present ? data.lateFrom.value : this.lateFrom,
      orderInCourse: data.orderInCourse.present
          ? data.orderInCourse.value
          : this.orderInCourse,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('date: $date, ')
          ..write('earlyPoints: $earlyPoints, ')
          ..write('midPoints: $midPoints, ')
          ..write('latePoints: $latePoints, ')
          ..write('earlyUntil: $earlyUntil, ')
          ..write('lateFrom: $lateFrom, ')
          ..write('orderInCourse: $orderInCourse')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    courseId,
    date,
    earlyPoints,
    midPoints,
    latePoints,
    earlyUntil,
    lateFrom,
    orderInCourse,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.date == this.date &&
          other.earlyPoints == this.earlyPoints &&
          other.midPoints == this.midPoints &&
          other.latePoints == this.latePoints &&
          other.earlyUntil == this.earlyUntil &&
          other.lateFrom == this.lateFrom &&
          other.orderInCourse == this.orderInCourse);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> courseId;
  final Value<DateTime> date;
  final Value<int> earlyPoints;
  final Value<int> midPoints;
  final Value<int> latePoints;
  final Value<String> earlyUntil;
  final Value<String> lateFrom;
  final Value<int> orderInCourse;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.date = const Value.absent(),
    this.earlyPoints = const Value.absent(),
    this.midPoints = const Value.absent(),
    this.latePoints = const Value.absent(),
    this.earlyUntil = const Value.absent(),
    this.lateFrom = const Value.absent(),
    this.orderInCourse = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int courseId,
    required DateTime date,
    this.earlyPoints = const Value.absent(),
    this.midPoints = const Value.absent(),
    this.latePoints = const Value.absent(),
    this.earlyUntil = const Value.absent(),
    this.lateFrom = const Value.absent(),
    this.orderInCourse = const Value.absent(),
  }) : courseId = Value(courseId),
       date = Value(date);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? courseId,
    Expression<DateTime>? date,
    Expression<int>? earlyPoints,
    Expression<int>? midPoints,
    Expression<int>? latePoints,
    Expression<String>? earlyUntil,
    Expression<String>? lateFrom,
    Expression<int>? orderInCourse,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (date != null) 'date': date,
      if (earlyPoints != null) 'early_points': earlyPoints,
      if (midPoints != null) 'mid_points': midPoints,
      if (latePoints != null) 'late_points': latePoints,
      if (earlyUntil != null) 'early_until': earlyUntil,
      if (lateFrom != null) 'late_from': lateFrom,
      if (orderInCourse != null) 'order_in_course': orderInCourse,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? courseId,
    Value<DateTime>? date,
    Value<int>? earlyPoints,
    Value<int>? midPoints,
    Value<int>? latePoints,
    Value<String>? earlyUntil,
    Value<String>? lateFrom,
    Value<int>? orderInCourse,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      date: date ?? this.date,
      earlyPoints: earlyPoints ?? this.earlyPoints,
      midPoints: midPoints ?? this.midPoints,
      latePoints: latePoints ?? this.latePoints,
      earlyUntil: earlyUntil ?? this.earlyUntil,
      lateFrom: lateFrom ?? this.lateFrom,
      orderInCourse: orderInCourse ?? this.orderInCourse,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<int>(courseId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (earlyPoints.present) {
      map['early_points'] = Variable<int>(earlyPoints.value);
    }
    if (midPoints.present) {
      map['mid_points'] = Variable<int>(midPoints.value);
    }
    if (latePoints.present) {
      map['late_points'] = Variable<int>(latePoints.value);
    }
    if (earlyUntil.present) {
      map['early_until'] = Variable<String>(earlyUntil.value);
    }
    if (lateFrom.present) {
      map['late_from'] = Variable<String>(lateFrom.value);
    }
    if (orderInCourse.present) {
      map['order_in_course'] = Variable<int>(orderInCourse.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('date: $date, ')
          ..write('earlyPoints: $earlyPoints, ')
          ..write('midPoints: $midPoints, ')
          ..write('latePoints: $latePoints, ')
          ..write('earlyUntil: $earlyUntil, ')
          ..write('lateFrom: $lateFrom, ')
          ..write('orderInCourse: $orderInCourse')
          ..write(')'))
        .toString();
  }
}

class $AttendancesTable extends Attendances
    with TableInfo<$AttendancesTable, Attendance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arrivalTimeMeta = const VerificationMeta(
    'arrivalTime',
  );
  @override
  late final GeneratedColumn<DateTime> arrivalTime = GeneratedColumn<DateTime>(
    'arrival_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, studentId, sessionId, arrivalTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendances';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attendance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('arrival_time')) {
      context.handle(
        _arrivalTimeMeta,
        arrivalTime.isAcceptableOrUnknown(
          data['arrival_time']!,
          _arrivalTimeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attendance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attendance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      arrivalTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrival_time'],
      ),
    );
  }

  @override
  $AttendancesTable createAlias(String alias) {
    return $AttendancesTable(attachedDatabase, alias);
  }
}

class Attendance extends DataClass implements Insertable<Attendance> {
  final int id;
  final int studentId;
  final int sessionId;
  final DateTime? arrivalTime;
  const Attendance({
    required this.id,
    required this.studentId,
    required this.sessionId,
    this.arrivalTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['session_id'] = Variable<int>(sessionId);
    if (!nullToAbsent || arrivalTime != null) {
      map['arrival_time'] = Variable<DateTime>(arrivalTime);
    }
    return map;
  }

  AttendancesCompanion toCompanion(bool nullToAbsent) {
    return AttendancesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      sessionId: Value(sessionId),
      arrivalTime: arrivalTime == null && nullToAbsent
          ? const Value.absent()
          : Value(arrivalTime),
    );
  }

  factory Attendance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attendance(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      arrivalTime: serializer.fromJson<DateTime?>(json['arrivalTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'sessionId': serializer.toJson<int>(sessionId),
      'arrivalTime': serializer.toJson<DateTime?>(arrivalTime),
    };
  }

  Attendance copyWith({
    int? id,
    int? studentId,
    int? sessionId,
    Value<DateTime?> arrivalTime = const Value.absent(),
  }) => Attendance(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    sessionId: sessionId ?? this.sessionId,
    arrivalTime: arrivalTime.present ? arrivalTime.value : this.arrivalTime,
  );
  Attendance copyWithCompanion(AttendancesCompanion data) {
    return Attendance(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      arrivalTime: data.arrivalTime.present
          ? data.arrivalTime.value
          : this.arrivalTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attendance(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('arrivalTime: $arrivalTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, sessionId, arrivalTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attendance &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.sessionId == this.sessionId &&
          other.arrivalTime == this.arrivalTime);
}

class AttendancesCompanion extends UpdateCompanion<Attendance> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> sessionId;
  final Value<DateTime?> arrivalTime;
  const AttendancesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.arrivalTime = const Value.absent(),
  });
  AttendancesCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int sessionId,
    this.arrivalTime = const Value.absent(),
  }) : studentId = Value(studentId),
       sessionId = Value(sessionId);
  static Insertable<Attendance> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? sessionId,
    Expression<DateTime>? arrivalTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (sessionId != null) 'session_id': sessionId,
      if (arrivalTime != null) 'arrival_time': arrivalTime,
    });
  }

  AttendancesCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? sessionId,
    Value<DateTime?>? arrivalTime,
  }) {
    return AttendancesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sessionId: sessionId ?? this.sessionId,
      arrivalTime: arrivalTime ?? this.arrivalTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (arrivalTime.present) {
      map['arrival_time'] = Variable<DateTime>(arrivalTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendancesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('arrivalTime: $arrivalTime')
          ..write(')'))
        .toString();
  }
}

class $MemorizationsTable extends Memorizations
    with TableInfo<$MemorizationsTable, Memorization> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemorizationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partIndexMeta = const VerificationMeta(
    'partIndex',
  );
  @override
  late final GeneratedColumn<int> partIndex = GeneratedColumn<int>(
    'part_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _partsMeta = const VerificationMeta('parts');
  @override
  late final GeneratedColumn<int> parts = GeneratedColumn<int>(
    'parts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _surahMeta = const VerificationMeta('surah');
  @override
  late final GeneratedColumn<String> surah = GeneratedColumn<String>(
    'surah',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reciterNameMeta = const VerificationMeta(
    'reciterName',
  );
  @override
  late final GeneratedColumn<String> reciterName = GeneratedColumn<String>(
    'reciter_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    sessionId,
    page,
    partIndex,
    parts,
    surah,
    rating,
    reciterName,
    date,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memorizations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Memorization> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('part_index')) {
      context.handle(
        _partIndexMeta,
        partIndex.isAcceptableOrUnknown(data['part_index']!, _partIndexMeta),
      );
    }
    if (data.containsKey('parts')) {
      context.handle(
        _partsMeta,
        parts.isAcceptableOrUnknown(data['parts']!, _partsMeta),
      );
    }
    if (data.containsKey('surah')) {
      context.handle(
        _surahMeta,
        surah.isAcceptableOrUnknown(data['surah']!, _surahMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('reciter_name')) {
      context.handle(
        _reciterNameMeta,
        reciterName.isAcceptableOrUnknown(
          data['reciter_name']!,
          _reciterNameMeta,
        ),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Memorization map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Memorization(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      partIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}part_index'],
      )!,
      parts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parts'],
      )!,
      surah: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}surah'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      reciterName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reciter_name'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $MemorizationsTable createAlias(String alias) {
    return $MemorizationsTable(attachedDatabase, alias);
  }
}

class Memorization extends DataClass implements Insertable<Memorization> {
  final int id;
  final int studentId;
  final int sessionId;
  final int page;
  final int partIndex;
  final int parts;
  final String surah;
  final int rating;
  final String reciterName;
  final DateTime date;
  const Memorization({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.page,
    required this.partIndex,
    required this.parts,
    required this.surah,
    required this.rating,
    required this.reciterName,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['session_id'] = Variable<int>(sessionId);
    map['page'] = Variable<int>(page);
    map['part_index'] = Variable<int>(partIndex);
    map['parts'] = Variable<int>(parts);
    map['surah'] = Variable<String>(surah);
    map['rating'] = Variable<int>(rating);
    map['reciter_name'] = Variable<String>(reciterName);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  MemorizationsCompanion toCompanion(bool nullToAbsent) {
    return MemorizationsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      sessionId: Value(sessionId),
      page: Value(page),
      partIndex: Value(partIndex),
      parts: Value(parts),
      surah: Value(surah),
      rating: Value(rating),
      reciterName: Value(reciterName),
      date: Value(date),
    );
  }

  factory Memorization.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Memorization(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      page: serializer.fromJson<int>(json['page']),
      partIndex: serializer.fromJson<int>(json['partIndex']),
      parts: serializer.fromJson<int>(json['parts']),
      surah: serializer.fromJson<String>(json['surah']),
      rating: serializer.fromJson<int>(json['rating']),
      reciterName: serializer.fromJson<String>(json['reciterName']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'sessionId': serializer.toJson<int>(sessionId),
      'page': serializer.toJson<int>(page),
      'partIndex': serializer.toJson<int>(partIndex),
      'parts': serializer.toJson<int>(parts),
      'surah': serializer.toJson<String>(surah),
      'rating': serializer.toJson<int>(rating),
      'reciterName': serializer.toJson<String>(reciterName),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  Memorization copyWith({
    int? id,
    int? studentId,
    int? sessionId,
    int? page,
    int? partIndex,
    int? parts,
    String? surah,
    int? rating,
    String? reciterName,
    DateTime? date,
  }) => Memorization(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    sessionId: sessionId ?? this.sessionId,
    page: page ?? this.page,
    partIndex: partIndex ?? this.partIndex,
    parts: parts ?? this.parts,
    surah: surah ?? this.surah,
    rating: rating ?? this.rating,
    reciterName: reciterName ?? this.reciterName,
    date: date ?? this.date,
  );
  Memorization copyWithCompanion(MemorizationsCompanion data) {
    return Memorization(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      page: data.page.present ? data.page.value : this.page,
      partIndex: data.partIndex.present ? data.partIndex.value : this.partIndex,
      parts: data.parts.present ? data.parts.value : this.parts,
      surah: data.surah.present ? data.surah.value : this.surah,
      rating: data.rating.present ? data.rating.value : this.rating,
      reciterName: data.reciterName.present
          ? data.reciterName.value
          : this.reciterName,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Memorization(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('page: $page, ')
          ..write('partIndex: $partIndex, ')
          ..write('parts: $parts, ')
          ..write('surah: $surah, ')
          ..write('rating: $rating, ')
          ..write('reciterName: $reciterName, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    sessionId,
    page,
    partIndex,
    parts,
    surah,
    rating,
    reciterName,
    date,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Memorization &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.sessionId == this.sessionId &&
          other.page == this.page &&
          other.partIndex == this.partIndex &&
          other.parts == this.parts &&
          other.surah == this.surah &&
          other.rating == this.rating &&
          other.reciterName == this.reciterName &&
          other.date == this.date);
}

class MemorizationsCompanion extends UpdateCompanion<Memorization> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> sessionId;
  final Value<int> page;
  final Value<int> partIndex;
  final Value<int> parts;
  final Value<String> surah;
  final Value<int> rating;
  final Value<String> reciterName;
  final Value<DateTime> date;
  const MemorizationsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.page = const Value.absent(),
    this.partIndex = const Value.absent(),
    this.parts = const Value.absent(),
    this.surah = const Value.absent(),
    this.rating = const Value.absent(),
    this.reciterName = const Value.absent(),
    this.date = const Value.absent(),
  });
  MemorizationsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int sessionId,
    required int page,
    this.partIndex = const Value.absent(),
    this.parts = const Value.absent(),
    this.surah = const Value.absent(),
    required int rating,
    this.reciterName = const Value.absent(),
    required DateTime date,
  }) : studentId = Value(studentId),
       sessionId = Value(sessionId),
       page = Value(page),
       rating = Value(rating),
       date = Value(date);
  static Insertable<Memorization> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? sessionId,
    Expression<int>? page,
    Expression<int>? partIndex,
    Expression<int>? parts,
    Expression<String>? surah,
    Expression<int>? rating,
    Expression<String>? reciterName,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (sessionId != null) 'session_id': sessionId,
      if (page != null) 'page': page,
      if (partIndex != null) 'part_index': partIndex,
      if (parts != null) 'parts': parts,
      if (surah != null) 'surah': surah,
      if (rating != null) 'rating': rating,
      if (reciterName != null) 'reciter_name': reciterName,
      if (date != null) 'date': date,
    });
  }

  MemorizationsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? sessionId,
    Value<int>? page,
    Value<int>? partIndex,
    Value<int>? parts,
    Value<String>? surah,
    Value<int>? rating,
    Value<String>? reciterName,
    Value<DateTime>? date,
  }) {
    return MemorizationsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sessionId: sessionId ?? this.sessionId,
      page: page ?? this.page,
      partIndex: partIndex ?? this.partIndex,
      parts: parts ?? this.parts,
      surah: surah ?? this.surah,
      rating: rating ?? this.rating,
      reciterName: reciterName ?? this.reciterName,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (partIndex.present) {
      map['part_index'] = Variable<int>(partIndex.value);
    }
    if (parts.present) {
      map['parts'] = Variable<int>(parts.value);
    }
    if (surah.present) {
      map['surah'] = Variable<String>(surah.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (reciterName.present) {
      map['reciter_name'] = Variable<String>(reciterName.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemorizationsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('page: $page, ')
          ..write('partIndex: $partIndex, ')
          ..write('parts: $parts, ')
          ..write('surah: $surah, ')
          ..write('rating: $rating, ')
          ..write('reciterName: $reciterName, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsValueMeta = const VerificationMeta(
    'pointsValue',
  );
  @override
  late final GeneratedColumn<int> pointsValue = GeneratedColumn<int>(
    'points_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    sessionId,
    type,
    pointsValue,
    date,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('points_value')) {
      context.handle(
        _pointsValueMeta,
        pointsValue.isAcceptableOrUnknown(
          data['points_value']!,
          _pointsValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointsValueMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      pointsValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_value'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final int studentId;
  final int sessionId;
  final String type;
  final int pointsValue;
  final DateTime date;
  final String? description;
  const Transaction({
    required this.id,
    required this.studentId,
    required this.sessionId,
    required this.type,
    required this.pointsValue,
    required this.date,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['session_id'] = Variable<int>(sessionId);
    map['type'] = Variable<String>(type);
    map['points_value'] = Variable<int>(pointsValue);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      sessionId: Value(sessionId),
      type: Value(type),
      pointsValue: Value(pointsValue),
      date: Value(date),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      type: serializer.fromJson<String>(json['type']),
      pointsValue: serializer.fromJson<int>(json['pointsValue']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'sessionId': serializer.toJson<int>(sessionId),
      'type': serializer.toJson<String>(type),
      'pointsValue': serializer.toJson<int>(pointsValue),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String?>(description),
    };
  }

  Transaction copyWith({
    int? id,
    int? studentId,
    int? sessionId,
    String? type,
    int? pointsValue,
    DateTime? date,
    Value<String?> description = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    sessionId: sessionId ?? this.sessionId,
    type: type ?? this.type,
    pointsValue: pointsValue ?? this.pointsValue,
    date: date ?? this.date,
    description: description.present ? description.value : this.description,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      pointsValue: data.pointsValue.present
          ? data.pointsValue.value
          : this.pointsValue,
      date: data.date.present ? data.date.value : this.date,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('pointsValue: $pointsValue, ')
          ..write('date: $date, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    sessionId,
    type,
    pointsValue,
    date,
    description,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.pointsValue == this.pointsValue &&
          other.date == this.date &&
          other.description == this.description);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> sessionId;
  final Value<String> type;
  final Value<int> pointsValue;
  final Value<DateTime> date;
  final Value<String?> description;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.pointsValue = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int sessionId,
    required String type,
    required int pointsValue,
    required DateTime date,
    this.description = const Value.absent(),
  }) : studentId = Value(studentId),
       sessionId = Value(sessionId),
       type = Value(type),
       pointsValue = Value(pointsValue),
       date = Value(date);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? sessionId,
    Expression<String>? type,
    Expression<int>? pointsValue,
    Expression<DateTime>? date,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (pointsValue != null) 'points_value': pointsValue,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? sessionId,
    Value<String>? type,
    Value<int>? pointsValue,
    Value<DateTime>? date,
    Value<String?>? description,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      pointsValue: pointsValue ?? this.pointsValue,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (pointsValue.present) {
      map['points_value'] = Variable<int>(pointsValue.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('pointsValue: $pointsValue, ')
          ..write('date: $date, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $CertificatesTable extends Certificates
    with TableInfo<$CertificatesTable, Certificate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CertificatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<int> courseId = GeneratedColumn<int>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startJuzMeta = const VerificationMeta(
    'startJuz',
  );
  @override
  late final GeneratedColumn<int> startJuz = GeneratedColumn<int>(
    'start_juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endJuzMeta = const VerificationMeta('endJuz');
  @override
  late final GeneratedColumn<int> endJuz = GeneratedColumn<int>(
    'end_juz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markMeta = const VerificationMeta('mark');
  @override
  late final GeneratedColumn<int> mark = GeneratedColumn<int>(
    'mark',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byHeartMeta = const VerificationMeta(
    'byHeart',
  );
  @override
  late final GeneratedColumn<bool> byHeart = GeneratedColumn<bool>(
    'by_heart',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("by_heart" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    courseId,
    startJuz,
    endJuz,
    mark,
    byHeart,
    date,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'certificates';
  @override
  VerificationContext validateIntegrity(
    Insertable<Certificate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('start_juz')) {
      context.handle(
        _startJuzMeta,
        startJuz.isAcceptableOrUnknown(data['start_juz']!, _startJuzMeta),
      );
    } else if (isInserting) {
      context.missing(_startJuzMeta);
    }
    if (data.containsKey('end_juz')) {
      context.handle(
        _endJuzMeta,
        endJuz.isAcceptableOrUnknown(data['end_juz']!, _endJuzMeta),
      );
    } else if (isInserting) {
      context.missing(_endJuzMeta);
    }
    if (data.containsKey('mark')) {
      context.handle(
        _markMeta,
        mark.isAcceptableOrUnknown(data['mark']!, _markMeta),
      );
    } else if (isInserting) {
      context.missing(_markMeta);
    }
    if (data.containsKey('by_heart')) {
      context.handle(
        _byHeartMeta,
        byHeart.isAcceptableOrUnknown(data['by_heart']!, _byHeartMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Certificate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Certificate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}course_id'],
      )!,
      startJuz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_juz'],
      )!,
      endJuz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_juz'],
      )!,
      mark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mark'],
      )!,
      byHeart: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}by_heart'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $CertificatesTable createAlias(String alias) {
    return $CertificatesTable(attachedDatabase, alias);
  }
}

class Certificate extends DataClass implements Insertable<Certificate> {
  final int id;
  final int studentId;
  final int courseId;
  final int startJuz;
  final int endJuz;
  final int mark;
  final bool byHeart;
  final DateTime date;
  const Certificate({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.startJuz,
    required this.endJuz,
    required this.mark,
    required this.byHeart,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['course_id'] = Variable<int>(courseId);
    map['start_juz'] = Variable<int>(startJuz);
    map['end_juz'] = Variable<int>(endJuz);
    map['mark'] = Variable<int>(mark);
    map['by_heart'] = Variable<bool>(byHeart);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  CertificatesCompanion toCompanion(bool nullToAbsent) {
    return CertificatesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      courseId: Value(courseId),
      startJuz: Value(startJuz),
      endJuz: Value(endJuz),
      mark: Value(mark),
      byHeart: Value(byHeart),
      date: Value(date),
    );
  }

  factory Certificate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Certificate(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      courseId: serializer.fromJson<int>(json['courseId']),
      startJuz: serializer.fromJson<int>(json['startJuz']),
      endJuz: serializer.fromJson<int>(json['endJuz']),
      mark: serializer.fromJson<int>(json['mark']),
      byHeart: serializer.fromJson<bool>(json['byHeart']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'courseId': serializer.toJson<int>(courseId),
      'startJuz': serializer.toJson<int>(startJuz),
      'endJuz': serializer.toJson<int>(endJuz),
      'mark': serializer.toJson<int>(mark),
      'byHeart': serializer.toJson<bool>(byHeart),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  Certificate copyWith({
    int? id,
    int? studentId,
    int? courseId,
    int? startJuz,
    int? endJuz,
    int? mark,
    bool? byHeart,
    DateTime? date,
  }) => Certificate(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    courseId: courseId ?? this.courseId,
    startJuz: startJuz ?? this.startJuz,
    endJuz: endJuz ?? this.endJuz,
    mark: mark ?? this.mark,
    byHeart: byHeart ?? this.byHeart,
    date: date ?? this.date,
  );
  Certificate copyWithCompanion(CertificatesCompanion data) {
    return Certificate(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      startJuz: data.startJuz.present ? data.startJuz.value : this.startJuz,
      endJuz: data.endJuz.present ? data.endJuz.value : this.endJuz,
      mark: data.mark.present ? data.mark.value : this.mark,
      byHeart: data.byHeart.present ? data.byHeart.value : this.byHeart,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Certificate(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('courseId: $courseId, ')
          ..write('startJuz: $startJuz, ')
          ..write('endJuz: $endJuz, ')
          ..write('mark: $mark, ')
          ..write('byHeart: $byHeart, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    courseId,
    startJuz,
    endJuz,
    mark,
    byHeart,
    date,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Certificate &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.courseId == this.courseId &&
          other.startJuz == this.startJuz &&
          other.endJuz == this.endJuz &&
          other.mark == this.mark &&
          other.byHeart == this.byHeart &&
          other.date == this.date);
}

class CertificatesCompanion extends UpdateCompanion<Certificate> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> courseId;
  final Value<int> startJuz;
  final Value<int> endJuz;
  final Value<int> mark;
  final Value<bool> byHeart;
  final Value<DateTime> date;
  const CertificatesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.courseId = const Value.absent(),
    this.startJuz = const Value.absent(),
    this.endJuz = const Value.absent(),
    this.mark = const Value.absent(),
    this.byHeart = const Value.absent(),
    this.date = const Value.absent(),
  });
  CertificatesCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int courseId,
    required int startJuz,
    required int endJuz,
    required int mark,
    this.byHeart = const Value.absent(),
    required DateTime date,
  }) : studentId = Value(studentId),
       courseId = Value(courseId),
       startJuz = Value(startJuz),
       endJuz = Value(endJuz),
       mark = Value(mark),
       date = Value(date);
  static Insertable<Certificate> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? courseId,
    Expression<int>? startJuz,
    Expression<int>? endJuz,
    Expression<int>? mark,
    Expression<bool>? byHeart,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (courseId != null) 'course_id': courseId,
      if (startJuz != null) 'start_juz': startJuz,
      if (endJuz != null) 'end_juz': endJuz,
      if (mark != null) 'mark': mark,
      if (byHeart != null) 'by_heart': byHeart,
      if (date != null) 'date': date,
    });
  }

  CertificatesCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? courseId,
    Value<int>? startJuz,
    Value<int>? endJuz,
    Value<int>? mark,
    Value<bool>? byHeart,
    Value<DateTime>? date,
  }) {
    return CertificatesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      startJuz: startJuz ?? this.startJuz,
      endJuz: endJuz ?? this.endJuz,
      mark: mark ?? this.mark,
      byHeart: byHeart ?? this.byHeart,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<int>(courseId.value);
    }
    if (startJuz.present) {
      map['start_juz'] = Variable<int>(startJuz.value);
    }
    if (endJuz.present) {
      map['end_juz'] = Variable<int>(endJuz.value);
    }
    if (mark.present) {
      map['mark'] = Variable<int>(mark.value);
    }
    if (byHeart.present) {
      map['by_heart'] = Variable<bool>(byHeart.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CertificatesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('courseId: $courseId, ')
          ..write('startJuz: $startJuz, ')
          ..write('endJuz: $endJuz, ')
          ..write('mark: $mark, ')
          ..write('byHeart: $byHeart, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $ExamsTable extends Exams with TableInfo<$ExamsTable, Exam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<int> courseId = GeneratedColumn<int>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectNameMeta = const VerificationMeta(
    'subjectName',
  );
  @override
  late final GeneratedColumn<String> subjectName = GeneratedColumn<String>(
    'subject_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxMarkMeta = const VerificationMeta(
    'maxMark',
  );
  @override
  late final GeneratedColumn<int> maxMark = GeneratedColumn<int>(
    'max_mark',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minSuccessMarkMeta = const VerificationMeta(
    'minSuccessMark',
  );
  @override
  late final GeneratedColumn<int> minSuccessMark = GeneratedColumn<int>(
    'min_success_mark',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseId,
    subjectName,
    date,
    type,
    maxMark,
    minSuccessMark,
    points,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('subject_name')) {
      context.handle(
        _subjectNameMeta,
        subjectName.isAcceptableOrUnknown(
          data['subject_name']!,
          _subjectNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subjectNameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('max_mark')) {
      context.handle(
        _maxMarkMeta,
        maxMark.isAcceptableOrUnknown(data['max_mark']!, _maxMarkMeta),
      );
    } else if (isInserting) {
      context.missing(_maxMarkMeta);
    }
    if (data.containsKey('min_success_mark')) {
      context.handle(
        _minSuccessMarkMeta,
        minSuccessMark.isAcceptableOrUnknown(
          data['min_success_mark']!,
          _minSuccessMarkMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minSuccessMarkMeta);
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}course_id'],
      )!,
      subjectName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_name'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      maxMark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_mark'],
      )!,
      minSuccessMark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_success_mark'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points'],
      )!,
    );
  }

  @override
  $ExamsTable createAlias(String alias) {
    return $ExamsTable(attachedDatabase, alias);
  }
}

class Exam extends DataClass implements Insertable<Exam> {
  final int id;
  final int courseId;
  final String subjectName;
  final DateTime date;
  final String type;
  final int maxMark;
  final int minSuccessMark;
  final int points;
  const Exam({
    required this.id,
    required this.courseId,
    required this.subjectName,
    required this.date,
    required this.type,
    required this.maxMark,
    required this.minSuccessMark,
    required this.points,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['course_id'] = Variable<int>(courseId);
    map['subject_name'] = Variable<String>(subjectName);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    map['max_mark'] = Variable<int>(maxMark);
    map['min_success_mark'] = Variable<int>(minSuccessMark);
    map['points'] = Variable<int>(points);
    return map;
  }

  ExamsCompanion toCompanion(bool nullToAbsent) {
    return ExamsCompanion(
      id: Value(id),
      courseId: Value(courseId),
      subjectName: Value(subjectName),
      date: Value(date),
      type: Value(type),
      maxMark: Value(maxMark),
      minSuccessMark: Value(minSuccessMark),
      points: Value(points),
    );
  }

  factory Exam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exam(
      id: serializer.fromJson<int>(json['id']),
      courseId: serializer.fromJson<int>(json['courseId']),
      subjectName: serializer.fromJson<String>(json['subjectName']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      maxMark: serializer.fromJson<int>(json['maxMark']),
      minSuccessMark: serializer.fromJson<int>(json['minSuccessMark']),
      points: serializer.fromJson<int>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'courseId': serializer.toJson<int>(courseId),
      'subjectName': serializer.toJson<String>(subjectName),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'maxMark': serializer.toJson<int>(maxMark),
      'minSuccessMark': serializer.toJson<int>(minSuccessMark),
      'points': serializer.toJson<int>(points),
    };
  }

  Exam copyWith({
    int? id,
    int? courseId,
    String? subjectName,
    DateTime? date,
    String? type,
    int? maxMark,
    int? minSuccessMark,
    int? points,
  }) => Exam(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    subjectName: subjectName ?? this.subjectName,
    date: date ?? this.date,
    type: type ?? this.type,
    maxMark: maxMark ?? this.maxMark,
    minSuccessMark: minSuccessMark ?? this.minSuccessMark,
    points: points ?? this.points,
  );
  Exam copyWithCompanion(ExamsCompanion data) {
    return Exam(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      subjectName: data.subjectName.present
          ? data.subjectName.value
          : this.subjectName,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      maxMark: data.maxMark.present ? data.maxMark.value : this.maxMark,
      minSuccessMark: data.minSuccessMark.present
          ? data.minSuccessMark.value
          : this.minSuccessMark,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exam(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('subjectName: $subjectName, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('maxMark: $maxMark, ')
          ..write('minSuccessMark: $minSuccessMark, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    courseId,
    subjectName,
    date,
    type,
    maxMark,
    minSuccessMark,
    points,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exam &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.subjectName == this.subjectName &&
          other.date == this.date &&
          other.type == this.type &&
          other.maxMark == this.maxMark &&
          other.minSuccessMark == this.minSuccessMark &&
          other.points == this.points);
}

class ExamsCompanion extends UpdateCompanion<Exam> {
  final Value<int> id;
  final Value<int> courseId;
  final Value<String> subjectName;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<int> maxMark;
  final Value<int> minSuccessMark;
  final Value<int> points;
  const ExamsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.subjectName = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.maxMark = const Value.absent(),
    this.minSuccessMark = const Value.absent(),
    this.points = const Value.absent(),
  });
  ExamsCompanion.insert({
    this.id = const Value.absent(),
    required int courseId,
    required String subjectName,
    required DateTime date,
    required String type,
    required int maxMark,
    required int minSuccessMark,
    this.points = const Value.absent(),
  }) : courseId = Value(courseId),
       subjectName = Value(subjectName),
       date = Value(date),
       type = Value(type),
       maxMark = Value(maxMark),
       minSuccessMark = Value(minSuccessMark);
  static Insertable<Exam> custom({
    Expression<int>? id,
    Expression<int>? courseId,
    Expression<String>? subjectName,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? maxMark,
    Expression<int>? minSuccessMark,
    Expression<int>? points,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (subjectName != null) 'subject_name': subjectName,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (maxMark != null) 'max_mark': maxMark,
      if (minSuccessMark != null) 'min_success_mark': minSuccessMark,
      if (points != null) 'points': points,
    });
  }

  ExamsCompanion copyWith({
    Value<int>? id,
    Value<int>? courseId,
    Value<String>? subjectName,
    Value<DateTime>? date,
    Value<String>? type,
    Value<int>? maxMark,
    Value<int>? minSuccessMark,
    Value<int>? points,
  }) {
    return ExamsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      subjectName: subjectName ?? this.subjectName,
      date: date ?? this.date,
      type: type ?? this.type,
      maxMark: maxMark ?? this.maxMark,
      minSuccessMark: minSuccessMark ?? this.minSuccessMark,
      points: points ?? this.points,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<int>(courseId.value);
    }
    if (subjectName.present) {
      map['subject_name'] = Variable<String>(subjectName.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (maxMark.present) {
      map['max_mark'] = Variable<int>(maxMark.value);
    }
    if (minSuccessMark.present) {
      map['min_success_mark'] = Variable<int>(minSuccessMark.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('subjectName: $subjectName, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('maxMark: $maxMark, ')
          ..write('minSuccessMark: $minSuccessMark, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }
}

class $ExamSubmissionsTable extends ExamSubmissions
    with TableInfo<$ExamSubmissionsTable, ExamSubmission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamSubmissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<int> examId = GeneratedColumn<int>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _markMeta = const VerificationMeta('mark');
  @override
  late final GeneratedColumn<double> mark = GeneratedColumn<double>(
    'mark',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, studentId, examId, mark, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_submissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamSubmission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('mark')) {
      context.handle(
        _markMeta,
        mark.isAcceptableOrUnknown(data['mark']!, _markMeta),
      );
    } else if (isInserting) {
      context.missing(_markMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamSubmission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamSubmission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_id'],
      )!,
      mark: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mark'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $ExamSubmissionsTable createAlias(String alias) {
    return $ExamSubmissionsTable(attachedDatabase, alias);
  }
}

class ExamSubmission extends DataClass implements Insertable<ExamSubmission> {
  final int id;
  final int studentId;
  final int examId;
  final double mark;
  final DateTime date;
  const ExamSubmission({
    required this.id,
    required this.studentId,
    required this.examId,
    required this.mark,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['exam_id'] = Variable<int>(examId);
    map['mark'] = Variable<double>(mark);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  ExamSubmissionsCompanion toCompanion(bool nullToAbsent) {
    return ExamSubmissionsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      examId: Value(examId),
      mark: Value(mark),
      date: Value(date),
    );
  }

  factory ExamSubmission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamSubmission(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      examId: serializer.fromJson<int>(json['examId']),
      mark: serializer.fromJson<double>(json['mark']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'examId': serializer.toJson<int>(examId),
      'mark': serializer.toJson<double>(mark),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  ExamSubmission copyWith({
    int? id,
    int? studentId,
    int? examId,
    double? mark,
    DateTime? date,
  }) => ExamSubmission(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    examId: examId ?? this.examId,
    mark: mark ?? this.mark,
    date: date ?? this.date,
  );
  ExamSubmission copyWithCompanion(ExamSubmissionsCompanion data) {
    return ExamSubmission(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      examId: data.examId.present ? data.examId.value : this.examId,
      mark: data.mark.present ? data.mark.value : this.mark,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamSubmission(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('examId: $examId, ')
          ..write('mark: $mark, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, examId, mark, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamSubmission &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.examId == this.examId &&
          other.mark == this.mark &&
          other.date == this.date);
}

class ExamSubmissionsCompanion extends UpdateCompanion<ExamSubmission> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> examId;
  final Value<double> mark;
  final Value<DateTime> date;
  const ExamSubmissionsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.examId = const Value.absent(),
    this.mark = const Value.absent(),
    this.date = const Value.absent(),
  });
  ExamSubmissionsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int examId,
    required double mark,
    required DateTime date,
  }) : studentId = Value(studentId),
       examId = Value(examId),
       mark = Value(mark),
       date = Value(date);
  static Insertable<ExamSubmission> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? examId,
    Expression<double>? mark,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (examId != null) 'exam_id': examId,
      if (mark != null) 'mark': mark,
      if (date != null) 'date': date,
    });
  }

  ExamSubmissionsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? examId,
    Value<double>? mark,
    Value<DateTime>? date,
  }) {
    return ExamSubmissionsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      examId: examId ?? this.examId,
      mark: mark ?? this.mark,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<int>(examId.value);
    }
    if (mark.present) {
      map['mark'] = Variable<double>(mark.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamSubmissionsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('examId: $examId, ')
          ..write('mark: $mark, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $TeamsTable extends Teams with TableInfo<$TeamsTable, Team> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeNameMeta = const VerificationMeta(
    'typeName',
  );
  @override
  late final GeneratedColumn<String> typeName = GeneratedColumn<String>(
    'type_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherNameMeta = const VerificationMeta(
    'teacherName',
  );
  @override
  late final GeneratedColumn<String> teacherName = GeneratedColumn<String>(
    'teacher_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, typeName, teacherName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Team> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type_name')) {
      context.handle(
        _typeNameMeta,
        typeName.isAcceptableOrUnknown(data['type_name']!, _typeNameMeta),
      );
    } else if (isInserting) {
      context.missing(_typeNameMeta);
    }
    if (data.containsKey('teacher_name')) {
      context.handle(
        _teacherNameMeta,
        teacherName.isAcceptableOrUnknown(
          data['teacher_name']!,
          _teacherNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Team map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Team(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      typeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_name'],
      )!,
      teacherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_name'],
      )!,
    );
  }

  @override
  $TeamsTable createAlias(String alias) {
    return $TeamsTable(attachedDatabase, alias);
  }
}

class Team extends DataClass implements Insertable<Team> {
  final int id;
  final String name;
  final String typeName;
  final String teacherName;
  const Team({
    required this.id,
    required this.name,
    required this.typeName,
    required this.teacherName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type_name'] = Variable<String>(typeName);
    map['teacher_name'] = Variable<String>(teacherName);
    return map;
  }

  TeamsCompanion toCompanion(bool nullToAbsent) {
    return TeamsCompanion(
      id: Value(id),
      name: Value(name),
      typeName: Value(typeName),
      teacherName: Value(teacherName),
    );
  }

  factory Team.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Team(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      typeName: serializer.fromJson<String>(json['typeName']),
      teacherName: serializer.fromJson<String>(json['teacherName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'typeName': serializer.toJson<String>(typeName),
      'teacherName': serializer.toJson<String>(teacherName),
    };
  }

  Team copyWith({
    int? id,
    String? name,
    String? typeName,
    String? teacherName,
  }) => Team(
    id: id ?? this.id,
    name: name ?? this.name,
    typeName: typeName ?? this.typeName,
    teacherName: teacherName ?? this.teacherName,
  );
  Team copyWithCompanion(TeamsCompanion data) {
    return Team(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      typeName: data.typeName.present ? data.typeName.value : this.typeName,
      teacherName: data.teacherName.present
          ? data.teacherName.value
          : this.teacherName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Team(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typeName: $typeName, ')
          ..write('teacherName: $teacherName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, typeName, teacherName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Team &&
          other.id == this.id &&
          other.name == this.name &&
          other.typeName == this.typeName &&
          other.teacherName == this.teacherName);
}

class TeamsCompanion extends UpdateCompanion<Team> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> typeName;
  final Value<String> teacherName;
  const TeamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.typeName = const Value.absent(),
    this.teacherName = const Value.absent(),
  });
  TeamsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String typeName,
    this.teacherName = const Value.absent(),
  }) : name = Value(name),
       typeName = Value(typeName);
  static Insertable<Team> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? typeName,
    Expression<String>? teacherName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (typeName != null) 'type_name': typeName,
      if (teacherName != null) 'teacher_name': teacherName,
    });
  }

  TeamsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? typeName,
    Value<String>? teacherName,
  }) {
    return TeamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      typeName: typeName ?? this.typeName,
      teacherName: teacherName ?? this.teacherName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (typeName.present) {
      map['type_name'] = Variable<String>(typeName.value);
    }
    if (teacherName.present) {
      map['teacher_name'] = Variable<String>(teacherName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typeName: $typeName, ')
          ..write('teacherName: $teacherName')
          ..write(')'))
        .toString();
  }
}

class $StudentTeamsTable extends StudentTeams
    with TableInfo<$StudentTeamsTable, StudentTeam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<int> teamId = GeneratedColumn<int>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, studentId, teamId, date];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentTeam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentTeam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentTeam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
    );
  }

  @override
  $StudentTeamsTable createAlias(String alias) {
    return $StudentTeamsTable(attachedDatabase, alias);
  }
}

class StudentTeam extends DataClass implements Insertable<StudentTeam> {
  final int id;
  final int studentId;
  final int teamId;
  final DateTime? date;
  const StudentTeam({
    required this.id,
    required this.studentId,
    required this.teamId,
    this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['team_id'] = Variable<int>(teamId);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    return map;
  }

  StudentTeamsCompanion toCompanion(bool nullToAbsent) {
    return StudentTeamsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      teamId: Value(teamId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
    );
  }

  factory StudentTeam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentTeam(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      teamId: serializer.fromJson<int>(json['teamId']),
      date: serializer.fromJson<DateTime?>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'teamId': serializer.toJson<int>(teamId),
      'date': serializer.toJson<DateTime?>(date),
    };
  }

  StudentTeam copyWith({
    int? id,
    int? studentId,
    int? teamId,
    Value<DateTime?> date = const Value.absent(),
  }) => StudentTeam(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    teamId: teamId ?? this.teamId,
    date: date.present ? date.value : this.date,
  );
  StudentTeam copyWithCompanion(StudentTeamsCompanion data) {
    return StudentTeam(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentTeam(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('teamId: $teamId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, teamId, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentTeam &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.teamId == this.teamId &&
          other.date == this.date);
}

class StudentTeamsCompanion extends UpdateCompanion<StudentTeam> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> teamId;
  final Value<DateTime?> date;
  const StudentTeamsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.date = const Value.absent(),
  });
  StudentTeamsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int teamId,
    this.date = const Value.absent(),
  }) : studentId = Value(studentId),
       teamId = Value(teamId);
  static Insertable<StudentTeam> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? teamId,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (teamId != null) 'team_id': teamId,
      if (date != null) 'date': date,
    });
  }

  StudentTeamsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? teamId,
    Value<DateTime?>? date,
  }) {
    return StudentTeamsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      teamId: teamId ?? this.teamId,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<int>(teamId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentTeamsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('teamId: $teamId, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'father_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearOfBirthMeta = const VerificationMeta(
    'yearOfBirth',
  );
  @override
  late final GeneratedColumn<int> yearOfBirth = GeneratedColumn<int>(
    'year_of_birth',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fatherName,
    yearOfBirth,
    barcode,
    active,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('father_name')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(data['father_name']!, _fatherNameMeta),
      );
    }
    if (data.containsKey('year_of_birth')) {
      context.handle(
        _yearOfBirthMeta,
        yearOfBirth.isAcceptableOrUnknown(
          data['year_of_birth']!,
          _yearOfBirthMeta,
        ),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_name'],
      ),
      yearOfBirth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_of_birth'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final int id;
  final String name;
  final String? fatherName;
  final int? yearOfBirth;
  final String barcode;
  final bool active;
  final DateTime? lastSeenAt;
  const Student({
    required this.id,
    required this.name,
    this.fatherName,
    this.yearOfBirth,
    required this.barcode,
    required this.active,
    this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || fatherName != null) {
      map['father_name'] = Variable<String>(fatherName);
    }
    if (!nullToAbsent || yearOfBirth != null) {
      map['year_of_birth'] = Variable<int>(yearOfBirth);
    }
    map['barcode'] = Variable<String>(barcode);
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      name: Value(name),
      fatherName: fatherName == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherName),
      yearOfBirth: yearOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(yearOfBirth),
      barcode: Value(barcode),
      active: Value(active),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fatherName: serializer.fromJson<String?>(json['fatherName']),
      yearOfBirth: serializer.fromJson<int?>(json['yearOfBirth']),
      barcode: serializer.fromJson<String>(json['barcode']),
      active: serializer.fromJson<bool>(json['active']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'fatherName': serializer.toJson<String?>(fatherName),
      'yearOfBirth': serializer.toJson<int?>(yearOfBirth),
      'barcode': serializer.toJson<String>(barcode),
      'active': serializer.toJson<bool>(active),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
    };
  }

  Student copyWith({
    int? id,
    String? name,
    Value<String?> fatherName = const Value.absent(),
    Value<int?> yearOfBirth = const Value.absent(),
    String? barcode,
    bool? active,
    Value<DateTime?> lastSeenAt = const Value.absent(),
  }) => Student(
    id: id ?? this.id,
    name: name ?? this.name,
    fatherName: fatherName.present ? fatherName.value : this.fatherName,
    yearOfBirth: yearOfBirth.present ? yearOfBirth.value : this.yearOfBirth,
    barcode: barcode ?? this.barcode,
    active: active ?? this.active,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      yearOfBirth: data.yearOfBirth.present
          ? data.yearOfBirth.value
          : this.yearOfBirth,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      active: data.active.present ? data.active.value : this.active,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fatherName: $fatherName, ')
          ..write('yearOfBirth: $yearOfBirth, ')
          ..write('barcode: $barcode, ')
          ..write('active: $active, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    fatherName,
    yearOfBirth,
    barcode,
    active,
    lastSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.name == this.name &&
          other.fatherName == this.fatherName &&
          other.yearOfBirth == this.yearOfBirth &&
          other.barcode == this.barcode &&
          other.active == this.active &&
          other.lastSeenAt == this.lastSeenAt);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> fatherName;
  final Value<int?> yearOfBirth;
  final Value<String> barcode;
  final Value<bool> active;
  final Value<DateTime?> lastSeenAt;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.yearOfBirth = const Value.absent(),
    this.barcode = const Value.absent(),
    this.active = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.fatherName = const Value.absent(),
    this.yearOfBirth = const Value.absent(),
    required String barcode,
    this.active = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
  }) : name = Value(name),
       barcode = Value(barcode);
  static Insertable<Student> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? fatherName,
    Expression<int>? yearOfBirth,
    Expression<String>? barcode,
    Expression<bool>? active,
    Expression<DateTime>? lastSeenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fatherName != null) 'father_name': fatherName,
      if (yearOfBirth != null) 'year_of_birth': yearOfBirth,
      if (barcode != null) 'barcode': barcode,
      if (active != null) 'active': active,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
    });
  }

  StudentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? fatherName,
    Value<int?>? yearOfBirth,
    Value<String>? barcode,
    Value<bool>? active,
    Value<DateTime?>? lastSeenAt,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      yearOfBirth: yearOfBirth ?? this.yearOfBirth,
      barcode: barcode ?? this.barcode,
      active: active ?? this.active,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (yearOfBirth.present) {
      map['year_of_birth'] = Variable<int>(yearOfBirth.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fatherName: $fatherName, ')
          ..write('yearOfBirth: $yearOfBirth, ')
          ..write('barcode: $barcode, ')
          ..write('active: $active, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }
}

class $PhonesTable extends Phones with TableInfo<$PhonesTable, Phone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, studentId, phone, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Phone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Phone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Phone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $PhonesTable createAlias(String alias) {
    return $PhonesTable(attachedDatabase, alias);
  }
}

class Phone extends DataClass implements Insertable<Phone> {
  final int id;
  final int studentId;
  final String phone;
  final String type;
  const Phone({
    required this.id,
    required this.studentId,
    required this.phone,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['phone'] = Variable<String>(phone);
    map['type'] = Variable<String>(type);
    return map;
  }

  PhonesCompanion toCompanion(bool nullToAbsent) {
    return PhonesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      phone: Value(phone),
      type: Value(type),
    );
  }

  factory Phone.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Phone(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      phone: serializer.fromJson<String>(json['phone']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'phone': serializer.toJson<String>(phone),
      'type': serializer.toJson<String>(type),
    };
  }

  Phone copyWith({int? id, int? studentId, String? phone, String? type}) =>
      Phone(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        phone: phone ?? this.phone,
        type: type ?? this.type,
      );
  Phone copyWithCompanion(PhonesCompanion data) {
    return Phone(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      phone: data.phone.present ? data.phone.value : this.phone,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Phone(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('phone: $phone, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, phone, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Phone &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.phone == this.phone &&
          other.type == this.type);
}

class PhonesCompanion extends UpdateCompanion<Phone> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<String> phone;
  final Value<String> type;
  const PhonesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.phone = const Value.absent(),
    this.type = const Value.absent(),
  });
  PhonesCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required String phone,
    required String type,
  }) : studentId = Value(studentId),
       phone = Value(phone),
       type = Value(type);
  static Insertable<Phone> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<String>? phone,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (phone != null) 'phone': phone,
      if (type != null) 'type': type,
    });
  }

  PhonesCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<String>? phone,
    Value<String>? type,
  }) {
    return PhonesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhonesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('phone: $phone, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $MatnsTable extends Matns with TableInfo<$MatnsTable, Matn> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pointsPerVerseMeta = const VerificationMeta(
    'pointsPerVerse',
  );
  @override
  late final GeneratedColumn<int> pointsPerVerse = GeneratedColumn<int>(
    'points_per_verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalVersesMeta = const VerificationMeta(
    'totalVerses',
  );
  @override
  late final GeneratedColumn<int> totalVerses = GeneratedColumn<int>(
    'total_verses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, pointsPerVerse, totalVerses];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Matn> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('points_per_verse')) {
      context.handle(
        _pointsPerVerseMeta,
        pointsPerVerse.isAcceptableOrUnknown(
          data['points_per_verse']!,
          _pointsPerVerseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pointsPerVerseMeta);
    }
    if (data.containsKey('total_verses')) {
      context.handle(
        _totalVersesMeta,
        totalVerses.isAcceptableOrUnknown(
          data['total_verses']!,
          _totalVersesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalVersesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Matn map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Matn(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      pointsPerVerse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}points_per_verse'],
      )!,
      totalVerses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_verses'],
      )!,
    );
  }

  @override
  $MatnsTable createAlias(String alias) {
    return $MatnsTable(attachedDatabase, alias);
  }
}

class Matn extends DataClass implements Insertable<Matn> {
  final int id;
  final String name;
  final int pointsPerVerse;
  final int totalVerses;
  const Matn({
    required this.id,
    required this.name,
    required this.pointsPerVerse,
    required this.totalVerses,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['points_per_verse'] = Variable<int>(pointsPerVerse);
    map['total_verses'] = Variable<int>(totalVerses);
    return map;
  }

  MatnsCompanion toCompanion(bool nullToAbsent) {
    return MatnsCompanion(
      id: Value(id),
      name: Value(name),
      pointsPerVerse: Value(pointsPerVerse),
      totalVerses: Value(totalVerses),
    );
  }

  factory Matn.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Matn(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      pointsPerVerse: serializer.fromJson<int>(json['pointsPerVerse']),
      totalVerses: serializer.fromJson<int>(json['totalVerses']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'pointsPerVerse': serializer.toJson<int>(pointsPerVerse),
      'totalVerses': serializer.toJson<int>(totalVerses),
    };
  }

  Matn copyWith({
    int? id,
    String? name,
    int? pointsPerVerse,
    int? totalVerses,
  }) => Matn(
    id: id ?? this.id,
    name: name ?? this.name,
    pointsPerVerse: pointsPerVerse ?? this.pointsPerVerse,
    totalVerses: totalVerses ?? this.totalVerses,
  );
  Matn copyWithCompanion(MatnsCompanion data) {
    return Matn(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      pointsPerVerse: data.pointsPerVerse.present
          ? data.pointsPerVerse.value
          : this.pointsPerVerse,
      totalVerses: data.totalVerses.present
          ? data.totalVerses.value
          : this.totalVerses,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Matn(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pointsPerVerse: $pointsPerVerse, ')
          ..write('totalVerses: $totalVerses')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, pointsPerVerse, totalVerses);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Matn &&
          other.id == this.id &&
          other.name == this.name &&
          other.pointsPerVerse == this.pointsPerVerse &&
          other.totalVerses == this.totalVerses);
}

class MatnsCompanion extends UpdateCompanion<Matn> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> pointsPerVerse;
  final Value<int> totalVerses;
  const MatnsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.pointsPerVerse = const Value.absent(),
    this.totalVerses = const Value.absent(),
  });
  MatnsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int pointsPerVerse,
    required int totalVerses,
  }) : name = Value(name),
       pointsPerVerse = Value(pointsPerVerse),
       totalVerses = Value(totalVerses);
  static Insertable<Matn> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? pointsPerVerse,
    Expression<int>? totalVerses,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (pointsPerVerse != null) 'points_per_verse': pointsPerVerse,
      if (totalVerses != null) 'total_verses': totalVerses,
    });
  }

  MatnsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? pointsPerVerse,
    Value<int>? totalVerses,
  }) {
    return MatnsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      pointsPerVerse: pointsPerVerse ?? this.pointsPerVerse,
      totalVerses: totalVerses ?? this.totalVerses,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (pointsPerVerse.present) {
      map['points_per_verse'] = Variable<int>(pointsPerVerse.value);
    }
    if (totalVerses.present) {
      map['total_verses'] = Variable<int>(totalVerses.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatnsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('pointsPerVerse: $pointsPerVerse, ')
          ..write('totalVerses: $totalVerses')
          ..write(')'))
        .toString();
  }
}

class $MatnRecitationsTable extends MatnRecitations
    with TableInfo<$MatnRecitationsTable, MatnRecitation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatnRecitationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matnIdMeta = const VerificationMeta('matnId');
  @override
  late final GeneratedColumn<int> matnId = GeneratedColumn<int>(
    'matn_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastVerseMeta = const VerificationMeta(
    'lastVerse',
  );
  @override
  late final GeneratedColumn<int> lastVerse = GeneratedColumn<int>(
    'last_verse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherNameMeta = const VerificationMeta(
    'teacherName',
  );
  @override
  late final GeneratedColumn<String> teacherName = GeneratedColumn<String>(
    'teacher_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    matnId,
    lastVerse,
    teacherName,
    sessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matn_recitations';
  @override
  VerificationContext validateIntegrity(
    Insertable<MatnRecitation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('matn_id')) {
      context.handle(
        _matnIdMeta,
        matnId.isAcceptableOrUnknown(data['matn_id']!, _matnIdMeta),
      );
    } else if (isInserting) {
      context.missing(_matnIdMeta);
    }
    if (data.containsKey('last_verse')) {
      context.handle(
        _lastVerseMeta,
        lastVerse.isAcceptableOrUnknown(data['last_verse']!, _lastVerseMeta),
      );
    } else if (isInserting) {
      context.missing(_lastVerseMeta);
    }
    if (data.containsKey('teacher_name')) {
      context.handle(
        _teacherNameMeta,
        teacherName.isAcceptableOrUnknown(
          data['teacher_name']!,
          _teacherNameMeta,
        ),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatnRecitation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatnRecitation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      matnId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}matn_id'],
      )!,
      lastVerse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_verse'],
      )!,
      teacherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_name'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
    );
  }

  @override
  $MatnRecitationsTable createAlias(String alias) {
    return $MatnRecitationsTable(attachedDatabase, alias);
  }
}

class MatnRecitation extends DataClass implements Insertable<MatnRecitation> {
  final int id;
  final int studentId;
  final int matnId;
  final int lastVerse;
  final String teacherName;
  final int sessionId;
  const MatnRecitation({
    required this.id,
    required this.studentId,
    required this.matnId,
    required this.lastVerse,
    required this.teacherName,
    required this.sessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['matn_id'] = Variable<int>(matnId);
    map['last_verse'] = Variable<int>(lastVerse);
    map['teacher_name'] = Variable<String>(teacherName);
    map['session_id'] = Variable<int>(sessionId);
    return map;
  }

  MatnRecitationsCompanion toCompanion(bool nullToAbsent) {
    return MatnRecitationsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      matnId: Value(matnId),
      lastVerse: Value(lastVerse),
      teacherName: Value(teacherName),
      sessionId: Value(sessionId),
    );
  }

  factory MatnRecitation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatnRecitation(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      matnId: serializer.fromJson<int>(json['matnId']),
      lastVerse: serializer.fromJson<int>(json['lastVerse']),
      teacherName: serializer.fromJson<String>(json['teacherName']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'matnId': serializer.toJson<int>(matnId),
      'lastVerse': serializer.toJson<int>(lastVerse),
      'teacherName': serializer.toJson<String>(teacherName),
      'sessionId': serializer.toJson<int>(sessionId),
    };
  }

  MatnRecitation copyWith({
    int? id,
    int? studentId,
    int? matnId,
    int? lastVerse,
    String? teacherName,
    int? sessionId,
  }) => MatnRecitation(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    matnId: matnId ?? this.matnId,
    lastVerse: lastVerse ?? this.lastVerse,
    teacherName: teacherName ?? this.teacherName,
    sessionId: sessionId ?? this.sessionId,
  );
  MatnRecitation copyWithCompanion(MatnRecitationsCompanion data) {
    return MatnRecitation(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      matnId: data.matnId.present ? data.matnId.value : this.matnId,
      lastVerse: data.lastVerse.present ? data.lastVerse.value : this.lastVerse,
      teacherName: data.teacherName.present
          ? data.teacherName.value
          : this.teacherName,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatnRecitation(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('matnId: $matnId, ')
          ..write('lastVerse: $lastVerse, ')
          ..write('teacherName: $teacherName, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, studentId, matnId, lastVerse, teacherName, sessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatnRecitation &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.matnId == this.matnId &&
          other.lastVerse == this.lastVerse &&
          other.teacherName == this.teacherName &&
          other.sessionId == this.sessionId);
}

class MatnRecitationsCompanion extends UpdateCompanion<MatnRecitation> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> matnId;
  final Value<int> lastVerse;
  final Value<String> teacherName;
  final Value<int> sessionId;
  const MatnRecitationsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.matnId = const Value.absent(),
    this.lastVerse = const Value.absent(),
    this.teacherName = const Value.absent(),
    this.sessionId = const Value.absent(),
  });
  MatnRecitationsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int matnId,
    required int lastVerse,
    this.teacherName = const Value.absent(),
    required int sessionId,
  }) : studentId = Value(studentId),
       matnId = Value(matnId),
       lastVerse = Value(lastVerse),
       sessionId = Value(sessionId);
  static Insertable<MatnRecitation> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? matnId,
    Expression<int>? lastVerse,
    Expression<String>? teacherName,
    Expression<int>? sessionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (matnId != null) 'matn_id': matnId,
      if (lastVerse != null) 'last_verse': lastVerse,
      if (teacherName != null) 'teacher_name': teacherName,
      if (sessionId != null) 'session_id': sessionId,
    });
  }

  MatnRecitationsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? matnId,
    Value<int>? lastVerse,
    Value<String>? teacherName,
    Value<int>? sessionId,
  }) {
    return MatnRecitationsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      matnId: matnId ?? this.matnId,
      lastVerse: lastVerse ?? this.lastVerse,
      teacherName: teacherName ?? this.teacherName,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (matnId.present) {
      map['matn_id'] = Variable<int>(matnId.value);
    }
    if (lastVerse.present) {
      map['last_verse'] = Variable<int>(lastVerse.value);
    }
    if (teacherName.present) {
      map['teacher_name'] = Variable<String>(teacherName.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatnRecitationsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('matnId: $matnId, ')
          ..write('lastVerse: $lastVerse, ')
          ..write('teacherName: $teacherName, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudentNoticesTable extends StudentNotices
    with TableInfo<$StudentNoticesTable, StudentNotice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentNoticesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    kind,
    title,
    body,
    date,
    read,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_notices';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentNotice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StudentNotice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentNotice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      read: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read'],
      )!,
    );
  }

  @override
  $StudentNoticesTable createAlias(String alias) {
    return $StudentNoticesTable(attachedDatabase, alias);
  }
}

class StudentNotice extends DataClass implements Insertable<StudentNotice> {
  final int id;
  final int studentId;
  final String kind;
  final String title;
  final String body;
  final DateTime date;
  final bool read;
  const StudentNotice({
    required this.id,
    required this.studentId,
    required this.kind,
    required this.title,
    required this.body,
    required this.date,
    required this.read,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['date'] = Variable<DateTime>(date);
    map['read'] = Variable<bool>(read);
    return map;
  }

  StudentNoticesCompanion toCompanion(bool nullToAbsent) {
    return StudentNoticesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      kind: Value(kind),
      title: Value(title),
      body: Value(body),
      date: Value(date),
      read: Value(read),
    );
  }

  factory StudentNotice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentNotice(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      date: serializer.fromJson<DateTime>(json['date']),
      read: serializer.fromJson<bool>(json['read']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'date': serializer.toJson<DateTime>(date),
      'read': serializer.toJson<bool>(read),
    };
  }

  StudentNotice copyWith({
    int? id,
    int? studentId,
    String? kind,
    String? title,
    String? body,
    DateTime? date,
    bool? read,
  }) => StudentNotice(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    body: body ?? this.body,
    date: date ?? this.date,
    read: read ?? this.read,
  );
  StudentNotice copyWithCompanion(StudentNoticesCompanion data) {
    return StudentNotice(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      date: data.date.present ? data.date.value : this.date,
      read: data.read.present ? data.read.value : this.read,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentNotice(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('date: $date, ')
          ..write('read: $read')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, kind, title, body, date, read);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentNotice &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.body == this.body &&
          other.date == this.date &&
          other.read == this.read);
}

class StudentNoticesCompanion extends UpdateCompanion<StudentNotice> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> date;
  final Value<bool> read;
  const StudentNoticesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.date = const Value.absent(),
    this.read = const Value.absent(),
  });
  StudentNoticesCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required String kind,
    required String title,
    required String body,
    required DateTime date,
    this.read = const Value.absent(),
  }) : studentId = Value(studentId),
       kind = Value(kind),
       title = Value(title),
       body = Value(body),
       date = Value(date);
  static Insertable<StudentNotice> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? date,
    Expression<bool>? read,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (date != null) 'date': date,
      if (read != null) 'read': read,
    });
  }

  StudentNoticesCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? date,
    Value<bool>? read,
  }) {
    return StudentNoticesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      date: date ?? this.date,
      read: read ?? this.read,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentNoticesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('date: $date, ')
          ..write('read: $read')
          ..write(')'))
        .toString();
  }
}

class $TeamTypesTable extends TeamTypes
    with TableInfo<$TeamTypesTable, TeamType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeamType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $TeamTypesTable createAlias(String alias) {
    return $TeamTypesTable(attachedDatabase, alias);
  }
}

class TeamType extends DataClass implements Insertable<TeamType> {
  final int id;
  final String name;
  final String? note;
  const TeamType({required this.id, required this.name, this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  TeamTypesCompanion toCompanion(bool nullToAbsent) {
    return TeamTypesCompanion(
      id: Value(id),
      name: Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory TeamType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'note': serializer.toJson<String?>(note),
    };
  }

  TeamType copyWith({
    int? id,
    String? name,
    Value<String?> note = const Value.absent(),
  }) => TeamType(
    id: id ?? this.id,
    name: name ?? this.name,
    note: note.present ? note.value : this.note,
  );
  TeamType copyWithCompanion(TeamTypesCompanion data) {
    return TeamType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamType(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamType &&
          other.id == this.id &&
          other.name == this.name &&
          other.note == this.note);
}

class TeamTypesCompanion extends UpdateCompanion<TeamType> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> note;
  const TeamTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
  });
  TeamTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.note = const Value.absent(),
  }) : name = Value(name);
  static Insertable<TeamType> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
    });
  }

  TeamTypesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? note,
  }) {
    return TeamTypesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookMeta = const VerificationMeta('book');
  @override
  late final GeneratedColumn<String> book = GeneratedColumn<String>(
    'book',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, book];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('book')) {
      context.handle(
        _bookMeta,
        book.isAcceptableOrUnknown(data['book']!, _bookMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      book: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book'],
      ),
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final String name;
  final String? book;
  const Subject({required this.id, required this.name, this.book});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || book != null) {
      map['book'] = Variable<String>(book);
    }
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      book: book == null && nullToAbsent ? const Value.absent() : Value(book),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      book: serializer.fromJson<String?>(json['book']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'book': serializer.toJson<String?>(book),
    };
  }

  Subject copyWith({
    int? id,
    String? name,
    Value<String?> book = const Value.absent(),
  }) => Subject(
    id: id ?? this.id,
    name: name ?? this.name,
    book: book.present ? book.value : this.book,
  );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      book: data.book.present ? data.book.value : this.book,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('book: $book')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, book);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.book == this.book);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> book;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.book = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.book = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? book,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (book != null) 'book': book,
    });
  }

  SubjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? book,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      book: book ?? this.book,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (book.present) {
      map['book'] = Variable<String>(book.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('book: $book')
          ..write(')'))
        .toString();
  }
}

class $DistributablesTable extends Distributables
    with TableInfo<$DistributablesTable, Distributable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DistributablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, note, active];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'distributables';
  @override
  VerificationContext validateIntegrity(
    Insertable<Distributable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Distributable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Distributable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $DistributablesTable createAlias(String alias) {
    return $DistributablesTable(attachedDatabase, alias);
  }
}

class Distributable extends DataClass implements Insertable<Distributable> {
  final int id;
  final String name;
  final String? note;
  final bool active;
  const Distributable({
    required this.id,
    required this.name,
    this.note,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  DistributablesCompanion toCompanion(bool nullToAbsent) {
    return DistributablesCompanion(
      id: Value(id),
      name: Value(name),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      active: Value(active),
    );
  }

  factory Distributable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Distributable(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      note: serializer.fromJson<String?>(json['note']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'note': serializer.toJson<String?>(note),
      'active': serializer.toJson<bool>(active),
    };
  }

  Distributable copyWith({
    int? id,
    String? name,
    Value<String?> note = const Value.absent(),
    bool? active,
  }) => Distributable(
    id: id ?? this.id,
    name: name ?? this.name,
    note: note.present ? note.value : this.note,
    active: active ?? this.active,
  );
  Distributable copyWithCompanion(DistributablesCompanion data) {
    return Distributable(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      note: data.note.present ? data.note.value : this.note,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Distributable(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, note, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Distributable &&
          other.id == this.id &&
          other.name == this.name &&
          other.note == this.note &&
          other.active == this.active);
}

class DistributablesCompanion extends UpdateCompanion<Distributable> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> note;
  final Value<bool> active;
  const DistributablesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.note = const Value.absent(),
    this.active = const Value.absent(),
  });
  DistributablesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.note = const Value.absent(),
    this.active = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Distributable> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? note,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (active != null) 'active': active,
    });
  }

  DistributablesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? note,
    Value<bool>? active,
  }) {
    return DistributablesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      note: note ?? this.note,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DistributablesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('note: $note, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $DistributionsTable extends Distributions
    with TableInfo<$DistributionsTable, Distribution> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DistributionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distributableIdMeta = const VerificationMeta(
    'distributableId',
  );
  @override
  late final GeneratedColumn<int> distributableId = GeneratedColumn<int>(
    'distributable_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    distributableId,
    count,
    date,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'distributions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Distribution> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('distributable_id')) {
      context.handle(
        _distributableIdMeta,
        distributableId.isAcceptableOrUnknown(
          data['distributable_id']!,
          _distributableIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distributableIdMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Distribution map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Distribution(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      distributableId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distributable_id'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
    );
  }

  @override
  $DistributionsTable createAlias(String alias) {
    return $DistributionsTable(attachedDatabase, alias);
  }
}

class Distribution extends DataClass implements Insertable<Distribution> {
  final int id;
  final int studentId;
  final int distributableId;
  final int count;
  final DateTime date;
  const Distribution({
    required this.id,
    required this.studentId,
    required this.distributableId,
    required this.count,
    required this.date,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['distributable_id'] = Variable<int>(distributableId);
    map['count'] = Variable<int>(count);
    map['date'] = Variable<DateTime>(date);
    return map;
  }

  DistributionsCompanion toCompanion(bool nullToAbsent) {
    return DistributionsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      distributableId: Value(distributableId),
      count: Value(count),
      date: Value(date),
    );
  }

  factory Distribution.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Distribution(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      distributableId: serializer.fromJson<int>(json['distributableId']),
      count: serializer.fromJson<int>(json['count']),
      date: serializer.fromJson<DateTime>(json['date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'distributableId': serializer.toJson<int>(distributableId),
      'count': serializer.toJson<int>(count),
      'date': serializer.toJson<DateTime>(date),
    };
  }

  Distribution copyWith({
    int? id,
    int? studentId,
    int? distributableId,
    int? count,
    DateTime? date,
  }) => Distribution(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    distributableId: distributableId ?? this.distributableId,
    count: count ?? this.count,
    date: date ?? this.date,
  );
  Distribution copyWithCompanion(DistributionsCompanion data) {
    return Distribution(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      distributableId: data.distributableId.present
          ? data.distributableId.value
          : this.distributableId,
      count: data.count.present ? data.count.value : this.count,
      date: data.date.present ? data.date.value : this.date,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Distribution(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('distributableId: $distributableId, ')
          ..write('count: $count, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, distributableId, count, date);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Distribution &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.distributableId == this.distributableId &&
          other.count == this.count &&
          other.date == this.date);
}

class DistributionsCompanion extends UpdateCompanion<Distribution> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> distributableId;
  final Value<int> count;
  final Value<DateTime> date;
  const DistributionsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.distributableId = const Value.absent(),
    this.count = const Value.absent(),
    this.date = const Value.absent(),
  });
  DistributionsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int distributableId,
    this.count = const Value.absent(),
    required DateTime date,
  }) : studentId = Value(studentId),
       distributableId = Value(distributableId),
       date = Value(date);
  static Insertable<Distribution> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? distributableId,
    Expression<int>? count,
    Expression<DateTime>? date,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (distributableId != null) 'distributable_id': distributableId,
      if (count != null) 'count': count,
      if (date != null) 'date': date,
    });
  }

  DistributionsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? distributableId,
    Value<int>? count,
    Value<DateTime>? date,
  }) {
    return DistributionsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      distributableId: distributableId ?? this.distributableId,
      count: count ?? this.count,
      date: date ?? this.date,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (distributableId.present) {
      map['distributable_id'] = Variable<int>(distributableId.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DistributionsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('distributableId: $distributableId, ')
          ..write('count: $count, ')
          ..write('date: $date')
          ..write(')'))
        .toString();
  }
}

class $ChangeRequestsTable extends ChangeRequests
    with TableInfo<$ChangeRequestsTable, ChangeRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
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
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  @override
  late final GeneratedColumn<String> currentValue = GeneratedColumn<String>(
    'current_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedValueMeta = const VerificationMeta(
    'requestedValue',
  );
  @override
  late final GeneratedColumn<String> requestedValue = GeneratedColumn<String>(
    'requested_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> reviewedAt = GeneratedColumn<DateTime>(
    'reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    field,
    currentValue,
    requestedValue,
    status,
    note,
    createdAt,
    reviewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'change_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChangeRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    }
    if (data.containsKey('requested_value')) {
      context.handle(
        _requestedValueMeta,
        requestedValue.isAcceptableOrUnknown(
          data['requested_value']!,
          _requestedValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedValueMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChangeRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_value'],
      ),
      requestedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_value'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}reviewed_at'],
      ),
    );
  }

  @override
  $ChangeRequestsTable createAlias(String alias) {
    return $ChangeRequestsTable(attachedDatabase, alias);
  }
}

class ChangeRequest extends DataClass implements Insertable<ChangeRequest> {
  final int id;
  final int studentId;
  final String field;
  final String? currentValue;
  final String requestedValue;
  final String status;
  final String? note;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  const ChangeRequest({
    required this.id,
    required this.studentId,
    required this.field,
    this.currentValue,
    required this.requestedValue,
    required this.status,
    this.note,
    required this.createdAt,
    this.reviewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || currentValue != null) {
      map['current_value'] = Variable<String>(currentValue);
    }
    map['requested_value'] = Variable<String>(requestedValue);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || reviewedAt != null) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt);
    }
    return map;
  }

  ChangeRequestsCompanion toCompanion(bool nullToAbsent) {
    return ChangeRequestsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      field: Value(field),
      currentValue: currentValue == null && nullToAbsent
          ? const Value.absent()
          : Value(currentValue),
      requestedValue: Value(requestedValue),
      status: Value(status),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      reviewedAt: reviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reviewedAt),
    );
  }

  factory ChangeRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeRequest(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      field: serializer.fromJson<String>(json['field']),
      currentValue: serializer.fromJson<String?>(json['currentValue']),
      requestedValue: serializer.fromJson<String>(json['requestedValue']),
      status: serializer.fromJson<String>(json['status']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      reviewedAt: serializer.fromJson<DateTime?>(json['reviewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'field': serializer.toJson<String>(field),
      'currentValue': serializer.toJson<String?>(currentValue),
      'requestedValue': serializer.toJson<String>(requestedValue),
      'status': serializer.toJson<String>(status),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'reviewedAt': serializer.toJson<DateTime?>(reviewedAt),
    };
  }

  ChangeRequest copyWith({
    int? id,
    int? studentId,
    String? field,
    Value<String?> currentValue = const Value.absent(),
    String? requestedValue,
    String? status,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> reviewedAt = const Value.absent(),
  }) => ChangeRequest(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    field: field ?? this.field,
    currentValue: currentValue.present ? currentValue.value : this.currentValue,
    requestedValue: requestedValue ?? this.requestedValue,
    status: status ?? this.status,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    reviewedAt: reviewedAt.present ? reviewedAt.value : this.reviewedAt,
  );
  ChangeRequest copyWithCompanion(ChangeRequestsCompanion data) {
    return ChangeRequest(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      field: data.field.present ? data.field.value : this.field,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      requestedValue: data.requestedValue.present
          ? data.requestedValue.value
          : this.requestedValue,
      status: data.status.present ? data.status.value : this.status,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeRequest(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('field: $field, ')
          ..write('currentValue: $currentValue, ')
          ..write('requestedValue: $requestedValue, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    field,
    currentValue,
    requestedValue,
    status,
    note,
    createdAt,
    reviewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeRequest &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.field == this.field &&
          other.currentValue == this.currentValue &&
          other.requestedValue == this.requestedValue &&
          other.status == this.status &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.reviewedAt == this.reviewedAt);
}

class ChangeRequestsCompanion extends UpdateCompanion<ChangeRequest> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<String> field;
  final Value<String?> currentValue;
  final Value<String> requestedValue;
  final Value<String> status;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime?> reviewedAt;
  const ChangeRequestsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.field = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.requestedValue = const Value.absent(),
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  });
  ChangeRequestsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required String field,
    this.currentValue = const Value.absent(),
    required String requestedValue,
    this.status = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reviewedAt = const Value.absent(),
  }) : studentId = Value(studentId),
       field = Value(field),
       requestedValue = Value(requestedValue);
  static Insertable<ChangeRequest> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<String>? field,
    Expression<String>? currentValue,
    Expression<String>? requestedValue,
    Expression<String>? status,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? reviewedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (field != null) 'field': field,
      if (currentValue != null) 'current_value': currentValue,
      if (requestedValue != null) 'requested_value': requestedValue,
      if (status != null) 'status': status,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
    });
  }

  ChangeRequestsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<String>? field,
    Value<String?>? currentValue,
    Value<String>? requestedValue,
    Value<String>? status,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime?>? reviewedAt,
  }) {
    return ChangeRequestsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      field: field ?? this.field,
      currentValue: currentValue ?? this.currentValue,
      requestedValue: requestedValue ?? this.requestedValue,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<String>(currentValue.value);
    }
    if (requestedValue.present) {
      map['requested_value'] = Variable<String>(requestedValue.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<DateTime>(reviewedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeRequestsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('field: $field, ')
          ..write('currentValue: $currentValue, ')
          ..write('requestedValue: $requestedValue, ')
          ..write('status: $status, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('reviewedAt: $reviewedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$StudentDatabase extends GeneratedDatabase {
  _$StudentDatabase(QueryExecutor e) : super(e);
  $StudentDatabaseManager get managers => $StudentDatabaseManager(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $AttendancesTable attendances = $AttendancesTable(this);
  late final $MemorizationsTable memorizations = $MemorizationsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CertificatesTable certificates = $CertificatesTable(this);
  late final $ExamsTable exams = $ExamsTable(this);
  late final $ExamSubmissionsTable examSubmissions = $ExamSubmissionsTable(
    this,
  );
  late final $TeamsTable teams = $TeamsTable(this);
  late final $StudentTeamsTable studentTeams = $StudentTeamsTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $PhonesTable phones = $PhonesTable(this);
  late final $MatnsTable matns = $MatnsTable(this);
  late final $MatnRecitationsTable matnRecitations = $MatnRecitationsTable(
    this,
  );
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $StudentNoticesTable studentNotices = $StudentNoticesTable(this);
  late final $TeamTypesTable teamTypes = $TeamTypesTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $DistributablesTable distributables = $DistributablesTable(this);
  late final $DistributionsTable distributions = $DistributionsTable(this);
  late final $ChangeRequestsTable changeRequests = $ChangeRequestsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    courses,
    sessions,
    attendances,
    memorizations,
    transactions,
    certificates,
    exams,
    examSubmissions,
    teams,
    studentTeams,
    students,
    phones,
    matns,
    matnRecitations,
    appMeta,
    studentNotices,
    teamTypes,
    subjects,
    distributables,
    distributions,
    changeRequests,
  ];
}

typedef $$CoursesTableCreateCompanionBuilder =
    CoursesCompanion Function({
      Value<int> id,
      required String name,
      required DateTime startDate,
      required DateTime endDate,
      Value<int> goodPoints,
      Value<int> veryGoodPoints,
      Value<int> excellentPoints,
      Value<int> certificatePoints,
    });
typedef $$CoursesTableUpdateCompanionBuilder =
    CoursesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> startDate,
      Value<DateTime> endDate,
      Value<int> goodPoints,
      Value<int> veryGoodPoints,
      Value<int> excellentPoints,
      Value<int> certificatePoints,
    });

class $$CoursesTableFilterComposer
    extends Composer<_$StudentDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goodPoints => $composableBuilder(
    column: $table.goodPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get veryGoodPoints => $composableBuilder(
    column: $table.veryGoodPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get excellentPoints => $composableBuilder(
    column: $table.excellentPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get certificatePoints => $composableBuilder(
    column: $table.certificatePoints,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoursesTableOrderingComposer
    extends Composer<_$StudentDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goodPoints => $composableBuilder(
    column: $table.goodPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get veryGoodPoints => $composableBuilder(
    column: $table.veryGoodPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get excellentPoints => $composableBuilder(
    column: $table.excellentPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get certificatePoints => $composableBuilder(
    column: $table.certificatePoints,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$StudentDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get goodPoints => $composableBuilder(
    column: $table.goodPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get veryGoodPoints => $composableBuilder(
    column: $table.veryGoodPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get excellentPoints => $composableBuilder(
    column: $table.excellentPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get certificatePoints => $composableBuilder(
    column: $table.certificatePoints,
    builder: (column) => column,
  );
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $CoursesTable,
          Course,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (Course, BaseReferences<_$StudentDatabase, $CoursesTable, Course>),
          Course,
          PrefetchHooks Function()
        > {
  $$CoursesTableTableManager(_$StudentDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime> endDate = const Value.absent(),
                Value<int> goodPoints = const Value.absent(),
                Value<int> veryGoodPoints = const Value.absent(),
                Value<int> excellentPoints = const Value.absent(),
                Value<int> certificatePoints = const Value.absent(),
              }) => CoursesCompanion(
                id: id,
                name: name,
                startDate: startDate,
                endDate: endDate,
                goodPoints: goodPoints,
                veryGoodPoints: veryGoodPoints,
                excellentPoints: excellentPoints,
                certificatePoints: certificatePoints,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime startDate,
                required DateTime endDate,
                Value<int> goodPoints = const Value.absent(),
                Value<int> veryGoodPoints = const Value.absent(),
                Value<int> excellentPoints = const Value.absent(),
                Value<int> certificatePoints = const Value.absent(),
              }) => CoursesCompanion.insert(
                id: id,
                name: name,
                startDate: startDate,
                endDate: endDate,
                goodPoints: goodPoints,
                veryGoodPoints: veryGoodPoints,
                excellentPoints: excellentPoints,
                certificatePoints: certificatePoints,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $CoursesTable,
      Course,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (Course, BaseReferences<_$StudentDatabase, $CoursesTable, Course>),
      Course,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required int courseId,
      required DateTime date,
      Value<int> earlyPoints,
      Value<int> midPoints,
      Value<int> latePoints,
      Value<String> earlyUntil,
      Value<String> lateFrom,
      Value<int> orderInCourse,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<int> courseId,
      Value<DateTime> date,
      Value<int> earlyPoints,
      Value<int> midPoints,
      Value<int> latePoints,
      Value<String> earlyUntil,
      Value<String> lateFrom,
      Value<int> orderInCourse,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$StudentDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get earlyPoints => $composableBuilder(
    column: $table.earlyPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get midPoints => $composableBuilder(
    column: $table.midPoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latePoints => $composableBuilder(
    column: $table.latePoints,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get earlyUntil => $composableBuilder(
    column: $table.earlyUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lateFrom => $composableBuilder(
    column: $table.lateFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderInCourse => $composableBuilder(
    column: $table.orderInCourse,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$StudentDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earlyPoints => $composableBuilder(
    column: $table.earlyPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get midPoints => $composableBuilder(
    column: $table.midPoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latePoints => $composableBuilder(
    column: $table.latePoints,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get earlyUntil => $composableBuilder(
    column: $table.earlyUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lateFrom => $composableBuilder(
    column: $table.lateFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderInCourse => $composableBuilder(
    column: $table.orderInCourse,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get earlyPoints => $composableBuilder(
    column: $table.earlyPoints,
    builder: (column) => column,
  );

  GeneratedColumn<int> get midPoints =>
      $composableBuilder(column: $table.midPoints, builder: (column) => column);

  GeneratedColumn<int> get latePoints => $composableBuilder(
    column: $table.latePoints,
    builder: (column) => column,
  );

  GeneratedColumn<String> get earlyUntil => $composableBuilder(
    column: $table.earlyUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lateFrom =>
      $composableBuilder(column: $table.lateFrom, builder: (column) => column);

  GeneratedColumn<int> get orderInCourse => $composableBuilder(
    column: $table.orderInCourse,
    builder: (column) => column,
  );
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, BaseReferences<_$StudentDatabase, $SessionsTable, Session>),
          Session,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$StudentDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> courseId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> earlyPoints = const Value.absent(),
                Value<int> midPoints = const Value.absent(),
                Value<int> latePoints = const Value.absent(),
                Value<String> earlyUntil = const Value.absent(),
                Value<String> lateFrom = const Value.absent(),
                Value<int> orderInCourse = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                courseId: courseId,
                date: date,
                earlyPoints: earlyPoints,
                midPoints: midPoints,
                latePoints: latePoints,
                earlyUntil: earlyUntil,
                lateFrom: lateFrom,
                orderInCourse: orderInCourse,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int courseId,
                required DateTime date,
                Value<int> earlyPoints = const Value.absent(),
                Value<int> midPoints = const Value.absent(),
                Value<int> latePoints = const Value.absent(),
                Value<String> earlyUntil = const Value.absent(),
                Value<String> lateFrom = const Value.absent(),
                Value<int> orderInCourse = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                courseId: courseId,
                date: date,
                earlyPoints: earlyPoints,
                midPoints: midPoints,
                latePoints: latePoints,
                earlyUntil: earlyUntil,
                lateFrom: lateFrom,
                orderInCourse: orderInCourse,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, BaseReferences<_$StudentDatabase, $SessionsTable, Session>),
      Session,
      PrefetchHooks Function()
    >;
typedef $$AttendancesTableCreateCompanionBuilder =
    AttendancesCompanion Function({
      Value<int> id,
      required int studentId,
      required int sessionId,
      Value<DateTime?> arrivalTime,
    });
typedef $$AttendancesTableUpdateCompanionBuilder =
    AttendancesCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> sessionId,
      Value<DateTime?> arrivalTime,
    });

class $$AttendancesTableFilterComposer
    extends Composer<_$StudentDatabase, $AttendancesTable> {
  $$AttendancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttendancesTableOrderingComposer
    extends Composer<_$StudentDatabase, $AttendancesTable> {
  $$AttendancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttendancesTableAnnotationComposer
    extends Composer<_$StudentDatabase, $AttendancesTable> {
  $$AttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<DateTime> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => column,
  );
}

class $$AttendancesTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $AttendancesTable,
          Attendance,
          $$AttendancesTableFilterComposer,
          $$AttendancesTableOrderingComposer,
          $$AttendancesTableAnnotationComposer,
          $$AttendancesTableCreateCompanionBuilder,
          $$AttendancesTableUpdateCompanionBuilder,
          (
            Attendance,
            BaseReferences<_$StudentDatabase, $AttendancesTable, Attendance>,
          ),
          Attendance,
          PrefetchHooks Function()
        > {
  $$AttendancesTableTableManager(_$StudentDatabase db, $AttendancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<DateTime?> arrivalTime = const Value.absent(),
              }) => AttendancesCompanion(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                arrivalTime: arrivalTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int sessionId,
                Value<DateTime?> arrivalTime = const Value.absent(),
              }) => AttendancesCompanion.insert(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                arrivalTime: arrivalTime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttendancesTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $AttendancesTable,
      Attendance,
      $$AttendancesTableFilterComposer,
      $$AttendancesTableOrderingComposer,
      $$AttendancesTableAnnotationComposer,
      $$AttendancesTableCreateCompanionBuilder,
      $$AttendancesTableUpdateCompanionBuilder,
      (
        Attendance,
        BaseReferences<_$StudentDatabase, $AttendancesTable, Attendance>,
      ),
      Attendance,
      PrefetchHooks Function()
    >;
typedef $$MemorizationsTableCreateCompanionBuilder =
    MemorizationsCompanion Function({
      Value<int> id,
      required int studentId,
      required int sessionId,
      required int page,
      Value<int> partIndex,
      Value<int> parts,
      Value<String> surah,
      required int rating,
      Value<String> reciterName,
      required DateTime date,
    });
typedef $$MemorizationsTableUpdateCompanionBuilder =
    MemorizationsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> sessionId,
      Value<int> page,
      Value<int> partIndex,
      Value<int> parts,
      Value<String> surah,
      Value<int> rating,
      Value<String> reciterName,
      Value<DateTime> date,
    });

class $$MemorizationsTableFilterComposer
    extends Composer<_$StudentDatabase, $MemorizationsTable> {
  $$MemorizationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partIndex => $composableBuilder(
    column: $table.partIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parts => $composableBuilder(
    column: $table.parts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reciterName => $composableBuilder(
    column: $table.reciterName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemorizationsTableOrderingComposer
    extends Composer<_$StudentDatabase, $MemorizationsTable> {
  $$MemorizationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partIndex => $composableBuilder(
    column: $table.partIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parts => $composableBuilder(
    column: $table.parts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get surah => $composableBuilder(
    column: $table.surah,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reciterName => $composableBuilder(
    column: $table.reciterName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemorizationsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $MemorizationsTable> {
  $$MemorizationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get partIndex =>
      $composableBuilder(column: $table.partIndex, builder: (column) => column);

  GeneratedColumn<int> get parts =>
      $composableBuilder(column: $table.parts, builder: (column) => column);

  GeneratedColumn<String> get surah =>
      $composableBuilder(column: $table.surah, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get reciterName => $composableBuilder(
    column: $table.reciterName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$MemorizationsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $MemorizationsTable,
          Memorization,
          $$MemorizationsTableFilterComposer,
          $$MemorizationsTableOrderingComposer,
          $$MemorizationsTableAnnotationComposer,
          $$MemorizationsTableCreateCompanionBuilder,
          $$MemorizationsTableUpdateCompanionBuilder,
          (
            Memorization,
            BaseReferences<
              _$StudentDatabase,
              $MemorizationsTable,
              Memorization
            >,
          ),
          Memorization,
          PrefetchHooks Function()
        > {
  $$MemorizationsTableTableManager(
    _$StudentDatabase db,
    $MemorizationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemorizationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemorizationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemorizationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> partIndex = const Value.absent(),
                Value<int> parts = const Value.absent(),
                Value<String> surah = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String> reciterName = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => MemorizationsCompanion(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                page: page,
                partIndex: partIndex,
                parts: parts,
                surah: surah,
                rating: rating,
                reciterName: reciterName,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int sessionId,
                required int page,
                Value<int> partIndex = const Value.absent(),
                Value<int> parts = const Value.absent(),
                Value<String> surah = const Value.absent(),
                required int rating,
                Value<String> reciterName = const Value.absent(),
                required DateTime date,
              }) => MemorizationsCompanion.insert(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                page: page,
                partIndex: partIndex,
                parts: parts,
                surah: surah,
                rating: rating,
                reciterName: reciterName,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemorizationsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $MemorizationsTable,
      Memorization,
      $$MemorizationsTableFilterComposer,
      $$MemorizationsTableOrderingComposer,
      $$MemorizationsTableAnnotationComposer,
      $$MemorizationsTableCreateCompanionBuilder,
      $$MemorizationsTableUpdateCompanionBuilder,
      (
        Memorization,
        BaseReferences<_$StudentDatabase, $MemorizationsTable, Memorization>,
      ),
      Memorization,
      PrefetchHooks Function()
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required int studentId,
      required int sessionId,
      required String type,
      required int pointsValue,
      required DateTime date,
      Value<String?> description,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> sessionId,
      Value<String> type,
      Value<int> pointsValue,
      Value<DateTime> date,
      Value<String?> description,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$StudentDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsValue => $composableBuilder(
    column: $table.pointsValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$StudentDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsValue => $composableBuilder(
    column: $table.pointsValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get pointsValue => $composableBuilder(
    column: $table.pointsValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$StudentDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(
    _$StudentDatabase db,
    $TransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> pointsValue = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                type: type,
                pointsValue: pointsValue,
                date: date,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int sessionId,
                required String type,
                required int pointsValue,
                required DateTime date,
                Value<String?> description = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                studentId: studentId,
                sessionId: sessionId,
                type: type,
                pointsValue: pointsValue,
                date: date,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$StudentDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$CertificatesTableCreateCompanionBuilder =
    CertificatesCompanion Function({
      Value<int> id,
      required int studentId,
      required int courseId,
      required int startJuz,
      required int endJuz,
      required int mark,
      Value<bool> byHeart,
      required DateTime date,
    });
typedef $$CertificatesTableUpdateCompanionBuilder =
    CertificatesCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> courseId,
      Value<int> startJuz,
      Value<int> endJuz,
      Value<int> mark,
      Value<bool> byHeart,
      Value<DateTime> date,
    });

class $$CertificatesTableFilterComposer
    extends Composer<_$StudentDatabase, $CertificatesTable> {
  $$CertificatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startJuz => $composableBuilder(
    column: $table.startJuz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endJuz => $composableBuilder(
    column: $table.endJuz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mark => $composableBuilder(
    column: $table.mark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get byHeart => $composableBuilder(
    column: $table.byHeart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CertificatesTableOrderingComposer
    extends Composer<_$StudentDatabase, $CertificatesTable> {
  $$CertificatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startJuz => $composableBuilder(
    column: $table.startJuz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endJuz => $composableBuilder(
    column: $table.endJuz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mark => $composableBuilder(
    column: $table.mark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get byHeart => $composableBuilder(
    column: $table.byHeart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CertificatesTableAnnotationComposer
    extends Composer<_$StudentDatabase, $CertificatesTable> {
  $$CertificatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<int> get startJuz =>
      $composableBuilder(column: $table.startJuz, builder: (column) => column);

  GeneratedColumn<int> get endJuz =>
      $composableBuilder(column: $table.endJuz, builder: (column) => column);

  GeneratedColumn<int> get mark =>
      $composableBuilder(column: $table.mark, builder: (column) => column);

  GeneratedColumn<bool> get byHeart =>
      $composableBuilder(column: $table.byHeart, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$CertificatesTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $CertificatesTable,
          Certificate,
          $$CertificatesTableFilterComposer,
          $$CertificatesTableOrderingComposer,
          $$CertificatesTableAnnotationComposer,
          $$CertificatesTableCreateCompanionBuilder,
          $$CertificatesTableUpdateCompanionBuilder,
          (
            Certificate,
            BaseReferences<_$StudentDatabase, $CertificatesTable, Certificate>,
          ),
          Certificate,
          PrefetchHooks Function()
        > {
  $$CertificatesTableTableManager(
    _$StudentDatabase db,
    $CertificatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CertificatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CertificatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CertificatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> courseId = const Value.absent(),
                Value<int> startJuz = const Value.absent(),
                Value<int> endJuz = const Value.absent(),
                Value<int> mark = const Value.absent(),
                Value<bool> byHeart = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => CertificatesCompanion(
                id: id,
                studentId: studentId,
                courseId: courseId,
                startJuz: startJuz,
                endJuz: endJuz,
                mark: mark,
                byHeart: byHeart,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int courseId,
                required int startJuz,
                required int endJuz,
                required int mark,
                Value<bool> byHeart = const Value.absent(),
                required DateTime date,
              }) => CertificatesCompanion.insert(
                id: id,
                studentId: studentId,
                courseId: courseId,
                startJuz: startJuz,
                endJuz: endJuz,
                mark: mark,
                byHeart: byHeart,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CertificatesTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $CertificatesTable,
      Certificate,
      $$CertificatesTableFilterComposer,
      $$CertificatesTableOrderingComposer,
      $$CertificatesTableAnnotationComposer,
      $$CertificatesTableCreateCompanionBuilder,
      $$CertificatesTableUpdateCompanionBuilder,
      (
        Certificate,
        BaseReferences<_$StudentDatabase, $CertificatesTable, Certificate>,
      ),
      Certificate,
      PrefetchHooks Function()
    >;
typedef $$ExamsTableCreateCompanionBuilder =
    ExamsCompanion Function({
      Value<int> id,
      required int courseId,
      required String subjectName,
      required DateTime date,
      required String type,
      required int maxMark,
      required int minSuccessMark,
      Value<int> points,
    });
typedef $$ExamsTableUpdateCompanionBuilder =
    ExamsCompanion Function({
      Value<int> id,
      Value<int> courseId,
      Value<String> subjectName,
      Value<DateTime> date,
      Value<String> type,
      Value<int> maxMark,
      Value<int> minSuccessMark,
      Value<int> points,
    });

class $$ExamsTableFilterComposer
    extends Composer<_$StudentDatabase, $ExamsTable> {
  $$ExamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxMark => $composableBuilder(
    column: $table.maxMark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minSuccessMark => $composableBuilder(
    column: $table.minSuccessMark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExamsTableOrderingComposer
    extends Composer<_$StudentDatabase, $ExamsTable> {
  $$ExamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxMark => $composableBuilder(
    column: $table.maxMark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minSuccessMark => $composableBuilder(
    column: $table.minSuccessMark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $ExamsTable> {
  $$ExamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get subjectName => $composableBuilder(
    column: $table.subjectName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get maxMark =>
      $composableBuilder(column: $table.maxMark, builder: (column) => column);

  GeneratedColumn<int> get minSuccessMark => $composableBuilder(
    column: $table.minSuccessMark,
    builder: (column) => column,
  );

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);
}

class $$ExamsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $ExamsTable,
          Exam,
          $$ExamsTableFilterComposer,
          $$ExamsTableOrderingComposer,
          $$ExamsTableAnnotationComposer,
          $$ExamsTableCreateCompanionBuilder,
          $$ExamsTableUpdateCompanionBuilder,
          (Exam, BaseReferences<_$StudentDatabase, $ExamsTable, Exam>),
          Exam,
          PrefetchHooks Function()
        > {
  $$ExamsTableTableManager(_$StudentDatabase db, $ExamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> courseId = const Value.absent(),
                Value<String> subjectName = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> maxMark = const Value.absent(),
                Value<int> minSuccessMark = const Value.absent(),
                Value<int> points = const Value.absent(),
              }) => ExamsCompanion(
                id: id,
                courseId: courseId,
                subjectName: subjectName,
                date: date,
                type: type,
                maxMark: maxMark,
                minSuccessMark: minSuccessMark,
                points: points,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int courseId,
                required String subjectName,
                required DateTime date,
                required String type,
                required int maxMark,
                required int minSuccessMark,
                Value<int> points = const Value.absent(),
              }) => ExamsCompanion.insert(
                id: id,
                courseId: courseId,
                subjectName: subjectName,
                date: date,
                type: type,
                maxMark: maxMark,
                minSuccessMark: minSuccessMark,
                points: points,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExamsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $ExamsTable,
      Exam,
      $$ExamsTableFilterComposer,
      $$ExamsTableOrderingComposer,
      $$ExamsTableAnnotationComposer,
      $$ExamsTableCreateCompanionBuilder,
      $$ExamsTableUpdateCompanionBuilder,
      (Exam, BaseReferences<_$StudentDatabase, $ExamsTable, Exam>),
      Exam,
      PrefetchHooks Function()
    >;
typedef $$ExamSubmissionsTableCreateCompanionBuilder =
    ExamSubmissionsCompanion Function({
      Value<int> id,
      required int studentId,
      required int examId,
      required double mark,
      required DateTime date,
    });
typedef $$ExamSubmissionsTableUpdateCompanionBuilder =
    ExamSubmissionsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> examId,
      Value<double> mark,
      Value<DateTime> date,
    });

class $$ExamSubmissionsTableFilterComposer
    extends Composer<_$StudentDatabase, $ExamSubmissionsTable> {
  $$ExamSubmissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mark => $composableBuilder(
    column: $table.mark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExamSubmissionsTableOrderingComposer
    extends Composer<_$StudentDatabase, $ExamSubmissionsTable> {
  $$ExamSubmissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get examId => $composableBuilder(
    column: $table.examId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mark => $composableBuilder(
    column: $table.mark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamSubmissionsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $ExamSubmissionsTable> {
  $$ExamSubmissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get examId =>
      $composableBuilder(column: $table.examId, builder: (column) => column);

  GeneratedColumn<double> get mark =>
      $composableBuilder(column: $table.mark, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$ExamSubmissionsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $ExamSubmissionsTable,
          ExamSubmission,
          $$ExamSubmissionsTableFilterComposer,
          $$ExamSubmissionsTableOrderingComposer,
          $$ExamSubmissionsTableAnnotationComposer,
          $$ExamSubmissionsTableCreateCompanionBuilder,
          $$ExamSubmissionsTableUpdateCompanionBuilder,
          (
            ExamSubmission,
            BaseReferences<
              _$StudentDatabase,
              $ExamSubmissionsTable,
              ExamSubmission
            >,
          ),
          ExamSubmission,
          PrefetchHooks Function()
        > {
  $$ExamSubmissionsTableTableManager(
    _$StudentDatabase db,
    $ExamSubmissionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamSubmissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamSubmissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamSubmissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> examId = const Value.absent(),
                Value<double> mark = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => ExamSubmissionsCompanion(
                id: id,
                studentId: studentId,
                examId: examId,
                mark: mark,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int examId,
                required double mark,
                required DateTime date,
              }) => ExamSubmissionsCompanion.insert(
                id: id,
                studentId: studentId,
                examId: examId,
                mark: mark,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExamSubmissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $ExamSubmissionsTable,
      ExamSubmission,
      $$ExamSubmissionsTableFilterComposer,
      $$ExamSubmissionsTableOrderingComposer,
      $$ExamSubmissionsTableAnnotationComposer,
      $$ExamSubmissionsTableCreateCompanionBuilder,
      $$ExamSubmissionsTableUpdateCompanionBuilder,
      (
        ExamSubmission,
        BaseReferences<
          _$StudentDatabase,
          $ExamSubmissionsTable,
          ExamSubmission
        >,
      ),
      ExamSubmission,
      PrefetchHooks Function()
    >;
typedef $$TeamsTableCreateCompanionBuilder =
    TeamsCompanion Function({
      Value<int> id,
      required String name,
      required String typeName,
      Value<String> teacherName,
    });
typedef $$TeamsTableUpdateCompanionBuilder =
    TeamsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> typeName,
      Value<String> teacherName,
    });

class $$TeamsTableFilterComposer
    extends Composer<_$StudentDatabase, $TeamsTable> {
  $$TeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamsTableOrderingComposer
    extends Composer<_$StudentDatabase, $TeamsTable> {
  $$TeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeName => $composableBuilder(
    column: $table.typeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $TeamsTable> {
  $$TeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get typeName =>
      $composableBuilder(column: $table.typeName, builder: (column) => column);

  GeneratedColumn<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => column,
  );
}

class $$TeamsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $TeamsTable,
          Team,
          $$TeamsTableFilterComposer,
          $$TeamsTableOrderingComposer,
          $$TeamsTableAnnotationComposer,
          $$TeamsTableCreateCompanionBuilder,
          $$TeamsTableUpdateCompanionBuilder,
          (Team, BaseReferences<_$StudentDatabase, $TeamsTable, Team>),
          Team,
          PrefetchHooks Function()
        > {
  $$TeamsTableTableManager(_$StudentDatabase db, $TeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> typeName = const Value.absent(),
                Value<String> teacherName = const Value.absent(),
              }) => TeamsCompanion(
                id: id,
                name: name,
                typeName: typeName,
                teacherName: teacherName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String typeName,
                Value<String> teacherName = const Value.absent(),
              }) => TeamsCompanion.insert(
                id: id,
                name: name,
                typeName: typeName,
                teacherName: teacherName,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $TeamsTable,
      Team,
      $$TeamsTableFilterComposer,
      $$TeamsTableOrderingComposer,
      $$TeamsTableAnnotationComposer,
      $$TeamsTableCreateCompanionBuilder,
      $$TeamsTableUpdateCompanionBuilder,
      (Team, BaseReferences<_$StudentDatabase, $TeamsTable, Team>),
      Team,
      PrefetchHooks Function()
    >;
typedef $$StudentTeamsTableCreateCompanionBuilder =
    StudentTeamsCompanion Function({
      Value<int> id,
      required int studentId,
      required int teamId,
      Value<DateTime?> date,
    });
typedef $$StudentTeamsTableUpdateCompanionBuilder =
    StudentTeamsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> teamId,
      Value<DateTime?> date,
    });

class $$StudentTeamsTableFilterComposer
    extends Composer<_$StudentDatabase, $StudentTeamsTable> {
  $$StudentTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentTeamsTableOrderingComposer
    extends Composer<_$StudentDatabase, $StudentTeamsTable> {
  $$StudentTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentTeamsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $StudentTeamsTable> {
  $$StudentTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$StudentTeamsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $StudentTeamsTable,
          StudentTeam,
          $$StudentTeamsTableFilterComposer,
          $$StudentTeamsTableOrderingComposer,
          $$StudentTeamsTableAnnotationComposer,
          $$StudentTeamsTableCreateCompanionBuilder,
          $$StudentTeamsTableUpdateCompanionBuilder,
          (
            StudentTeam,
            BaseReferences<_$StudentDatabase, $StudentTeamsTable, StudentTeam>,
          ),
          StudentTeam,
          PrefetchHooks Function()
        > {
  $$StudentTeamsTableTableManager(
    _$StudentDatabase db,
    $StudentTeamsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> teamId = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
              }) => StudentTeamsCompanion(
                id: id,
                studentId: studentId,
                teamId: teamId,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int teamId,
                Value<DateTime?> date = const Value.absent(),
              }) => StudentTeamsCompanion.insert(
                id: id,
                studentId: studentId,
                teamId: teamId,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $StudentTeamsTable,
      StudentTeam,
      $$StudentTeamsTableFilterComposer,
      $$StudentTeamsTableOrderingComposer,
      $$StudentTeamsTableAnnotationComposer,
      $$StudentTeamsTableCreateCompanionBuilder,
      $$StudentTeamsTableUpdateCompanionBuilder,
      (
        StudentTeam,
        BaseReferences<_$StudentDatabase, $StudentTeamsTable, StudentTeam>,
      ),
      StudentTeam,
      PrefetchHooks Function()
    >;
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> fatherName,
      Value<int?> yearOfBirth,
      required String barcode,
      Value<bool> active,
      Value<DateTime?> lastSeenAt,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> fatherName,
      Value<int?> yearOfBirth,
      Value<String> barcode,
      Value<bool> active,
      Value<DateTime?> lastSeenAt,
    });

class $$StudentsTableFilterComposer
    extends Composer<_$StudentDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearOfBirth => $composableBuilder(
    column: $table.yearOfBirth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentsTableOrderingComposer
    extends Composer<_$StudentDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearOfBirth => $composableBuilder(
    column: $table.yearOfBirth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yearOfBirth => $composableBuilder(
    column: $table.yearOfBirth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, BaseReferences<_$StudentDatabase, $StudentsTable, Student>),
          Student,
          PrefetchHooks Function()
        > {
  $$StudentsTableTableManager(_$StudentDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> fatherName = const Value.absent(),
                Value<int?> yearOfBirth = const Value.absent(),
                Value<String> barcode = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                name: name,
                fatherName: fatherName,
                yearOfBirth: yearOfBirth,
                barcode: barcode,
                active: active,
                lastSeenAt: lastSeenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> fatherName = const Value.absent(),
                Value<int?> yearOfBirth = const Value.absent(),
                required String barcode,
                Value<bool> active = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                name: name,
                fatherName: fatherName,
                yearOfBirth: yearOfBirth,
                barcode: barcode,
                active: active,
                lastSeenAt: lastSeenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, BaseReferences<_$StudentDatabase, $StudentsTable, Student>),
      Student,
      PrefetchHooks Function()
    >;
typedef $$PhonesTableCreateCompanionBuilder =
    PhonesCompanion Function({
      Value<int> id,
      required int studentId,
      required String phone,
      required String type,
    });
typedef $$PhonesTableUpdateCompanionBuilder =
    PhonesCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<String> phone,
      Value<String> type,
    });

class $$PhonesTableFilterComposer
    extends Composer<_$StudentDatabase, $PhonesTable> {
  $$PhonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhonesTableOrderingComposer
    extends Composer<_$StudentDatabase, $PhonesTable> {
  $$PhonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhonesTableAnnotationComposer
    extends Composer<_$StudentDatabase, $PhonesTable> {
  $$PhonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$PhonesTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $PhonesTable,
          Phone,
          $$PhonesTableFilterComposer,
          $$PhonesTableOrderingComposer,
          $$PhonesTableAnnotationComposer,
          $$PhonesTableCreateCompanionBuilder,
          $$PhonesTableUpdateCompanionBuilder,
          (Phone, BaseReferences<_$StudentDatabase, $PhonesTable, Phone>),
          Phone,
          PrefetchHooks Function()
        > {
  $$PhonesTableTableManager(_$StudentDatabase db, $PhonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => PhonesCompanion(
                id: id,
                studentId: studentId,
                phone: phone,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required String phone,
                required String type,
              }) => PhonesCompanion.insert(
                id: id,
                studentId: studentId,
                phone: phone,
                type: type,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhonesTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $PhonesTable,
      Phone,
      $$PhonesTableFilterComposer,
      $$PhonesTableOrderingComposer,
      $$PhonesTableAnnotationComposer,
      $$PhonesTableCreateCompanionBuilder,
      $$PhonesTableUpdateCompanionBuilder,
      (Phone, BaseReferences<_$StudentDatabase, $PhonesTable, Phone>),
      Phone,
      PrefetchHooks Function()
    >;
typedef $$MatnsTableCreateCompanionBuilder =
    MatnsCompanion Function({
      Value<int> id,
      required String name,
      required int pointsPerVerse,
      required int totalVerses,
    });
typedef $$MatnsTableUpdateCompanionBuilder =
    MatnsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> pointsPerVerse,
      Value<int> totalVerses,
    });

class $$MatnsTableFilterComposer
    extends Composer<_$StudentDatabase, $MatnsTable> {
  $$MatnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pointsPerVerse => $composableBuilder(
    column: $table.pointsPerVerse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalVerses => $composableBuilder(
    column: $table.totalVerses,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatnsTableOrderingComposer
    extends Composer<_$StudentDatabase, $MatnsTable> {
  $$MatnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pointsPerVerse => $composableBuilder(
    column: $table.pointsPerVerse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalVerses => $composableBuilder(
    column: $table.totalVerses,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatnsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $MatnsTable> {
  $$MatnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get pointsPerVerse => $composableBuilder(
    column: $table.pointsPerVerse,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalVerses => $composableBuilder(
    column: $table.totalVerses,
    builder: (column) => column,
  );
}

class $$MatnsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $MatnsTable,
          Matn,
          $$MatnsTableFilterComposer,
          $$MatnsTableOrderingComposer,
          $$MatnsTableAnnotationComposer,
          $$MatnsTableCreateCompanionBuilder,
          $$MatnsTableUpdateCompanionBuilder,
          (Matn, BaseReferences<_$StudentDatabase, $MatnsTable, Matn>),
          Matn,
          PrefetchHooks Function()
        > {
  $$MatnsTableTableManager(_$StudentDatabase db, $MatnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> pointsPerVerse = const Value.absent(),
                Value<int> totalVerses = const Value.absent(),
              }) => MatnsCompanion(
                id: id,
                name: name,
                pointsPerVerse: pointsPerVerse,
                totalVerses: totalVerses,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int pointsPerVerse,
                required int totalVerses,
              }) => MatnsCompanion.insert(
                id: id,
                name: name,
                pointsPerVerse: pointsPerVerse,
                totalVerses: totalVerses,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatnsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $MatnsTable,
      Matn,
      $$MatnsTableFilterComposer,
      $$MatnsTableOrderingComposer,
      $$MatnsTableAnnotationComposer,
      $$MatnsTableCreateCompanionBuilder,
      $$MatnsTableUpdateCompanionBuilder,
      (Matn, BaseReferences<_$StudentDatabase, $MatnsTable, Matn>),
      Matn,
      PrefetchHooks Function()
    >;
typedef $$MatnRecitationsTableCreateCompanionBuilder =
    MatnRecitationsCompanion Function({
      Value<int> id,
      required int studentId,
      required int matnId,
      required int lastVerse,
      Value<String> teacherName,
      required int sessionId,
    });
typedef $$MatnRecitationsTableUpdateCompanionBuilder =
    MatnRecitationsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> matnId,
      Value<int> lastVerse,
      Value<String> teacherName,
      Value<int> sessionId,
    });

class $$MatnRecitationsTableFilterComposer
    extends Composer<_$StudentDatabase, $MatnRecitationsTable> {
  $$MatnRecitationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get matnId => $composableBuilder(
    column: $table.matnId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastVerse => $composableBuilder(
    column: $table.lastVerse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MatnRecitationsTableOrderingComposer
    extends Composer<_$StudentDatabase, $MatnRecitationsTable> {
  $$MatnRecitationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get matnId => $composableBuilder(
    column: $table.matnId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastVerse => $composableBuilder(
    column: $table.lastVerse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MatnRecitationsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $MatnRecitationsTable> {
  $$MatnRecitationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get matnId =>
      $composableBuilder(column: $table.matnId, builder: (column) => column);

  GeneratedColumn<int> get lastVerse =>
      $composableBuilder(column: $table.lastVerse, builder: (column) => column);

  GeneratedColumn<String> get teacherName => $composableBuilder(
    column: $table.teacherName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);
}

class $$MatnRecitationsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $MatnRecitationsTable,
          MatnRecitation,
          $$MatnRecitationsTableFilterComposer,
          $$MatnRecitationsTableOrderingComposer,
          $$MatnRecitationsTableAnnotationComposer,
          $$MatnRecitationsTableCreateCompanionBuilder,
          $$MatnRecitationsTableUpdateCompanionBuilder,
          (
            MatnRecitation,
            BaseReferences<
              _$StudentDatabase,
              $MatnRecitationsTable,
              MatnRecitation
            >,
          ),
          MatnRecitation,
          PrefetchHooks Function()
        > {
  $$MatnRecitationsTableTableManager(
    _$StudentDatabase db,
    $MatnRecitationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatnRecitationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatnRecitationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatnRecitationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> matnId = const Value.absent(),
                Value<int> lastVerse = const Value.absent(),
                Value<String> teacherName = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
              }) => MatnRecitationsCompanion(
                id: id,
                studentId: studentId,
                matnId: matnId,
                lastVerse: lastVerse,
                teacherName: teacherName,
                sessionId: sessionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int matnId,
                required int lastVerse,
                Value<String> teacherName = const Value.absent(),
                required int sessionId,
              }) => MatnRecitationsCompanion.insert(
                id: id,
                studentId: studentId,
                matnId: matnId,
                lastVerse: lastVerse,
                teacherName: teacherName,
                sessionId: sessionId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MatnRecitationsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $MatnRecitationsTable,
      MatnRecitation,
      $$MatnRecitationsTableFilterComposer,
      $$MatnRecitationsTableOrderingComposer,
      $$MatnRecitationsTableAnnotationComposer,
      $$MatnRecitationsTableCreateCompanionBuilder,
      $$MatnRecitationsTableUpdateCompanionBuilder,
      (
        MatnRecitation,
        BaseReferences<
          _$StudentDatabase,
          $MatnRecitationsTable,
          MatnRecitation
        >,
      ),
      MatnRecitation,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$StudentDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$StudentDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$StudentDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$StudentDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$StudentDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (
        AppMetaData,
        BaseReferences<_$StudentDatabase, $AppMetaTable, AppMetaData>,
      ),
      AppMetaData,
      PrefetchHooks Function()
    >;
typedef $$StudentNoticesTableCreateCompanionBuilder =
    StudentNoticesCompanion Function({
      Value<int> id,
      required int studentId,
      required String kind,
      required String title,
      required String body,
      required DateTime date,
      Value<bool> read,
    });
typedef $$StudentNoticesTableUpdateCompanionBuilder =
    StudentNoticesCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<String> kind,
      Value<String> title,
      Value<String> body,
      Value<DateTime> date,
      Value<bool> read,
    });

class $$StudentNoticesTableFilterComposer
    extends Composer<_$StudentDatabase, $StudentNoticesTable> {
  $$StudentNoticesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentNoticesTableOrderingComposer
    extends Composer<_$StudentDatabase, $StudentNoticesTable> {
  $$StudentNoticesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentNoticesTableAnnotationComposer
    extends Composer<_$StudentDatabase, $StudentNoticesTable> {
  $$StudentNoticesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);
}

class $$StudentNoticesTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $StudentNoticesTable,
          StudentNotice,
          $$StudentNoticesTableFilterComposer,
          $$StudentNoticesTableOrderingComposer,
          $$StudentNoticesTableAnnotationComposer,
          $$StudentNoticesTableCreateCompanionBuilder,
          $$StudentNoticesTableUpdateCompanionBuilder,
          (
            StudentNotice,
            BaseReferences<
              _$StudentDatabase,
              $StudentNoticesTable,
              StudentNotice
            >,
          ),
          StudentNotice,
          PrefetchHooks Function()
        > {
  $$StudentNoticesTableTableManager(
    _$StudentDatabase db,
    $StudentNoticesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentNoticesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentNoticesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentNoticesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> read = const Value.absent(),
              }) => StudentNoticesCompanion(
                id: id,
                studentId: studentId,
                kind: kind,
                title: title,
                body: body,
                date: date,
                read: read,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required String kind,
                required String title,
                required String body,
                required DateTime date,
                Value<bool> read = const Value.absent(),
              }) => StudentNoticesCompanion.insert(
                id: id,
                studentId: studentId,
                kind: kind,
                title: title,
                body: body,
                date: date,
                read: read,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentNoticesTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $StudentNoticesTable,
      StudentNotice,
      $$StudentNoticesTableFilterComposer,
      $$StudentNoticesTableOrderingComposer,
      $$StudentNoticesTableAnnotationComposer,
      $$StudentNoticesTableCreateCompanionBuilder,
      $$StudentNoticesTableUpdateCompanionBuilder,
      (
        StudentNotice,
        BaseReferences<_$StudentDatabase, $StudentNoticesTable, StudentNotice>,
      ),
      StudentNotice,
      PrefetchHooks Function()
    >;
typedef $$TeamTypesTableCreateCompanionBuilder =
    TeamTypesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> note,
    });
typedef $$TeamTypesTableUpdateCompanionBuilder =
    TeamTypesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> note,
    });

class $$TeamTypesTableFilterComposer
    extends Composer<_$StudentDatabase, $TeamTypesTable> {
  $$TeamTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamTypesTableOrderingComposer
    extends Composer<_$StudentDatabase, $TeamTypesTable> {
  $$TeamTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamTypesTableAnnotationComposer
    extends Composer<_$StudentDatabase, $TeamTypesTable> {
  $$TeamTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$TeamTypesTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $TeamTypesTable,
          TeamType,
          $$TeamTypesTableFilterComposer,
          $$TeamTypesTableOrderingComposer,
          $$TeamTypesTableAnnotationComposer,
          $$TeamTypesTableCreateCompanionBuilder,
          $$TeamTypesTableUpdateCompanionBuilder,
          (
            TeamType,
            BaseReferences<_$StudentDatabase, $TeamTypesTable, TeamType>,
          ),
          TeamType,
          PrefetchHooks Function()
        > {
  $$TeamTypesTableTableManager(_$StudentDatabase db, $TeamTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => TeamTypesCompanion(id: id, name: name, note: note),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> note = const Value.absent(),
              }) => TeamTypesCompanion.insert(id: id, name: name, note: note),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $TeamTypesTable,
      TeamType,
      $$TeamTypesTableFilterComposer,
      $$TeamTypesTableOrderingComposer,
      $$TeamTypesTableAnnotationComposer,
      $$TeamTypesTableCreateCompanionBuilder,
      $$TeamTypesTableUpdateCompanionBuilder,
      (TeamType, BaseReferences<_$StudentDatabase, $TeamTypesTable, TeamType>),
      TeamType,
      PrefetchHooks Function()
    >;
typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> book,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> book,
    });

class $$SubjectsTableFilterComposer
    extends Composer<_$StudentDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$StudentDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get book => $composableBuilder(
    column: $table.book,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get book =>
      $composableBuilder(column: $table.book, builder: (column) => column);
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, BaseReferences<_$StudentDatabase, $SubjectsTable, Subject>),
          Subject,
          PrefetchHooks Function()
        > {
  $$SubjectsTableTableManager(_$StudentDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> book = const Value.absent(),
              }) => SubjectsCompanion(id: id, name: name, book: book),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> book = const Value.absent(),
              }) => SubjectsCompanion.insert(id: id, name: name, book: book),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, BaseReferences<_$StudentDatabase, $SubjectsTable, Subject>),
      Subject,
      PrefetchHooks Function()
    >;
typedef $$DistributablesTableCreateCompanionBuilder =
    DistributablesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> note,
      Value<bool> active,
    });
typedef $$DistributablesTableUpdateCompanionBuilder =
    DistributablesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> note,
      Value<bool> active,
    });

class $$DistributablesTableFilterComposer
    extends Composer<_$StudentDatabase, $DistributablesTable> {
  $$DistributablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DistributablesTableOrderingComposer
    extends Composer<_$StudentDatabase, $DistributablesTable> {
  $$DistributablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DistributablesTableAnnotationComposer
    extends Composer<_$StudentDatabase, $DistributablesTable> {
  $$DistributablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$DistributablesTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $DistributablesTable,
          Distributable,
          $$DistributablesTableFilterComposer,
          $$DistributablesTableOrderingComposer,
          $$DistributablesTableAnnotationComposer,
          $$DistributablesTableCreateCompanionBuilder,
          $$DistributablesTableUpdateCompanionBuilder,
          (
            Distributable,
            BaseReferences<
              _$StudentDatabase,
              $DistributablesTable,
              Distributable
            >,
          ),
          Distributable,
          PrefetchHooks Function()
        > {
  $$DistributablesTableTableManager(
    _$StudentDatabase db,
    $DistributablesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DistributablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DistributablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DistributablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => DistributablesCompanion(
                id: id,
                name: name,
                note: note,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> note = const Value.absent(),
                Value<bool> active = const Value.absent(),
              }) => DistributablesCompanion.insert(
                id: id,
                name: name,
                note: note,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DistributablesTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $DistributablesTable,
      Distributable,
      $$DistributablesTableFilterComposer,
      $$DistributablesTableOrderingComposer,
      $$DistributablesTableAnnotationComposer,
      $$DistributablesTableCreateCompanionBuilder,
      $$DistributablesTableUpdateCompanionBuilder,
      (
        Distributable,
        BaseReferences<_$StudentDatabase, $DistributablesTable, Distributable>,
      ),
      Distributable,
      PrefetchHooks Function()
    >;
typedef $$DistributionsTableCreateCompanionBuilder =
    DistributionsCompanion Function({
      Value<int> id,
      required int studentId,
      required int distributableId,
      Value<int> count,
      required DateTime date,
    });
typedef $$DistributionsTableUpdateCompanionBuilder =
    DistributionsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> distributableId,
      Value<int> count,
      Value<DateTime> date,
    });

class $$DistributionsTableFilterComposer
    extends Composer<_$StudentDatabase, $DistributionsTable> {
  $$DistributionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distributableId => $composableBuilder(
    column: $table.distributableId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DistributionsTableOrderingComposer
    extends Composer<_$StudentDatabase, $DistributionsTable> {
  $$DistributionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distributableId => $composableBuilder(
    column: $table.distributableId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DistributionsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $DistributionsTable> {
  $$DistributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get distributableId => $composableBuilder(
    column: $table.distributableId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);
}

class $$DistributionsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $DistributionsTable,
          Distribution,
          $$DistributionsTableFilterComposer,
          $$DistributionsTableOrderingComposer,
          $$DistributionsTableAnnotationComposer,
          $$DistributionsTableCreateCompanionBuilder,
          $$DistributionsTableUpdateCompanionBuilder,
          (
            Distribution,
            BaseReferences<
              _$StudentDatabase,
              $DistributionsTable,
              Distribution
            >,
          ),
          Distribution,
          PrefetchHooks Function()
        > {
  $$DistributionsTableTableManager(
    _$StudentDatabase db,
    $DistributionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DistributionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DistributionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DistributionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> distributableId = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
              }) => DistributionsCompanion(
                id: id,
                studentId: studentId,
                distributableId: distributableId,
                count: count,
                date: date,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int distributableId,
                Value<int> count = const Value.absent(),
                required DateTime date,
              }) => DistributionsCompanion.insert(
                id: id,
                studentId: studentId,
                distributableId: distributableId,
                count: count,
                date: date,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DistributionsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $DistributionsTable,
      Distribution,
      $$DistributionsTableFilterComposer,
      $$DistributionsTableOrderingComposer,
      $$DistributionsTableAnnotationComposer,
      $$DistributionsTableCreateCompanionBuilder,
      $$DistributionsTableUpdateCompanionBuilder,
      (
        Distribution,
        BaseReferences<_$StudentDatabase, $DistributionsTable, Distribution>,
      ),
      Distribution,
      PrefetchHooks Function()
    >;
typedef $$ChangeRequestsTableCreateCompanionBuilder =
    ChangeRequestsCompanion Function({
      Value<int> id,
      required int studentId,
      required String field,
      Value<String?> currentValue,
      required String requestedValue,
      Value<String> status,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime?> reviewedAt,
    });
typedef $$ChangeRequestsTableUpdateCompanionBuilder =
    ChangeRequestsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<String> field,
      Value<String?> currentValue,
      Value<String> requestedValue,
      Value<String> status,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime?> reviewedAt,
    });

class $$ChangeRequestsTableFilterComposer
    extends Composer<_$StudentDatabase, $ChangeRequestsTable> {
  $$ChangeRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedValue => $composableBuilder(
    column: $table.requestedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChangeRequestsTableOrderingComposer
    extends Composer<_$StudentDatabase, $ChangeRequestsTable> {
  $$ChangeRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedValue => $composableBuilder(
    column: $table.requestedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChangeRequestsTableAnnotationComposer
    extends Composer<_$StudentDatabase, $ChangeRequestsTable> {
  $$ChangeRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get requestedValue => $composableBuilder(
    column: $table.requestedValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );
}

class $$ChangeRequestsTableTableManager
    extends
        RootTableManager<
          _$StudentDatabase,
          $ChangeRequestsTable,
          ChangeRequest,
          $$ChangeRequestsTableFilterComposer,
          $$ChangeRequestsTableOrderingComposer,
          $$ChangeRequestsTableAnnotationComposer,
          $$ChangeRequestsTableCreateCompanionBuilder,
          $$ChangeRequestsTableUpdateCompanionBuilder,
          (
            ChangeRequest,
            BaseReferences<
              _$StudentDatabase,
              $ChangeRequestsTable,
              ChangeRequest
            >,
          ),
          ChangeRequest,
          PrefetchHooks Function()
        > {
  $$ChangeRequestsTableTableManager(
    _$StudentDatabase db,
    $ChangeRequestsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangeRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChangeRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChangeRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> currentValue = const Value.absent(),
                Value<String> requestedValue = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
              }) => ChangeRequestsCompanion(
                id: id,
                studentId: studentId,
                field: field,
                currentValue: currentValue,
                requestedValue: requestedValue,
                status: status,
                note: note,
                createdAt: createdAt,
                reviewedAt: reviewedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required String field,
                Value<String?> currentValue = const Value.absent(),
                required String requestedValue,
                Value<String> status = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> reviewedAt = const Value.absent(),
              }) => ChangeRequestsCompanion.insert(
                id: id,
                studentId: studentId,
                field: field,
                currentValue: currentValue,
                requestedValue: requestedValue,
                status: status,
                note: note,
                createdAt: createdAt,
                reviewedAt: reviewedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChangeRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$StudentDatabase,
      $ChangeRequestsTable,
      ChangeRequest,
      $$ChangeRequestsTableFilterComposer,
      $$ChangeRequestsTableOrderingComposer,
      $$ChangeRequestsTableAnnotationComposer,
      $$ChangeRequestsTableCreateCompanionBuilder,
      $$ChangeRequestsTableUpdateCompanionBuilder,
      (
        ChangeRequest,
        BaseReferences<_$StudentDatabase, $ChangeRequestsTable, ChangeRequest>,
      ),
      ChangeRequest,
      PrefetchHooks Function()
    >;

class $StudentDatabaseManager {
  final _$StudentDatabase _db;
  $StudentDatabaseManager(this._db);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db, _db.attendances);
  $$MemorizationsTableTableManager get memorizations =>
      $$MemorizationsTableTableManager(_db, _db.memorizations);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CertificatesTableTableManager get certificates =>
      $$CertificatesTableTableManager(_db, _db.certificates);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db, _db.exams);
  $$ExamSubmissionsTableTableManager get examSubmissions =>
      $$ExamSubmissionsTableTableManager(_db, _db.examSubmissions);
  $$TeamsTableTableManager get teams =>
      $$TeamsTableTableManager(_db, _db.teams);
  $$StudentTeamsTableTableManager get studentTeams =>
      $$StudentTeamsTableTableManager(_db, _db.studentTeams);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$PhonesTableTableManager get phones =>
      $$PhonesTableTableManager(_db, _db.phones);
  $$MatnsTableTableManager get matns =>
      $$MatnsTableTableManager(_db, _db.matns);
  $$MatnRecitationsTableTableManager get matnRecitations =>
      $$MatnRecitationsTableTableManager(_db, _db.matnRecitations);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$StudentNoticesTableTableManager get studentNotices =>
      $$StudentNoticesTableTableManager(_db, _db.studentNotices);
  $$TeamTypesTableTableManager get teamTypes =>
      $$TeamTypesTableTableManager(_db, _db.teamTypes);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$DistributablesTableTableManager get distributables =>
      $$DistributablesTableTableManager(_db, _db.distributables);
  $$DistributionsTableTableManager get distributions =>
      $$DistributionsTableTableManager(_db, _db.distributions);
  $$ChangeRequestsTableTableManager get changeRequests =>
      $$ChangeRequestsTableTableManager(_db, _db.changeRequests);
}
