// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// SafeJsonModelGenerator
// **************************************************************************

class _$AccountSafeProvider implements SafeJsonModelProvider<Account> {
  @override
  Account fromJson(Map<String, dynamic> json) {
    return Account(
      id: SafeJsonMapper.checkRequired(
        SafeJsonMapper.toInt(json['id'], 'id', isRequired: true),
        'id',
        'Account',
        0,
      ),
      name: SafeJsonMapper.asString(
        json['full_name'] ?? json['name'],
        'name',
        isRequired: false,
      ),
      enabled:
          (SafeJsonMapper.toBool(
            json['enabled'],
            'enabled',
            fromInt: true,
            isRequired: false,
          ) ??
          false),
      scores: SafeJsonMapper.toIntList(json['scores'], 'scores') ?? [],
      ratings: SafeJsonMapper.toDoubleMap(json['ratings'], 'ratings') ?? {},
      status: SafeJsonMapper.toEnum<Status>(
        json['status'],
        'status',
        Status.values,
        isRequired: false,
      ),
      created: SafeJsonMapper.toDateTime(
        json['created'],
        'created',
        isRequired: false,
      ),
      detail: (json['detail'] is Map)
          ? SafeJsonMapper.fromJson<Detail>(json['detail'])
          : null,
      city: SafeJsonMapper.asString(
        SafeJsonMapper.getNestedValue(json, 'address.city'),
        'city',
        isRequired: false,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson(Account instance) {
    final result = <String, dynamic>{};
    result['id'] = SafeJsonMapper.serializeValue(instance.id);
    result['full_name'] = SafeJsonMapper.serializeValue(instance.name);
    result['enabled'] = SafeJsonMapper.serializeValue(instance.enabled);
    result['scores'] = SafeJsonMapper.serializeValue(instance.scores);
    result['ratings'] = SafeJsonMapper.serializeValue(instance.ratings);
    result['status'] = SafeJsonMapper.serializeValue(instance.status);
    result['created'] = SafeJsonMapper.serializeValue(instance.created);
    result['detail'] = SafeJsonMapper.serializeValue(instance.detail);
    result['city'] = SafeJsonMapper.serializeValue(instance.city);
    return result;
  }
}

extension $AccountSafeJsonExtension on Account {
  Account copyWith({
    int? id,
    String? name,
    bool? enabled,
    List<int>? scores,
    Map<String, double>? ratings,
    Status? status,
    DateTime? created,
    Detail? detail,
    String? city,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      enabled: enabled ?? this.enabled,
      scores: scores ?? this.scores,
      ratings: ratings ?? this.ratings,
      status: status ?? this.status,
      created: created ?? this.created,
      detail: detail ?? this.detail,
      city: city ?? this.city,
    );
  }

  Map<String, dynamic> toJson() {
    return SafeJsonMapper.toJson<Account>(this);
  }

  bool isEqual(Object? other) {
    if (identical(this, other)) return true;
    if (other is! Account) return false;
    if (!SafeJsonMapper.deepEquals(id, other.id)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(name, other.name)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(enabled, other.enabled)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(scores, other.scores)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(ratings, other.ratings)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(status, other.status)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(created, other.created)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(detail, other.detail)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(city, other.city)) {
      return false;
    }
    return true;
  }

  int computeHashCode() {
    return Object.hashAll([
      SafeJsonMapper.deepHash(id),
      SafeJsonMapper.deepHash(name),
      SafeJsonMapper.deepHash(enabled),
      SafeJsonMapper.deepHash(scores),
      SafeJsonMapper.deepHash(ratings),
      SafeJsonMapper.deepHash(status),
      SafeJsonMapper.deepHash(created),
      SafeJsonMapper.deepHash(detail),
      SafeJsonMapper.deepHash(city),
    ]);
  }

  String toDebugString() {
    final buffer = StringBuffer('Account(');
    buffer.write('id: $id');
    buffer.write(', ');
    buffer.write('name: $name');
    buffer.write(', ');
    buffer.write('enabled: $enabled');
    buffer.write(', ');
    buffer.write('scores: $scores');
    buffer.write(', ');
    buffer.write('ratings: $ratings');
    buffer.write(', ');
    buffer.write('status: $status');
    buffer.write(', ');
    buffer.write('created: $created');
    buffer.write(', ');
    buffer.write('detail: $detail');
    buffer.write(', ');
    buffer.write('city: $city');
    buffer.write(')');
    return buffer.toString();
  }
}

void registerAccount() {
  SafeJsonMapper.register<Account>(_$AccountSafeProvider());
}

class _$DetailSafeProvider implements SafeJsonModelProvider<Detail> {
  @override
  Detail fromJson(Map<String, dynamic> json) {
    return Detail(
      title:
          (SafeJsonMapper.asString(json['title'], 'title', isRequired: false) ??
          'Unknown'),
    );
  }

  @override
  Map<String, dynamic> toJson(Detail instance) {
    final result = <String, dynamic>{};
    result['title'] = SafeJsonMapper.serializeValue(instance.title);
    return result;
  }
}

extension $DetailSafeJsonExtension on Detail {
  Detail copyWith({String? title}) {
    return Detail(title: title ?? this.title);
  }

  Map<String, dynamic> toJson() {
    return SafeJsonMapper.toJson<Detail>(this);
  }

  bool isEqual(Object? other) {
    if (identical(this, other)) return true;
    if (other is! Detail) return false;
    if (!SafeJsonMapper.deepEquals(title, other.title)) {
      return false;
    }
    return true;
  }

  int computeHashCode() {
    return Object.hashAll([SafeJsonMapper.deepHash(title)]);
  }

  String toDebugString() {
    final buffer = StringBuffer('Detail(');
    buffer.write('title: $title');
    buffer.write(')');
    return buffer.toString();
  }
}

void registerDetail() {
  SafeJsonMapper.register<Detail>(_$DetailSafeProvider());
}

class _$WideModelSafeProvider implements SafeJsonModelProvider<WideModel> {
  @override
  WideModel fromJson(Map<String, dynamic> json) {
    return WideModel(
      field0:
          (SafeJsonMapper.toInt(json['field0'], 'field0', isRequired: false) ??
          0),
      field1:
          (SafeJsonMapper.toInt(json['field1'], 'field1', isRequired: false) ??
          0),
      field2:
          (SafeJsonMapper.toInt(json['field2'], 'field2', isRequired: false) ??
          0),
      field3:
          (SafeJsonMapper.toInt(json['field3'], 'field3', isRequired: false) ??
          0),
      field4:
          (SafeJsonMapper.toInt(json['field4'], 'field4', isRequired: false) ??
          0),
      field5:
          (SafeJsonMapper.toInt(json['field5'], 'field5', isRequired: false) ??
          0),
      field6:
          (SafeJsonMapper.toInt(json['field6'], 'field6', isRequired: false) ??
          0),
      field7:
          (SafeJsonMapper.toInt(json['field7'], 'field7', isRequired: false) ??
          0),
      field8:
          (SafeJsonMapper.toInt(json['field8'], 'field8', isRequired: false) ??
          0),
      field9:
          (SafeJsonMapper.toInt(json['field9'], 'field9', isRequired: false) ??
          0),
      field10:
          (SafeJsonMapper.toInt(
            json['field10'],
            'field10',
            isRequired: false,
          ) ??
          0),
      field11:
          (SafeJsonMapper.toInt(
            json['field11'],
            'field11',
            isRequired: false,
          ) ??
          0),
      field12:
          (SafeJsonMapper.toInt(
            json['field12'],
            'field12',
            isRequired: false,
          ) ??
          0),
      field13:
          (SafeJsonMapper.toInt(
            json['field13'],
            'field13',
            isRequired: false,
          ) ??
          0),
      field14:
          (SafeJsonMapper.toInt(
            json['field14'],
            'field14',
            isRequired: false,
          ) ??
          0),
      field15:
          (SafeJsonMapper.toInt(
            json['field15'],
            'field15',
            isRequired: false,
          ) ??
          0),
      field16:
          (SafeJsonMapper.toInt(
            json['field16'],
            'field16',
            isRequired: false,
          ) ??
          0),
      field17:
          (SafeJsonMapper.toInt(
            json['field17'],
            'field17',
            isRequired: false,
          ) ??
          0),
      field18:
          (SafeJsonMapper.toInt(
            json['field18'],
            'field18',
            isRequired: false,
          ) ??
          0),
      field19:
          (SafeJsonMapper.toInt(
            json['field19'],
            'field19',
            isRequired: false,
          ) ??
          0),
      field20:
          (SafeJsonMapper.toInt(
            json['field20'],
            'field20',
            isRequired: false,
          ) ??
          0),
    );
  }

  @override
  Map<String, dynamic> toJson(WideModel instance) {
    final result = <String, dynamic>{};
    result['field0'] = SafeJsonMapper.serializeValue(instance.field0);
    result['field1'] = SafeJsonMapper.serializeValue(instance.field1);
    result['field2'] = SafeJsonMapper.serializeValue(instance.field2);
    result['field3'] = SafeJsonMapper.serializeValue(instance.field3);
    result['field4'] = SafeJsonMapper.serializeValue(instance.field4);
    result['field5'] = SafeJsonMapper.serializeValue(instance.field5);
    result['field6'] = SafeJsonMapper.serializeValue(instance.field6);
    result['field7'] = SafeJsonMapper.serializeValue(instance.field7);
    result['field8'] = SafeJsonMapper.serializeValue(instance.field8);
    result['field9'] = SafeJsonMapper.serializeValue(instance.field9);
    result['field10'] = SafeJsonMapper.serializeValue(instance.field10);
    result['field11'] = SafeJsonMapper.serializeValue(instance.field11);
    result['field12'] = SafeJsonMapper.serializeValue(instance.field12);
    result['field13'] = SafeJsonMapper.serializeValue(instance.field13);
    result['field14'] = SafeJsonMapper.serializeValue(instance.field14);
    result['field15'] = SafeJsonMapper.serializeValue(instance.field15);
    result['field16'] = SafeJsonMapper.serializeValue(instance.field16);
    result['field17'] = SafeJsonMapper.serializeValue(instance.field17);
    result['field18'] = SafeJsonMapper.serializeValue(instance.field18);
    result['field19'] = SafeJsonMapper.serializeValue(instance.field19);
    result['field20'] = SafeJsonMapper.serializeValue(instance.field20);
    return result;
  }
}

extension $WideModelSafeJsonExtension on WideModel {
  WideModel copyWith({
    int? field0,
    int? field1,
    int? field2,
    int? field3,
    int? field4,
    int? field5,
    int? field6,
    int? field7,
    int? field8,
    int? field9,
    int? field10,
    int? field11,
    int? field12,
    int? field13,
    int? field14,
    int? field15,
    int? field16,
    int? field17,
    int? field18,
    int? field19,
    int? field20,
  }) {
    return WideModel(
      field0: field0 ?? this.field0,
      field1: field1 ?? this.field1,
      field2: field2 ?? this.field2,
      field3: field3 ?? this.field3,
      field4: field4 ?? this.field4,
      field5: field5 ?? this.field5,
      field6: field6 ?? this.field6,
      field7: field7 ?? this.field7,
      field8: field8 ?? this.field8,
      field9: field9 ?? this.field9,
      field10: field10 ?? this.field10,
      field11: field11 ?? this.field11,
      field12: field12 ?? this.field12,
      field13: field13 ?? this.field13,
      field14: field14 ?? this.field14,
      field15: field15 ?? this.field15,
      field16: field16 ?? this.field16,
      field17: field17 ?? this.field17,
      field18: field18 ?? this.field18,
      field19: field19 ?? this.field19,
      field20: field20 ?? this.field20,
    );
  }

  Map<String, dynamic> toJson() {
    return SafeJsonMapper.toJson<WideModel>(this);
  }

  bool isEqual(Object? other) {
    if (identical(this, other)) return true;
    if (other is! WideModel) return false;
    if (!SafeJsonMapper.deepEquals(field0, other.field0)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field1, other.field1)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field2, other.field2)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field3, other.field3)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field4, other.field4)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field5, other.field5)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field6, other.field6)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field7, other.field7)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field8, other.field8)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field9, other.field9)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field10, other.field10)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field11, other.field11)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field12, other.field12)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field13, other.field13)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field14, other.field14)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field15, other.field15)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field16, other.field16)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field17, other.field17)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field18, other.field18)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field19, other.field19)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(field20, other.field20)) {
      return false;
    }
    return true;
  }

  int computeHashCode() {
    return Object.hashAll([
      SafeJsonMapper.deepHash(field0),
      SafeJsonMapper.deepHash(field1),
      SafeJsonMapper.deepHash(field2),
      SafeJsonMapper.deepHash(field3),
      SafeJsonMapper.deepHash(field4),
      SafeJsonMapper.deepHash(field5),
      SafeJsonMapper.deepHash(field6),
      SafeJsonMapper.deepHash(field7),
      SafeJsonMapper.deepHash(field8),
      SafeJsonMapper.deepHash(field9),
      SafeJsonMapper.deepHash(field10),
      SafeJsonMapper.deepHash(field11),
      SafeJsonMapper.deepHash(field12),
      SafeJsonMapper.deepHash(field13),
      SafeJsonMapper.deepHash(field14),
      SafeJsonMapper.deepHash(field15),
      SafeJsonMapper.deepHash(field16),
      SafeJsonMapper.deepHash(field17),
      SafeJsonMapper.deepHash(field18),
      SafeJsonMapper.deepHash(field19),
      SafeJsonMapper.deepHash(field20),
    ]);
  }

  String toDebugString() {
    final buffer = StringBuffer('WideModel(');
    buffer.write('field0: $field0');
    buffer.write(', ');
    buffer.write('field1: $field1');
    buffer.write(', ');
    buffer.write('field2: $field2');
    buffer.write(', ');
    buffer.write('field3: $field3');
    buffer.write(', ');
    buffer.write('field4: $field4');
    buffer.write(', ');
    buffer.write('field5: $field5');
    buffer.write(', ');
    buffer.write('field6: $field6');
    buffer.write(', ');
    buffer.write('field7: $field7');
    buffer.write(', ');
    buffer.write('field8: $field8');
    buffer.write(', ');
    buffer.write('field9: $field9');
    buffer.write(', ');
    buffer.write('field10: $field10');
    buffer.write(', ');
    buffer.write('field11: $field11');
    buffer.write(', ');
    buffer.write('field12: $field12');
    buffer.write(', ');
    buffer.write('field13: $field13');
    buffer.write(', ');
    buffer.write('field14: $field14');
    buffer.write(', ');
    buffer.write('field15: $field15');
    buffer.write(', ');
    buffer.write('field16: $field16');
    buffer.write(', ');
    buffer.write('field17: $field17');
    buffer.write(', ');
    buffer.write('field18: $field18');
    buffer.write(', ');
    buffer.write('field19: $field19');
    buffer.write(', ');
    buffer.write('field20: $field20');
    buffer.write(')');
    return buffer.toString();
  }
}

void registerWideModel() {
  SafeJsonMapper.register<WideModel>(_$WideModelSafeProvider());
}
