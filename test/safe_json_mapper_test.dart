import 'package:test/test.dart';
import 'package:safe_json_mapper/safe_json_mapper.dart';

void main() {
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
  });

  group('SafeJsonMapper Error Policies', () {
    test('checkRequired - throwError policy', () {
      SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.throwError;
      expect(
        () => SafeJsonMapper.checkRequired(null, 'id', 'User', 0),
        throwsException,
      );
      expect(SafeJsonMapper.checkRequired(1, 'id', 'User', 0), 1);
    });

    test('checkRequired - logAndDefault policy', () {
      SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.logAndDefault;
      // Should not throw, should return fallback
      expect(SafeJsonMapper.checkRequired(null, 'id', 'User', 99), 99);
    });

    test('checkRequired - silent policy', () {
      SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.silent;
      expect(SafeJsonMapper.checkRequired(null, 'id', 'User', 99), 99);
    });
  });
}
