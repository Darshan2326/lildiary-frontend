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
  bool? isSubscribed;
  String? subscriptionExpiresAt;
  List<Diaries>? diaries;
  List<Memories>? memories;

  bool get isPremium => isSubscribed == true;

  User(
      {this.id,
      this.name,
      this.username,
      this.email,
      this.role,
      this.isActive,
      this.isSubscribed,
      this.subscriptionExpiresAt,
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
    isSubscribed = json['is_subscribed'] == true || json['is_subscribed'] == 1;
    subscriptionExpiresAt = json['subscription_expires_at']?.toString();
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
    data['is_subscribed'] = this.isSubscribed;
    data['subscription_expires_at'] = this.subscriptionExpiresAt;
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
  int? recapId;
  String? title;
  String? description;
  String? videoUrl;
  String? thumbnailUrl;
  String? status;
  int? progress;
  String? statusMessage;
  String? childName;
  String? mood;
  String? musicCategory;
  String? songTitle;
  int? durationSeconds;
  int? memoriesCount;
  String? errorMessage;
  String? createdAt;
  String? frameStyle;
  String? theme;

  Memories({
    this.id,
    this.recapId,
    this.title,
    this.description,
    this.videoUrl,
    this.thumbnailUrl,
    this.status,
    this.progress,
    this.statusMessage,
    this.childName,
    this.mood,
    this.musicCategory,
    this.songTitle,
    this.durationSeconds,
    this.memoriesCount,
    this.errorMessage,
    this.createdAt,
    this.frameStyle,
    this.theme,
  });

  Memories.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? json['recap_id'];
    recapId = json['recap_id'] ?? json['id'];
    title = json['title'] ?? 'Memory Recap';
    description = json['description'];
    final rawVideo = json['video_url'] ?? json['video'] ?? json['url'] ?? json['video_path'];
    videoUrl = rawVideo?.toString().trim();
    final rawThumb = json['thumbnail_url'] ?? json['thumbnail'] ?? json['cover_image'] ?? json['cover_url'];
    thumbnailUrl = rawThumb?.toString().trim();
    status = json['status'];
    progress = json['progress'] is num ? (json['progress'] as num).toInt() : null;
    statusMessage = json['status_message'];
    childName = json['child_name'];
    mood = json['mood'];
    musicCategory = json['music_category'];
    songTitle = json['song_title'];
    durationSeconds = json['duration_seconds'] is num
        ? (json['duration_seconds'] as num).toInt()
        : null;
    memoriesCount = json['memories_count'] is num
        ? (json['memories_count'] as num).toInt()
        : null;
    errorMessage = json['error_message'];
    createdAt = json['created_at'];
    frameStyle = json['frame_style'];
    theme = json['theme'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['recap_id'] = this.recapId ?? this.id;
    data['title'] = this.title ?? 'Memory Recap';
    data['description'] = this.description;
    data['video_url'] = this.videoUrl;
    data['thumbnail_url'] = this.thumbnailUrl;
    data['status'] = this.status;
    data['progress'] = this.progress;
    data['status_message'] = this.statusMessage;
    data['child_name'] = this.childName;
    data['mood'] = this.mood;
    data['music_category'] = this.musicCategory;
    data['song_title'] = this.songTitle;
    data['duration_seconds'] = this.durationSeconds;
    data['memories_count'] = this.memoriesCount;
    data['error_message'] = this.errorMessage;
    data['created_at'] = this.createdAt;
    if (this.frameStyle != null) {
      data['frame_style'] = this.frameStyle;
    }
    if (this.theme != null) {
      data['theme'] = this.theme;
    }
    return data;
  }
}

class MusicTrack {
  final int id;
  final String title;
  final String artist;
  final String category;
  final String? keywords;
  final double? durationSeconds;
  final String? fileUrl;
  final bool isActive;

  const MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.category,
    this.keywords,
    this.durationSeconds,
    this.fileUrl,
    this.isActive = true,
  });

  List<String> get keywordList {
    if (keywords == null || keywords!.trim().isEmpty) return [];
    return keywords!
        .split(',')
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();
  }

  factory MusicTrack.fromJson(Map<String, dynamic> json) {
    return MusicTrack(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      keywords: json['keywords']?.toString(),
      durationSeconds: json['duration_seconds'] is num
          ? (json['duration_seconds'] as num).toDouble()
          : null,
      fileUrl: json['file_url']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'category': category,
      'keywords': keywords,
      'duration_seconds': durationSeconds,
      'file_url': fileUrl,
      'is_active': isActive,
    };
  }
}

