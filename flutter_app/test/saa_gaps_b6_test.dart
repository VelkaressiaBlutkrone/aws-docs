import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B6 — Task 2.2 잔여: ASG 운영·불변 인프라·HA 지표·DB 가용성·
/// Route 53·분산 패턴·가시성·쿼터·관리형 AI (2026-10-21).
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B6".
/// `saa-t2-3`·`saa-t2-4` 문항은 모두 `verified:false` 드래프트지만 md 는 라이브다.
///
/// 가드 규율: **금지할 것만 고정하고 요구는 느슨하게**. 틀린 수치를 바로잡는 경고
/// 문구가 그 문자열을 포함할 수 있으므로 문자열 금지보다 **단정 금지**를 쓴다(B3 교훈).
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·보강 노트 구간을 **제외한 본문**만 돌려준다.
  ///
  /// ⚠️ 이 배치에서 세 번째로 같은 함정을 만났다 — 보강 노트는 "쓰지 않은 것"을
  /// 적으며 **그 수치를 인용**하므로, 본문 금지와 같은 자를 대면 *올바른 기록*이
  /// 가드에 걸린다(B3 의 "SCP 최대 5개" 경고 문구, B6 의 가용성 계층표에 이어
  /// 세 번째). 단정을 막아야 할 곳은 **가르치는 본문**이므로 구간을 한정한다.
  /// `saa_t1_facts_test.dart` 의 G-1.1-08(자가 점검 구간 한정)과 같은 방식이다.
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B6-1 G-2.2-11 ASG 운영 세부 (saa-t2-3)', () {
    test('유예 기간·쿨다운·워밍업·웜 풀·새로 고침이 있다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('쿨다운'), isTrue);
      expect(t.contains('워밍업'), isTrue);
      expect(t.contains('웜 풀'), isTrue);
      expect(t.contains('인스턴스 새로 고침'), isTrue);
    });

    // 유예 기간은 콘솔 300초 / CLI·SDK 0초로 **기본값이 갈린다**.
    // 한쪽만 적으면 틀리므로 둘과 그 조건(CLI)을 함께 요구한다.
    test('유예 기간 기본값이 콘솔·CLI로 갈리는 것을 적는다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('300초'), isTrue);
      expect(t.contains('0초'), isTrue);
      expect(t.contains('CLI'), isTrue, reason: '기본값이 갈리는 조건');
    });

    // 금지: 복수 정책 충돌에서 작은 용량이 이긴다는 서술.
    // 공식: "chooses the policy that provides the largest capacity".
    test('복수 정책에서 작은 용량이 우선한다고 쓰지 않는다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('가장 작은 용량'), isFalse);
      expect(t.contains('더 작은 용량을 선택'), isFalse);
    });

    // `99-gaps` V-15 해소(2026-10-21). 공식 API 레퍼런스 `LifecycleHook.GlobalTimeout`:
    // "최대 172800초(48시간) 또는 HeartbeatTimeout 의 100배 중 **더 작은 값**".
    // 기존 `saa-t2-3` 서술("기본 1시간(최대 48시간)")은 틀린 게 아니라 **조건이
    // 빠진 것**이었다 — 기본 1시간이면 100배(360,000초)가 48시간보다 커서 48시간이
    // 상한이 된다. 갭 노트가 `[의심]`(G-2.2-19)으로 둔 항목이므로 지우지 않고
    // 공식 확인 뒤 조건을 보강한다.
    test('수명 주기 훅 최대 대기에 100배 조건을 함께 적는다', () {
      final t = doc('saa-t2-3');
      if (t.contains('48시간')) {
        expect(t.contains('100배'), isTrue,
            reason: '상한은 48시간 또는 HeartbeatTimeout 의 100배 중 작은 값');
      }
    });

    test('공식 출처가 실려 있다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('health-check-grace-period'), isTrue);
      expect(t.contains('as-scale-based-on-demand'), isTrue);
    });
  });

  group('B6-2 G-2.2-03 불변 인프라 (saa-t2-3)', () {
    test('불변 인프라와 배포 전략이 있다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('불변'), isTrue);
      expect(t.contains('카나리'), isTrue);
      expect(t.contains('블루/그린') || t.contains('블루 그린'), isTrue);
    });

    // 금지: 불변 인프라에서 제자리 변경을 허용한다는 서술.
    // 공식(REL08-BP04): "no updates, security patches, or configuration changes
    //                    happen in-place on production workloads".
    test('불변 인프라에서 제자리 변경을 허용한다고 쓰지 않는다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('불변 인프라에서도 제자리'), isFalse);
      expect(t.contains('불변 인프라는 패치를 직접'), isFalse);
    });
  });

  group('B6-3 G-2.2-06 레거시 앱 신뢰성 (saa-t2-3)', () {
    test('EC2 자동 복구와 단일 인스턴스 ASG 패턴이 있다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('StatusCheckFailed_System'), isTrue);
      expect(t.contains('자동 복구'), isTrue);
      expect(t.contains('시스템 상태 점검'), isTrue);
    });

    // 금지: 인스턴스 상태 점검만 실패해도 자동 복구가 동작한다는 서술.
    // 공식: "automatic instance recovery does not operate if only the instance
    //        status check fails".
    test('인스턴스 상태 점검 실패로도 자동 복구가 된다고 쓰지 않는다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('인스턴스 상태 점검 실패 시에도 자동 복구'), isFalse);
      expect(t.contains('두 상태 점검 모두 자동 복구'), isFalse);
    });

    // 금지: 자동 복구가 인스턴스 스토어 데이터를 보존한다는 서술.
    test('자동 복구가 인스턴스 스토어 데이터를 보존한다고 쓰지 않는다', () {
      final t = doc('saa-t2-3');
      expect(t.contains('인스턴스 스토어 데이터도 보존'), isFalse);
      expect(t.contains('인스턴스 스토어가 유지'), isFalse);
    });
  });

  group('B6-4 G-2.2-07 HA 지표 (saa-t2-4)', () {
    test('가용성 % ↔ 연간 허용 중단 환산이 있다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('99.9'), isTrue);
      expect(t.contains('연간'), isTrue);
    });

    test('SLA 와 설계 목표를 구분해 적는다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('SLA'), isTrue);
      expect(t.contains('설계 목표'), isTrue, reason: 'SLA(계약)와 설계 목표는 다르다');
    });

    // 금지: 서비스별 SLA 수치 단정. `99-gaps` V-13 이 EC2 SLA 수치를 미확인으로
    // 열어 둔 계열이고, 이번 조회에서도 SLA 페이지 수치를 확보하지 않았다.
    //
    // ⚠️ 퍼센트 문자열 자체를 금지하면 안 된다 — 가용성 계층표(99.95%·99.999%)는
    // SLA 가 아니라 **목표 등급**이라 본문에 정당하게 나온다. 처음 이렇게 썼다가
    // 올바른 표에 걸렸다(B3 의 "경고 문구가 금지 문자열을 포함한다"와 같은 계열).
    // 그래서 **SLA 라는 말에 수치를 붙이는 형태**만 막는다.
    test('서비스별 SLA 수치를 단정하지 않는다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('SLA는 99.9'), isFalse);
      expect(t.contains('SLA 99.9'), isFalse);
      expect(t.contains('Multi-AZ SLA'), isFalse);
      expect(t.contains('Aurora SLA'), isFalse);
    });
  });

  group('B6-5 G-2.2-08 DB 가용성 옵션 (saa-t2-4)', () {
    test('Aurora 저장 구조와 Multi-AZ 클러스터가 있다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('6개'), isTrue, reason: '스토리지 노드 6개');
      expect(t.contains('35초'), isTrue, reason: 'Multi-AZ 클러스터 장애 조치');
      expect(t.contains('읽기 가능 스탠바이'), isTrue);
    });

    test('DynamoDB 글로벌 테이블 두 모드가 있다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('MREC'), isTrue);
      expect(t.contains('MRSC'), isTrue);
    });

    // 금지: Aurora 장애 조치를 30초 미만으로 단정.
    // 공식 사용자 가이드: "typically restored in less than 60 seconds,
    //                     and often less than 30 seconds".
    test('Aurora 장애 조치를 30초 미만으로 단정하지 않는다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('Aurora 장애 조치는 30초 미만'), isFalse);
      expect(t.contains('30초 안에 끝납니다'), isFalse);
      if (t.contains('30초')) {
        expect(t.contains('60초'), isTrue,
            reason: '30초는 "흔히"에 해당하고 통상 상한은 60초다');
      }
    });

    // 금지: RDS Proxy 장애 조치 단축 "66%" — `99-gaps` V-14 미확인.
    // 본문 구간만 본다(보강 노트는 "쓰지 않았다"며 이 수치를 인용한다).
    test('본문에 RDS Proxy 66% 수치를 쓰지 않는다', () {
      expect(body('saa-t2-4').contains('66%'), isFalse);
    });

    // MRSC 는 정확히 3개 리전 제약이 핵심이다.
    test('MRSC 의 리전 수 제약을 함께 적는다', () {
      final t = doc('saa-t2-4');
      if (t.contains('MRSC')) {
        expect(t.contains('3개 리전') || t.contains('세 개 리전'), isTrue,
            reason: 'MRSC 는 정확히 3개 리전에만 배포된다');
      }
    });
  });

  group('B6-6 G-2.2-09 Route 53 (saa-t2-4)', () {
    test('라우팅 정책 8종과 헬스 체크 수치가 있다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('지연 시간') || t.contains('Latency'), isTrue);
      expect(t.contains('가중'), isTrue);
      expect(t.contains('멀티값'), isTrue);
      expect(t.contains('18%'), isTrue, reason: '헬스 체커 집계 규칙');
      expect(t.contains('10초'), isTrue, reason: '빠른 간격');
    });

    test('정책 상세는 담당 문서로 참조한다', () {
      expect(doc('saa-t2-4').contains('saa-t3-7'), isTrue);
    });

    // 금지: HTTPS 헬스 체크가 인증서를 검증한다는 서술.
    // 공식: "HTTPS health checks don't validate SSL/TLS certificates".
    test('HTTPS 헬스 체크가 인증서를 검증한다고 쓰지 않는다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('HTTPS 헬스 체크는 인증서를 검증'), isFalse);
      expect(t.contains('만료된 인증서는 헬스 체크 실패'), isFalse);
    });
  });

  group('B6-7 G-2.2-05 분산 설계 패턴 (saa-t2-4)', () {
    test('백오프·지터·재시도 제한·회로 차단기가 있다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('지수 백오프'), isTrue);
      expect(t.contains('지터'), isTrue);
      expect(t.contains('회로 차단기'), isTrue);
      expect(t.contains('HALF_OPEN'), isTrue, reason: '세 상태 중 하나');
    });

    // 금지: 백오프만으로 충분하다는 서술. 공식(REL05-BP03)은 분산 시스템에서
    // 모든 클라이언트가 동시에 백오프하면 재시도 군집이 생긴다고 적는다.
    test('지터 없이 백오프만으로 충분하다고 쓰지 않는다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('백오프만으로 충분'), isFalse);
      expect(t.contains('지터는 선택 사항이라 생략'), isFalse);
    });
  });

  group('B6-8·9·10 가시성·쿼터·관리형 AI (saa-t2-4)', () {
    test('X-Ray 와 트레이스 맵이 있다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('X-Ray'), isTrue);
      expect(t.contains('트레이스 맵') || t.contains('서비스 맵'), isTrue);
    });

    test('Service Quotas 와 요청 템플릿이 있다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('Service Quotas'), isTrue);
      expect(t.contains('템플릿'), isTrue);
    });

    // 금지: 요청 템플릿이 기존 계정의 쿼터까지 바꾼다는 서술.
    // 공식: "Updating a request template doesn't update quota values for
    //        existing accounts."
    test('템플릿이 기존 계정 쿼터를 바꾼다고 쓰지 않는다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('기존 계정의 쿼터도 갱신'), isFalse);
      expect(t.contains('기존 계정에도 소급'), isFalse);
    });

    test('in-scope 관리형 AI 서비스와 용도가 있다', () {
      final t = doc('saa-t2-4');
      for (final s in ['Comprehend', 'Polly', 'Textract', 'Transcribe',
                       'Translate', 'Lex']) {
        expect(t.contains(s), isTrue, reason: 'in-scope 관리형 AI: $s');
      }
    });

    // 금지: AMS(AWS Managed Services, 운영 대행)를 시험 범위로 단정.
    // `99-gaps` C-18 — 공식 Knowledge 의 예시가 AMS 와 무관해 의미가 모호하고
    // AMS 자체는 in-scope 목록에 없다.
    test('AMS를 시험 범위로 단정하지 않는다', () {
      final t = doc('saa-t2-4');
      expect(t.contains('AMS는 시험 범위'), isFalse);
      expect(t.contains('AWS Managed Services가 출제'), isFalse);
    });
  });
}
