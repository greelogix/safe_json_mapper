import 'package:safe_json_mapper/safe_json_mapper.dart';

part 'models.g.dart';

@SafeJson()
class User with $UserEqualityMixin {
  @SafeField(required: true)
  final int id;

  @SafeField(name: 'full_name')
  final String? name;

  final String? gender;

  @SafeBool(fromInt: true)
  final bool isActive;

  final Profile? profile;

  @SafeNum()
  final double rating;

  final List<String> tags;

  final List<Post> posts;

  User({
    required this.id,
    this.name,
    this.gender,
    required this.isActive,
    this.profile,
    required this.rating,
    required this.tags,
    required this.posts,
  });
}

@SafeJson()
class Profile with $ProfileEqualityMixin {
  @SafeField(required: true, defaultValue: 18)
  final int age;

  final String? bio;

  @SafeNum(defaultValue: 0)
  final num score;

  Profile({
    required this.age,
    this.bio,
    required this.score,
  });
}

@SafeJson()
class Post with $PostEqualityMixin {
  final String title;

  @SafeField(defaultValue: 'No content available')
  final String content;

  Post({
    required this.title,
    required this.content,
  });
}

@SafeJson()
class ApiResponse with $ApiResponseEqualityMixin {
  final bool success;
  final String message;
  final User? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });
}

// Function to initialize all models
void initModels() {
  registerUser();
  registerProfile();
  registerPost();
  registerApiResponse();
}
