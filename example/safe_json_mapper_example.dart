// ignore_for_file: avoid_print

import 'package:safe_json_mapper/safe_json_mapper.dart';

part 'safe_json_mapper_example.g.dart';

@SafeJson()
class Customer {
  @SafeField(required: true)
  final int id;
  @SafeField(name: 'full_name')
  final String name;
  @SafeBool()
  final bool active;

  Customer({required this.id, required this.name, required this.active});
}

void main() {
  registerCustomer();
  final customer = SafeJsonMapper.fromJson<Customer>({
    'id': '42',
    'full_name': 'Greelogix',
    'active': 1,
  });
  print(customer.toDebugString());
  print(customer.copyWith(name: 'Bilal').toJson());
}
