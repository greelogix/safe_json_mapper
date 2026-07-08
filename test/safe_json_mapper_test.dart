import 'package:test/test.dart';
import 'package:safe_json_mapper/safe_json_mapper.dart';

enum TestStatus { active, inactive, pending }

void main() {
  setUp(() {
    // Clear drifts before each test
    SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.silent;
    SafeJsonMapper.clearDrifts();
  });

  group('SafeJsonMapper Type Conversions', () {
    test('toInt conversions', () {
      expect(SafeJsonMapper.toInt(123, 'test'), 123);
      expect(SafeJsonMapper.toInt('123', 'test'), 123);
      expect(SafeJsonMapper.toInt(123.45, 'test'), 123);
      expect(SafeJsonMapper.toInt('abc', 'test'), isNull);
      expect(SafeJsonMapper.toInt(null, 'test'), isNull);
    });

    test('toDouble conversions', () {
      expect(SafeJsonMapper.toDouble(123.45, 'test'), 123.45);
      expect(SafeJsonMapper.toDouble(123, 'test'), 123.0);
      expect(SafeJsonMapper.toDouble('123.45', 'test'), 123.45);
      expect(SafeJsonMapper.toDouble('abc', 'test'), isNull);
      expect(SafeJsonMapper.toDouble(null, 'test'), isNull);
    });

    test('toBool conversions', () {
      expect(SafeJsonMapper.toBool(true, 'test'), isTrue);
      expect(SafeJsonMapper.toBool(false, 'test'), isFalse);
      expect(SafeJsonMapper.toBool(1, 'test', fromInt: true), isTrue);
      expect(SafeJsonMapper.toBool(0, 'test', fromInt: true), isFalse);
      expect(SafeJsonMapper.toBool('1', 'test', fromInt: true), isTrue);
      expect(SafeJsonMapper.toBool('0', 'test', fromInt: true), isFalse);
      expect(SafeJsonMapper.toBool('true', 'test', fromInt: true), isTrue);
      expect(SafeJsonMapper.toBool('false', 'test', fromInt: true), isFalse);
      expect(SafeJsonMapper.toBool(null, 'test'), isNull);
    });

    test('asString conversions', () {
      expect(SafeJsonMapper.asString('hello', 'test'), 'hello');
      expect(SafeJsonMapper.asString(123, 'test'), '123');
      expect(SafeJsonMapper.asString(true, 'test'), 'true');
      expect(SafeJsonMapper.asString(null, 'test'), isNull);
    });

    test('toDateTime conversions from ISO string', () {
      final date = DateTime(2023, 10, 5, 14, 30);
      expect(SafeJsonMapper.toDateTime(date.toIso8601String(), 'test'), date);
      expect(SafeJsonMapper.toDateTime(null, 'test'), isNull);
    });

    test('toDateTime conversions from int (millis since epoch)', () {
      final date = DateTime(2023, 10, 5, 14, 30);
      expect(
          SafeJsonMapper.toDateTime(date.millisecondsSinceEpoch, 'test'), date);
    });

    test('toDateTime conversions from double (seconds since epoch)', () {
      final date = DateTime(2023, 10, 5, 14, 30, 123);
      final seconds = date.millisecondsSinceEpoch / 1000;
      expect(SafeJsonMapper.toDateTime(seconds, 'test'), date);
    });

    test('toEnum conversions from string', () {
      expect(
          SafeJsonMapper.toEnum<TestStatus>(
              'active', 'test', TestStatus.values),
          TestStatus.active);
      expect(
          SafeJsonMapper.toEnum<TestStatus>(
              'ACTIVE', 'test', TestStatus.values),
          TestStatus.active);
      expect(
          SafeJsonMapper.toEnum<TestStatus>(
              'inactive', 'test', TestStatus.values),
          TestStatus.inactive);
      expect(
          SafeJsonMapper.toEnum<TestStatus>(
              'pending', 'test', TestStatus.values),
          TestStatus.pending);
    });

    test('toEnum conversions from int', () {
      expect(SafeJsonMapper.toEnum<TestStatus>(0, 'test', TestStatus.values),
          TestStatus.active);
      expect(SafeJsonMapper.toEnum<TestStatus>(1, 'test', TestStatus.values),
          TestStatus.inactive);
      expect(SafeJsonMapper.toEnum<TestStatus>(2, 'test', TestStatus.values),
          TestStatus.pending);
    });

    test('toEnum with unknown value', () {
      expect(
          SafeJsonMapper.toEnum<TestStatus>(
              'unknown', 'test', TestStatus.values,
              unknownValue: TestStatus.pending),
          TestStatus.pending);
    });

    test('toIntList conversions', () {
      expect(SafeJsonMapper.toIntList([1, 2, 3], 'test'), [1, 2, 3]);
      expect(SafeJsonMapper.toIntList(['1', '2', '3'], 'test'), [1, 2, 3]);
      expect(SafeJsonMapper.toIntList([1.5, 2.0, 3.9], 'test'), [1, 2, 3]);
      expect(SafeJsonMapper.toIntList(null, 'test'), isNull);
    });

    test('toDoubleList conversions', () {
      expect(SafeJsonMapper.toDoubleList([1.1, 2.2, 3.3], 'test'),
          [1.1, 2.2, 3.3]);
      expect(SafeJsonMapper.toDoubleList([1, 2, 3], 'test'), [1.0, 2.0, 3.0]);
      expect(SafeJsonMapper.toDoubleList(['1.1', '2.2', '3.3'], 'test'),
          [1.1, 2.2, 3.3]);
    });

    test('toStringList conversions', () {
      expect(SafeJsonMapper.toStringList(['a', 'b', 'c'], 'test'),
          ['a', 'b', 'c']);
      expect(SafeJsonMapper.toStringList([1, true, 3.14], 'test'),
          ['1', 'true', '3.14']);
    });

    test('toDateTimeList conversions', () {
      final dates = [DateTime(2023, 1, 1), DateTime(2023, 12, 31)];
      final dateStrings = dates.map((d) => d.toIso8601String()).toList();
      expect(SafeJsonMapper.toDateTimeList(dateStrings, 'test'), dates);
    });

    test('toEnumList conversions', () {
      expect(
          SafeJsonMapper.toEnumList<TestStatus>(
              ['active', 'inactive'], 'test', TestStatus.values),
          [TestStatus.active, TestStatus.inactive]);
      expect(
          SafeJsonMapper.toEnumList<TestStatus>(
              [0, 1, 2], 'test', TestStatus.values),
          [TestStatus.active, TestStatus.inactive, TestStatus.pending]);
    });

    test('toIntMap conversions', () {
      expect(
          SafeJsonMapper.toIntMap({'a': 1, 'b': 2}, 'test'), {'a': 1, 'b': 2});
      expect(SafeJsonMapper.toIntMap({'a': '1', 'b': '2'}, 'test'),
          {'a': 1, 'b': 2});
    });

    test('toStringMap conversions', () {
      expect(SafeJsonMapper.toStringMap({'a': 'hello', 'b': 'world'}, 'test'),
          {'a': 'hello', 'b': 'world'});
      expect(SafeJsonMapper.toStringMap({'a': 123, 'b': true}, 'test'),
          {'a': '123', 'b': 'true'});
    });
  });

  group('SafeJsonMapper Error Policies', () {
    test('checkRequired - throwError policy', () {
      SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.throwError;
      expect(
        () => SafeJsonMapper.checkRequired(null, 'id', 'User', 0),
        throwsA(isA<SafeJsonMappingException>()),
      );
      expect(SafeJsonMapper.checkRequired(1, 'id', 'User', 0), 1);
    });

    test('checkRequired - logAndDefault policy', () {
      SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.logAndDefault;
      expect(SafeJsonMapper.checkRequired(null, 'id', 'User', 99), 99);
    });

    test('checkRequired - silent policy', () {
      SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.silent;
      expect(SafeJsonMapper.checkRequired(null, 'id', 'User', 99), 99);
    });

    test('lastDrifts returns drifts from last operation', () {
      SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.silent;
      SafeJsonMapper.toInt('invalid', 'test');
      expect(SafeJsonMapper.lastDrifts, hasLength(1));
      expect(SafeJsonMapper.lastDrifts.first.field, 'test');
    });
  });
}
