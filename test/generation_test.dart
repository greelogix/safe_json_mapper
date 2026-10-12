import 'package:safe_json_mapper/safe_json_mapper.dart';
import 'package:test/test.dart';
import 'fixtures/models.dart';

void main() {
  setUp(() {
    registerAccount();
    registerDetail();
    registerWideModel();
    SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.silent;
    SafeJsonMapper.clearDrifts();
  });

  test(
    'generated provider converts fields, aliases, paths and nested models',
    () {
      final account = SafeJsonMapper.fromJson<Account>({
        'id': '42',
        'name': 'Bilal',
        'enabled': 1,
        'scores': ['1', 2.8],
        'ratings': {'service': '4.5'},
        'status': 'ACTIVE',
        'created': '2026-01-01T00:00:00Z',
        'detail': <String, dynamic>{},
        'address': {'city': 'Lahore'},
      });
      expect(account.id, 42);
      expect(account.name, 'Bilal');
      expect(account.enabled, isTrue);
      expect(account.scores, [1, 2]);
      expect(account.ratings, {'service': 4.5});
      expect(account.status, Status.active);
      expect(account.created, DateTime.utc(2026));
      expect(account.detail?.title, 'Unknown');
      expect(account.city, 'Lahore');
      expect(account.label, '42: Bilal');
      final json = account.toJson();
      expect(json['full_name'], 'Bilal');
      expect(json['detail'], {'title': 'Unknown'});
      expect(json['status'], 'active');
      expect(json.containsKey('label'), isFalse);
      expect(json.containsKey('category'), isFalse);
    },
  );

  test(
    'generated extensions preserve fields and compare collection contents',
    () {
      final account = SafeJsonMapper.fromJson<Account>({'id': 1});
      final copy = account.copyWith(name: 'Greelogix');
      expect(copy.id, 1);
      expect(copy.name, 'Greelogix');
      expect(account.isEqual(account.copyWith()), isTrue);
      expect(account.computeHashCode(), account.copyWith().computeHashCode());
      expect(account.toDebugString(), contains('Account('));
      final detail = Detail(title: 'Title');
      expect(detail.computeHashCode(), detail.copyWith().computeHashCode());
    },
  );

  test('hash computation supports more than 20 fields', () {
    final model = SafeJsonMapper.fromJson<WideModel>({});
    expect(model.computeHashCode(), model.copyWith().computeHashCode());
  });

  test('generated provider enforces required fields under throw policy', () {
    SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.throwError;
    expect(
      () => SafeJsonMapper.fromJson<Account>({}),
      throwsA(isA<SafeJsonMappingException>()),
    );
  });
}
