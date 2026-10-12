import 'package:safe_json_mapper/safe_json_mapper.dart';

part 'models.g.dart';

enum Status { active, inactive }

@SafeJson()
class Account {
  @SafeField(required: true)
  final int id;
  @SafeField(name: 'full_name', aliases: ['name'])
  final String? name;
  @SafeBool()
  final bool enabled;
  final List<int> scores;
  final Map<String, double> ratings;
  final Status? status;
  final DateTime? created;
  final Detail? detail;
  @SafeField(path: 'address.city')
  final String? city;

  String get label => '$id: $name';
  static const category = 'account';

  Account({
    required this.id,
    this.name,
    required this.enabled,
    required this.scores,
    required this.ratings,
    required this.status,
    this.created,
    this.detail,
    this.city,
  });
}

@SafeJson()
class Detail {
  @SafeDefault('Unknown')
  final String title;
  Detail({required this.title});
}

@SafeJson()
class WideModel {
  final int field0;
  final int field1;
  final int field2;
  final int field3;
  final int field4;
  final int field5;
  final int field6;
  final int field7;
  final int field8;
  final int field9;
  final int field10;
  final int field11;
  final int field12;
  final int field13;
  final int field14;
  final int field15;
  final int field16;
  final int field17;
  final int field18;
  final int field19;
  final int field20;
  WideModel({
    required this.field0,
    required this.field1,
    required this.field2,
    required this.field3,
    required this.field4,
    required this.field5,
    required this.field6,
    required this.field7,
    required this.field8,
    required this.field9,
    required this.field10,
    required this.field11,
    required this.field12,
    required this.field13,
    required this.field14,
    required this.field15,
    required this.field16,
    required this.field17,
    required this.field18,
    required this.field19,
    required this.field20,
  });
}
