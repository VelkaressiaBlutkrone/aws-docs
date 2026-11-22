import 'package:flutter/foundation.dart';

/// 안내의 상태.
enum CertLifecyclePhase {
  /// 마지막 응시일 전이거나 당일이다.
  upcoming,

  /// 공식이 확정한 마지막 응시일이 지났다.
  ended,

  /// 예정일이 지났지만 공식 확정일이 없어 종료로 단정할 수 없다.
  needsConfirmation,
}

/// 시험 하나의 공식 수명 정보. 근거와 판정은
/// `docs/superpowers/specs/2026-11-22-cert-lifecycle-notice-design.md`.
class CertLifecycle {
  const CertLifecycle({
    required this.lastExamDate,
    required this.sourceUrl,
    this.successor,
    this.tentative = false,
  });

  final DateTime lastExamDate;
  final String sourceUrl;

  /// 후속 시험 코드. null 이면 은퇴다.
  final String? successor;

  /// true 면 [lastExamDate] 가 공식 확정일이 아니라 예정일이다.
  final bool tentative;
}

/// 화면에 보여 줄 안내.
class CertLifecycleNotice {
  const CertLifecycleNotice({
    required this.phase,
    required this.badge,
    required this.message,
    required this.sourceUrl,
  });

  final CertLifecyclePhase phase;
  final String badge;
  final String message;
  final String sourceUrl;
}

const _guides =
    'https://docs.aws.amazon.com/aws-certification/latest/examguides/aws-certification-exam-guides.html';

final Map<String, CertLifecycle> kCertLifecycles = {
  'SAP-C02': CertLifecycle(
    lastExamDate: DateTime(2026, 11, 16),
    successor: 'SAP-C03',
    sourceUrl: _guides,
  ),
  'DVA-C02': CertLifecycle(
    lastExamDate: DateTime(2026, 11, 30),
    successor: 'DVA-C03',
    sourceUrl: _guides,
  ),
  'ANS-C01': CertLifecycle(
    lastExamDate: DateTime(2026, 12, 31),
    sourceUrl:
        'https://aws.amazon.com/certification/certified-advanced-networking-specialty/',
  ),
  // 영어 C01 은 2026-09-28 에 끝났다. 한국어는 C02 정식 출시까지이고, 그 날짜는
  // 블로그만 2027-01-14 로 적고 인증 페이지는 아직 TBD 다.
  'MLA-C01': CertLifecycle(
    lastExamDate: DateTime(2027, 1, 14),
    successor: 'MLA-C02',
    tentative: true,
    sourceUrl:
        'https://aws.amazon.com/blogs/training-and-certification/updates-to-aws-certified-machine-learning-engineer-associate-mla-c02/',
  ),
};

/// 위젯이 읽는 현재 시각. 테스트만 바꾼다.
@visibleForTesting
DateTime Function() certLifecycleClock = DateTime.now;

String _fullDate(DateTime d) => '${d.year}년 ${d.month}월 ${d.day}일';

/// [code] 의 안내. 현행 시험이면 null 이다. 마지막 응시일은 당일까지 유효하다.
CertLifecycleNotice? certLifecycleNotice(String code, [DateTime? today]) {
  final life = kCertLifecycles[code];
  if (life == null) return null;
  final now = today ?? certLifecycleClock();
  final date = DateTime(now.year, now.month, now.day);
  final last = life.lastExamDate;
  final passed = date.isAfter(last);
  final day = _fullDate(last);
  final next = life.successor;

  if (life.tentative) {
    return passed
        ? CertLifecycleNotice(
            phase: CertLifecyclePhase.needsConfirmation,
            badge: '$next 전환 확인 필요',
            message:
                'AWS 블로그의 $next 정식 출시 예정일인 $day이 지났습니다. 한국어 $code 응시 가능 여부는 공식 페이지에서 확인해 주세요.',
            sourceUrl: life.sourceUrl,
          )
        : CertLifecycleNotice(
            phase: CertLifecyclePhase.upcoming,
            badge: '$next 전환 예정',
            message:
                '$code 영어 시험은 2026년 9월 28일에 끝났고, 한국어 시험은 $next 정식 출시 전까지 응시할 수 있습니다. AWS 블로그의 예정일은 $day이고, 인증 페이지에는 아직 확정일이 없습니다.',
            sourceUrl: life.sourceUrl,
          );
  }

  const retained = '후속 시험은 없고, 은퇴 전에 취득한 자격은 표준 3년 동안 유지됩니다.';
  if (passed) {
    return CertLifecycleNotice(
      phase: CertLifecyclePhase.ended,
      badge: '응시 종료',
      message: next == null
          ? '$code 시험은 $day에 은퇴했습니다. $retained'
          : '$code 응시는 $day에 끝났습니다. 현재 시험은 $next이고, 이 페이지의 내용은 $code 기준입니다.',
      sourceUrl: life.sourceUrl,
    );
  }
  return CertLifecycleNotice(
    phase: CertLifecyclePhase.upcoming,
    badge: '${last.month}월 ${last.day}일까지 응시',
    message: next == null
        ? '$code의 마지막 응시일은 $day입니다. $retained'
        : '$code의 마지막 응시일은 $day입니다. 이후 시험은 $next입니다.',
    sourceUrl: life.sourceUrl,
  );
}
