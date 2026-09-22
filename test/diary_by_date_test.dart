import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lildairy/models/user.dart';

void main() {
  test('Diaries parsing from diary/by_date API response', () {
    const rawJson = '''
    [
      {
        "id": 9,
        "title": "test perminent media URL",
        "description": "test perminent media URL",
        "images": [
          "https://pub-817856dee81e4f938a629260580cb9f7.r2.dev/diaries/string/9/30a645f6cd3d4b31bc002994a3bb7707"
        ],
        "user_id": 1,
        "user_email": "string",
        "created_at": "2026-09-19T11:22:47",
        "updated_at": "2026-09-19T11:22:49",
        "deleted_at": null
      }
    ]
    ''';

    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final diaries = decoded
        .map((item) => Diaries.fromJson(item as Map<String, dynamic>))
        .toList();

    expect(diaries.length, 1);
    expect(diaries.first.id, 9);
    expect(diaries.first.title, 'test perminent media URL');
    expect(diaries.first.description, 'test perminent media URL');
    expect(diaries.first.images?.length, 1);
    expect(
      diaries.first.images?.first,
      'https://pub-817856dee81e4f938a629260580cb9f7.r2.dev/diaries/string/9/30a645f6cd3d4b31bc002994a3bb7707',
    );
    expect(diaries.first.userId, 1);
    expect(diaries.first.userEmail, 'string');
    expect(diaries.first.createdAt, '2026-09-19T11:22:47');
  });

  test('Diaries parsing from diary/add_diary API response', () {
    const rawJson = '''
    {
      "id": 12,
      "title": "my daughter is very happy with her grand father",
      "description": "my daughter is very happy with her grand father",
      "images": [
        "https://pub-817856dee81e4f938a629260580cb9f7.r2.dev/diaries/string/12/c4d4bed7bf68469583446bf5e1b873d2",
        "https://pub-817856dee81e4f938a629260580cb9f7.r2.dev/diaries/string/12/095f9a8d21dc420f9d376ed28d40667e",
        "https://pub-817856dee81e4f938a629260580cb9f7.r2.dev/diaries/string/12/45d02964a7f24edf8ccd1d17017672a7"
      ],
      "user_id": 1,
      "user_email": "string",
      "created_at": "2026-09-22T00:13:21",
      "updated_at": "2026-09-22T00:13:36",
      "deleted_at": null
    }
    ''';

    final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
    final diary = Diaries.fromJson(decoded);

    expect(diary.id, 12);
    expect(diary.title, 'my daughter is very happy with her grand father');
    expect(diary.description, 'my daughter is very happy with her grand father');
    expect(diary.images?.length, 3);
    expect(
      diary.images?[0],
      'https://pub-817856dee81e4f938a629260580cb9f7.r2.dev/diaries/string/12/c4d4bed7bf68469583446bf5e1b873d2',
    );
    expect(diary.userId, 1);
    expect(diary.userEmail, 'string');
    expect(diary.createdAt, '2026-09-22T00:13:21');
  });

  test('Memories parsing from /memories API response', () {
    const rawJson = '''
    [
      {
        "id": 1,
        "title": "September Recap",
        "description": "Family moments in September",
        "video_url": "https://pub-817856dee81e4f938a629260580cb9f7.r2.dev/memories/video1.mp4",
        "thumbnail_url": "https://pub-817856dee81e4f938a629260580cb9f7.r2.dev/memories/thumb1.jpg",
        "status": "completed",
        "error_message": null,
        "created_at": "2026-09-22T00:36:24.773Z"
      }
    ]
    ''';

    final decoded = jsonDecode(rawJson) as List<dynamic>;
    final memories = decoded
        .map((item) => Memories.fromJson(item as Map<String, dynamic>))
        .toList();

    expect(memories.length, 1);
    expect(memories.first.id, 1);
    expect(memories.first.title, 'September Recap');
    expect(memories.first.description, 'Family moments in September');
    expect(memories.first.videoUrl, contains('video1.mp4'));
    expect(memories.first.thumbnailUrl, contains('thumb1.jpg'));
    expect(memories.first.status, 'completed');
    expect(memories.first.createdAt, '2026-09-22T00:36:24.773Z');
  });
}
