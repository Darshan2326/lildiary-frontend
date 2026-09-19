// class User {
//   final int id;
//   final String name;
//   final String username;
//   final String email;

//   const User({
//     required this.id,
//     required this.name,
//     required this.username,
//     required this.email,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'] as int,
//       name: json['name'] as String,
//       username: json['username'] as String,
//       email: json['email'] as String,
//     );
//   }
// }

class User {
  int? id;
  String? name;
  String? username;
  String? email;
  String? role;
  int? isActive;
  String? profileImageUrl;
  String? createdAt;
  String? updatedAt;
  Null deletedAt;
  List<Diaries>? diaries;
  List<Memories>? memories;

  User(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.role,
      this.isActive,
      this.profileImageUrl,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.diaries,
      this.memories});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    role = json['role'];
    isActive = json['is_active'];
    profileImageUrl = json['profile_image_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    if (json['diaries'] != null) {
      diaries = <Diaries>[];
      (json['diaries'] as List<dynamic>).forEach((value) {
        diaries!.add(Diaries.fromJson(value as Map<String, dynamic>));
      });
    }
    if (json['memories'] != null) {
      memories = <Memories>[];
      (json['memories'] as List<dynamic>).forEach((value) {
        memories!.add(Memories.fromJson(value as Map<String, dynamic>));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['role'] = this.role;
    data['is_active'] = this.isActive;
    data['profile_image_url'] = this.profileImageUrl;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    if (this.diaries != null) {
      data['diaries'] = this.diaries!.map((v) => v.toJson()).toList();
    }
    if (this.memories != null) {
      data['memories'] = this.memories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Diaries {
  int? id;
  String? title;
  String? description;
  List<String>? images;
  int? userId;
  String? userEmail;
  String? createdAt;
  String? updatedAt;
  Null deletedAt;

  Diaries(
      {this.id,
      this.title,
      this.description,
      this.images,
      this.userId,
      this.userEmail,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  Diaries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    images = (json['images'] as List<dynamic>?)
      ?.map((value) => value.toString())
      .toList();
    userId = json['user_id'];
    userEmail = json['user_email'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['images'] = this.images;
    data['user_id'] = this.userId;
    data['user_email'] = this.userEmail;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    return data;
  }
}

class Memories {
  int? id;
  String? title;
  String? description;
  String? videoUrl;
  String? thumbnailUrl;
  String? status;
  String? errorMessage;
  String? createdAt;

  Memories(
      {this.id,
      this.title,
      this.description,
      this.videoUrl,
      this.thumbnailUrl,
      this.status,
      this.errorMessage,
      this.createdAt});

  Memories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    videoUrl = json['video_url'];
    thumbnailUrl = json['thumbnail_url'];
    status = json['status'];
    errorMessage = json['error_message'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['video_url'] = this.videoUrl;
    data['thumbnail_url'] = this.thumbnailUrl;
    data['status'] = this.status;
    data['error_message'] = this.errorMessage;
    data['created_at'] = this.createdAt;
    return data;
  }
}
