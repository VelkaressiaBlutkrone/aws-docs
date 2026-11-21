/// 운영자 공지 한 건 — 번들 자산 `assets/notices.json` 의 한 항목.
///
/// 설계 정본: `docs/superpowers/specs/2026-11-21-notice-feedback-design.md` §7-1.
class Notice {
  const Notice({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
  });

  /// `n-YYYYMMDD-NN`.
  ///
  /// ⚠️⚠️ **지우거나 재사용하지 않는다(append-only).** 읽음 상태가 「가장 최근
  /// 읽은 공지의 id」 하나로 저장되므로, 이미 내보낸 id 가 사라지면 읽음 기준을
  /// 계산할 수 없다. 그 경우를 런타임은 「전부 읽음」으로 흡수하지만(`notices.dart`),
  /// 그것은 안전장치이고 규율의 대체가 아니다.
  final String id;

  /// `YYYY-MM-DD`. 목록은 이 값의 **내림차순**(최신 먼저)이다.
  final String date;

  final String title;

  /// **평문.** 단락은 `\n` 으로 가른다 — 공지 렌더 경로는 마크다운 파서를 타지
  /// 않는 평문 `Text` 다(문항·해설과 같은 규율).
  final String body;

  factory Notice.fromJson(Map<String, dynamic> j) => Notice(
        id: (j['id'] ?? '').toString(),
        date: (j['date'] ?? '').toString(),
        title: (j['title'] ?? '').toString(),
        body: (j['body'] ?? '').toString(),
      );
}
