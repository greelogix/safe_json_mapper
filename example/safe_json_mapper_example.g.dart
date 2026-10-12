// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safe_json_mapper_example.dart';

// **************************************************************************
// SafeJsonModelGenerator
// **************************************************************************

class _$CustomerSafeProvider implements SafeJsonModelProvider<Customer> {
  @override
  Customer fromJson(Map<String, dynamic> json) {
    return Customer(
      id: SafeJsonMapper.checkRequired(
        SafeJsonMapper.toInt(json['id'], 'id', isRequired: true),
        'id',
        'Customer',
        0,
      ),
      name:
          (SafeJsonMapper.asString(
            json['full_name'],
            'name',
            isRequired: false,
          ) ??
          ''),
      active:
          (SafeJsonMapper.toBool(
            json['active'],
            'active',
            fromInt: true,
            isRequired: false,
          ) ??
          false),
    );
  }

  @override
  Map<String, dynamic> toJson(Customer instance) {
    final result = <String, dynamic>{};
    result['id'] = SafeJsonMapper.serializeValue(instance.id);
    result['full_name'] = SafeJsonMapper.serializeValue(instance.name);
    result['active'] = SafeJsonMapper.serializeValue(instance.active);
    return result;
  }
}

extension $CustomerSafeJsonExtension on Customer {
  Customer copyWith({int? id, String? name, bool? active}) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() {
    return SafeJsonMapper.toJson<Customer>(this);
  }

  bool isEqual(Object? other) {
    if (identical(this, other)) return true;
    if (other is! Customer) return false;
    if (!SafeJsonMapper.deepEquals(id, other.id)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(name, other.name)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(active, other.active)) {
      return false;
    }
    return true;
  }

  int computeHashCode() {
    return Object.hashAll([
      SafeJsonMapper.deepHash(id),
      SafeJsonMapper.deepHash(name),
      SafeJsonMapper.deepHash(active),
    ]);
  }

  String toDebugString() {
    final buffer = StringBuffer('Customer(');
    buffer.write('id: $id');
    buffer.write(', ');
    buffer.write('name: $name');
    buffer.write(', ');
    buffer.write('active: $active');
    buffer.write(')');
    return buffer.toString();
  }
}

void registerCustomer() {
  SafeJsonMapper.register<Customer>(_$CustomerSafeProvider());
}