class RecapGenerateRequest {
  final String? startDate;
  final String? endDate;
  final String backgroundMusic;
  final int? songId;
  final String theme;
  final String? frameStyle;
  final int maxMemories;

  const RecapGenerateRequest({
    this.startDate,
    this.endDate,
    this.backgroundMusic = "calm",
    this.songId,
    this.theme = "classic",
    this.frameStyle,
    this.maxMemories = 40,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'background_music': backgroundMusic,
      'theme': theme,
      'max_memories': maxMemories,
    };
    if (songId != null) {
      data['song_id'] = songId;
    }
    if (frameStyle != null &&
        frameStyle!.trim().isNotEmpty &&
        frameStyle!.trim().toLowerCase() != 'auto') {
      data['frame_style'] = frameStyle!.trim();
    }
    if (startDate != null && startDate!.trim().isNotEmpty) {
      data['start_date'] = startDate!.trim();
    }
    if (endDate != null && endDate!.trim().isNotEmpty) {
      data['end_date'] = endDate!.trim();
    }
    return data;
  }
}

class SubscriptionPlan {
  final int id;
  final String planName;
  final String? description;
  final double amount;
  final String currency;
  final int durationDays;
  final bool isActive;

  const SubscriptionPlan({
    required this.id,
    required this.planName,
    this.description,
    required this.amount,
    this.currency = "INR",
    this.durationDays = 30,
    this.isActive = true,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] is num ? (json['id'] as num).toInt() : 1,
      planName: json['plan_name']?.toString() ?? 'Lil Diary Premium',
      description: json['description']?.toString(),
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : 199.0,
      currency: json['currency']?.toString() ?? 'INR',
      durationDays: json['duration_days'] is num
          ? (json['duration_days'] as num).toInt()
          : 30,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }
}

class SubscriptionStatus {
  final bool isSubscribed;
  final String? subscriptionExpiresAt;
  final int daysRemaining;
  final String planName;
  final bool canViewOldMemories;
  final bool canUseCustomRecap;
  final int weeklyRecapsUsed;
  final int weeklyRecapsLimit;
  final int dailyDiariesUsed;
  final int dailyDiariesLimit;

  const SubscriptionStatus({
    required this.isSubscribed,
    this.subscriptionExpiresAt,
    required this.daysRemaining,
    required this.planName,
    required this.canViewOldMemories,
    required this.canUseCustomRecap,
    required this.weeklyRecapsUsed,
    required this.weeklyRecapsLimit,
    required this.dailyDiariesUsed,
    required this.dailyDiariesLimit,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isSubscribed: json['is_subscribed'] == true || json['is_subscribed'] == 1,
      subscriptionExpiresAt: json['subscription_expires_at']?.toString(),
      daysRemaining: json['days_remaining'] is num
          ? (json['days_remaining'] as num).toInt()
          : 0,
      planName: json['plan_name']?.toString() ?? 'Free Tier',
      canViewOldMemories: json['can_view_old_memories'] == true,
      canUseCustomRecap: json['can_use_custom_recap'] == true,
      weeklyRecapsUsed: json['weekly_recaps_used'] is num
          ? (json['weekly_recaps_used'] as num).toInt()
          : 0,
      weeklyRecapsLimit: json['weekly_recaps_limit'] is num
          ? (json['weekly_recaps_limit'] as num).toInt()
          : 4,
      dailyDiariesUsed: json['daily_diaries_used'] is num
          ? (json['daily_diaries_used'] as num).toInt()
          : 0,
      dailyDiariesLimit: json['daily_diaries_limit'] is num
          ? (json['daily_diaries_limit'] as num).toInt()
          : 3,
    );
  }
}
