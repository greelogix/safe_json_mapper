// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// SafeJsonModelGenerator
// **************************************************************************

class _$UserSafeProvider implements SafeJsonModelProvider<User> {
  @override
  User fromJson(Map<String, dynamic> json) {
    return User(
      id: SafeJsonMapper.checkRequired(
          SafeJsonMapper.toInt(json['id'], 'id', isRequired: true),
          'id',
          'User',
          0),
      name:
          SafeJsonMapper.asString(json['full_name'], 'name', isRequired: false),
      gender:
          SafeJsonMapper.asString(json['gender'], 'gender', isRequired: false),
      isActive: (SafeJsonMapper.toBool(json['isActive'], 'isActive',
              fromInt: true, isRequired: false) ??
          false),
      profile: (json['profile'] is Map)
          ? SafeJsonMapper.fromJson<Profile>(json['profile'])
          : null,
      rating: (SafeJsonMapper.toDouble(json['rating'], 'rating',
              isRequired: false) ??
          0.0),
      tags: (SafeJsonMapper.ensureList(json['tags'], 'tags'))
              ?.map((e) => SafeJsonMapper.asString(e, 'tags'))
              .whereType<String>()
              .toList() ??
          [],
      posts: (SafeJsonMapper.ensureList(json['posts'], 'posts'))
              ?.map((e) => (e is Map) ? SafeJsonMapper.fromJson<Post>(e) : null)
              .whereType<Post>()
              .toList() ??
          [],
    );
  }
}

void _registerUser() {
  SafeJsonMapper.register<User>(_$UserSafeProvider());
}

class _$ProfileSafeProvider implements SafeJsonModelProvider<Profile> {
  @override
  Profile fromJson(Map<String, dynamic> json) {
    return Profile(
      age: SafeJsonMapper.checkRequired(
          SafeJsonMapper.toInt(json['age'], 'age', isRequired: true),
          'age',
          'Profile',
          18),
      bio: SafeJsonMapper.asString(json['bio'], 'bio', isRequired: false),
      score: (SafeJsonMapper.toNum(json['score'], 'score', isRequired: false) ??
          0),
    );
  }
}

void _registerProfile() {
  SafeJsonMapper.register<Profile>(_$ProfileSafeProvider());
}

class _$PostSafeProvider implements SafeJsonModelProvider<Post> {
  @override
  Post fromJson(Map<String, dynamic> json) {
    return Post(
      title:
          (SafeJsonMapper.asString(json['title'], 'title', isRequired: false) ??
              ''),
      content: (SafeJsonMapper.asString(json['content'], 'content',
              isRequired: false) ??
          'No content available'),
    );
  }
}

void _registerPost() {
  SafeJsonMapper.register<Post>(_$PostSafeProvider());
}

class _$ApiResponseSafeProvider implements SafeJsonModelProvider<ApiResponse> {
  @override
  ApiResponse fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: (SafeJsonMapper.toBool(json['success'], 'success',
              fromInt: false, isRequired: false) ??
          false),
      message: (SafeJsonMapper.asString(json['message'], 'message',
              isRequired: false) ??
          ''),
      data: (json['data'] is Map)
          ? SafeJsonMapper.fromJson<User>(json['data'])
          : null,
    );
  }
}

void _registerApiResponse() {
  SafeJsonMapper.register<ApiResponse>(_$ApiResponseSafeProvider());
}
