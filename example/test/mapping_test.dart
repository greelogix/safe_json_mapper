import 'package:flutter_test/flutter_test.dart';
import 'package:safe_json_mapper/safe_json_mapper.dart';
import 'package:safe_json_mapper_example/models.dart';

void main() {
  // Initialize models once for all tests
  setUpAll(() {
    initModels();
  });

  group('Generated Model Mapping Tests', () {
    test('User - Optimal JSON mapping', () {
      final json = {
        "id": 1,
        "full_name": "John Doe",
        "gender": "male",
        "isActive": true,
        "rating": 4.5,
        "tags": ["flutter", "dart"],
        "posts": [
          {"title": "Post 1", "content": "Content 1"}
        ],
        "profile": {"age": 25, "score": 100}
      };

      final user = SafeJsonMapper.fromJson<User>(json);

      expect(user.id, 1);
      expect(user.name, "John Doe");
      expect(user.isActive, isTrue);
      expect(user.rating, 4.5);
      expect(user.tags, containsAll(["flutter", "dart"]));
      expect(user.posts.length, 1);
      expect(user.posts.first.title, "Post 1");
      expect(user.profile?.age, 25);
    });

    test('User - Type Drift mapping', () {
      final json = {
        "id": "123", // String to int
        "isActive": 1, // int to bool
        "rating": "4.8", // String to double
        "tags": ["a", 1, true], // Mixed types in List
        "profile": "invalid", // Invalid object
      };

      final user = SafeJsonMapper.fromJson<User>(json);

      expect(user.id, 123);
      expect(user.isActive, isTrue);
      expect(user.rating, 4.8);
      expect(user.tags, ["a", "1", "true"]); // All converted to String
      expect(user.profile, isNull); // Falls back to null because it's nullable
    });

    test('User - Missing Required Fields (Policy: Log & Default)', () {
      SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.logAndDefault;
      final json = <String, dynamic>{}; // Empty JSON

      final user = SafeJsonMapper.fromJson<User>(json);

      expect(user.id, 0); // Default fallback for int
      expect(user.isActive, isFalse); // Default fallback for bool
      expect(user.rating, 0.0); // Default fallback for double
      expect(user.tags, isEmpty);
      expect(user.posts, isEmpty);
    });

    test('User - Missing Required Fields (Policy: Throw)', () {
      SafeJsonMapper.errorPolicy = SafeJsonModelErrorPolicy.throwError;
      final json = <String, dynamic>{};

      expect(() => SafeJsonMapper.fromJson<User>(json), throwsException);
    });

    test('ApiResponse - Wrapper mapping', () {
      final json = {
        "success": true,
        "message": "Loaded",
        "data": {
          "id": 1,
          "isActive": true,
          "rating": 5.0,
          "tags": [],
          "posts": []
        }
      };

      final response = SafeJsonMapper.fromJson<ApiResponse>(json);

      expect(response.success, isTrue);
      expect(response.message, "Loaded");
      expect(response.data?.id, 1);
    });

    test('Post - Default Values', () {
      final json = {
        "title": "Minimal Post"
        // content is missing
      };

      final post = SafeJsonMapper.fromJson<Post>(json);

      expect(post.title, "Minimal Post");
      expect(post.content,
          "No content available"); // From @SafeJsonField(defaultValue)
    });
  });
}
