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
      tags: SafeJsonMapper.toStringList(json['tags'], 'tags') ?? [],
      posts: SafeJsonMapper.toModelList<Post>(json['posts'], 'posts') ?? [],
    );
  }

  @override
  Map<String, dynamic> toJson(User instance) {
    final result = <String, dynamic>{};
    result['id'] = SafeJsonMapper.serializeValue(instance.id);
    result['full_name'] = SafeJsonMapper.serializeValue(instance.name);
    result['gender'] = SafeJsonMapper.serializeValue(instance.gender);
    result['isActive'] = SafeJsonMapper.serializeValue(instance.isActive);
    result['profile'] = SafeJsonMapper.serializeValue(instance.profile);
    result['rating'] = SafeJsonMapper.serializeValue(instance.rating);
    result['tags'] = SafeJsonMapper.serializeValue(instance.tags);
    result['posts'] = SafeJsonMapper.serializeValue(instance.posts);
    return result;
  }
}

mixin $UserEqualityMixin on User {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! User) return false;
    if (!SafeJsonMapper.deepEquals(id, other.id)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(name, other.name)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(gender, other.gender)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(isActive, other.isActive)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(profile, other.profile)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(rating, other.rating)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(tags, other.tags)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(posts, other.posts)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
        SafeJsonMapper.deepHash(id),
        SafeJsonMapper.deepHash(name),
        SafeJsonMapper.deepHash(gender),
        SafeJsonMapper.deepHash(isActive),
        SafeJsonMapper.deepHash(profile),
        SafeJsonMapper.deepHash(rating),
        SafeJsonMapper.deepHash(tags),
        SafeJsonMapper.deepHash(posts));
  }

  @override
  String toString() {
    final buffer = StringBuffer('User(');
    buffer.write('id: $id');
    buffer.write(', ');
    buffer.write('name: $name');
    buffer.write(', ');
    buffer.write('gender: $gender');
    buffer.write(', ');
    buffer.write('isActive: $isActive');
    buffer.write(', ');
    buffer.write('profile: $profile');
    buffer.write(', ');
    buffer.write('rating: $rating');
    buffer.write(', ');
    buffer.write('tags: $tags');
    buffer.write(', ');
    buffer.write('posts: $posts');
    buffer.write(')');
    return buffer.toString();
  }
}

extension $UserSafeJsonExtension on User {
  User copyWith({
    int? id,
    String? name,
    String? gender,
    bool? isActive,
    Profile? profile,
    double? rating,
    List<String>? tags,
    List<Post>? posts,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      isActive: isActive ?? this.isActive,
      profile: profile ?? this.profile,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      posts: posts ?? this.posts,
    );
  }

  Map<String, dynamic> toJson() {
    return SafeJsonMapper.toJson<User>(this);
  }
}

void registerUser() {
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

  @override
  Map<String, dynamic> toJson(Profile instance) {
    final result = <String, dynamic>{};
    result['age'] = SafeJsonMapper.serializeValue(instance.age);
    result['bio'] = SafeJsonMapper.serializeValue(instance.bio);
    result['score'] = SafeJsonMapper.serializeValue(instance.score);
    return result;
  }
}

mixin $ProfileEqualityMixin on Profile {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Profile) return false;
    if (!SafeJsonMapper.deepEquals(age, other.age)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(bio, other.bio)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(score, other.score)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(SafeJsonMapper.deepHash(age),
        SafeJsonMapper.deepHash(bio), SafeJsonMapper.deepHash(score));
  }

  @override
  String toString() {
    final buffer = StringBuffer('Profile(');
    buffer.write('age: $age');
    buffer.write(', ');
    buffer.write('bio: $bio');
    buffer.write(', ');
    buffer.write('score: $score');
    buffer.write(')');
    return buffer.toString();
  }
}

extension $ProfileSafeJsonExtension on Profile {
  Profile copyWith({
    int? age,
    String? bio,
    num? score,
  }) {
    return Profile(
      age: age ?? this.age,
      bio: bio ?? this.bio,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toJson() {
    return SafeJsonMapper.toJson<Profile>(this);
  }
}

void registerProfile() {
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

  @override
  Map<String, dynamic> toJson(Post instance) {
    final result = <String, dynamic>{};
    result['title'] = SafeJsonMapper.serializeValue(instance.title);
    result['content'] = SafeJsonMapper.serializeValue(instance.content);
    return result;
  }
}

mixin $PostEqualityMixin on Post {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Post) return false;
    if (!SafeJsonMapper.deepEquals(title, other.title)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(content, other.content)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(
        SafeJsonMapper.deepHash(title), SafeJsonMapper.deepHash(content));
  }

  @override
  String toString() {
    final buffer = StringBuffer('Post(');
    buffer.write('title: $title');
    buffer.write(', ');
    buffer.write('content: $content');
    buffer.write(')');
    return buffer.toString();
  }
}

extension $PostSafeJsonExtension on Post {
  Post copyWith({
    String? title,
    String? content,
  }) {
    return Post(
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toJson() {
    return SafeJsonMapper.toJson<Post>(this);
  }
}

void registerPost() {
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

  @override
  Map<String, dynamic> toJson(ApiResponse instance) {
    final result = <String, dynamic>{};
    result['success'] = SafeJsonMapper.serializeValue(instance.success);
    result['message'] = SafeJsonMapper.serializeValue(instance.message);
    result['data'] = SafeJsonMapper.serializeValue(instance.data);
    return result;
  }
}

mixin $ApiResponseEqualityMixin on ApiResponse {
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ApiResponse) return false;
    if (!SafeJsonMapper.deepEquals(success, other.success)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(message, other.message)) {
      return false;
    }
    if (!SafeJsonMapper.deepEquals(data, other.data)) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return Object.hash(SafeJsonMapper.deepHash(success),
        SafeJsonMapper.deepHash(message), SafeJsonMapper.deepHash(data));
  }

  @override
  String toString() {
    final buffer = StringBuffer('ApiResponse(');
    buffer.write('success: $success');
    buffer.write(', ');
    buffer.write('message: $message');
    buffer.write(', ');
    buffer.write('data: $data');
    buffer.write(')');
    return buffer.toString();
  }
}

extension $ApiResponseSafeJsonExtension on ApiResponse {
  ApiResponse copyWith({
    bool? success,
    String? message,
    User? data,
  }) {
    return ApiResponse(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toJson() {
    return SafeJsonMapper.toJson<ApiResponse>(this);
  }
}

void registerApiResponse() {
  SafeJsonMapper.register<ApiResponse>(_$ApiResponseSafeProvider());
}
