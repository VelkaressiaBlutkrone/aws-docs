import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// SAA 갭 보강 배치 B8c — Task 3.5 잔여 7행 (2026-10-21). **B8 완결.**
///
/// 배정 정본은 `docs/content-research/SAA-C03/97-gap-batch-map.md` §4 "B8".
/// B8 23행 중 마지막 7행이다(3.3 잔여 6행 = B8a, 3.4+MACsec 10행 = B8b).
///
/// ⚠️ `saa-t3-9` 는 서브섹션 11·원리 8 로 하한이 8 에 캡돼 있어 절을 늘려도
///    안전하다. 문항은 드래프트 0/15.
/// ⚠️ **QuickSight 개명은 이 배치 범위를 넘는다** — `Amazon Quick`(상위
///    서비스) 안의 `Amazon Quick Sight`(BI 기능)이고, 레포 전체 9파일
///    4자격증에 옛 표기가 있다. B8c 는 `saa-t3-9` 만 고치고 나머지는 별 트랙.
void main() {
  String doc(String id) =>
      File('assets/content/saa/$id.md').readAsStringSync();

  /// 출처·보강 노트 구간을 제외한 **본문**만 본다(B6 교훈 — 맵 §4).
  String body(String id) {
    final t = doc(id);
    final i = t.indexOf('### 📌 출처');
    return i < 0 ? t : t.substring(0, i);
  }

  group('B8c-1 G-3.5-07 시각화 — Amazon Quick Sight (saa-t3-9)', () {
    test('현행 명칭과 상위 서비스 관계가 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('Amazon Quick Sight'), isTrue, reason: '현행 기능 명칭');
      expect(t.contains('Amazon Quick'), isTrue, reason: '상위 서비스');
      expect(t.contains('API'), isTrue, reason: 'API·SDK는 변경 없음');
    });

    test('SPICE·직접 쿼리와 규모가 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('SPICE'), isTrue);
      expect(t.contains('직접 쿼리'), isTrue);
      expect(t.contains('200 GB'), isTrue, reason: '데이터셋 규모');
    });

    test('VPC 연결 미지원 소스가 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('VPC 연결'), isTrue);
      expect(t.contains('invalid parameter') || t.contains('잘못된 파라미터'),
          isTrue, reason: '미지원 소스에 붙이면 실패');
    });

    // 금지가 아니라 **교정 문맥 요구**(맵 §4의 ①). 옛 표기 `QuickSight` 를
    // 역사적 맥락으로 쓰는 것은 옳다 — 다만 현행 명칭이 같은 문서에 있어야 한다.
    test('옛 표기를 현행 명칭 없이 쓰지 않는다', () {
      final t = body('saa-t3-9');
      if (t.contains('QuickSight')) {
        expect(t.contains('Amazon Quick Sight'), isTrue,
            reason: '옛 표기를 남기려면 현행 명칭과 관계를 함께 적어야 한다');
      }
    });

    // 금지: 개명을 "QuickSight → Amazon Quick" 으로 뭉개는 서술.
    // 공식: Quick 은 **상위 서비스**이고 QuickSight 는 그 안의 **Quick Sight**
    //       기능으로 이어진다.
    test('개명을 상위·하위 구분 없이 적지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('QuickSight가 Amazon Quick으로 이름이 바뀌'), isFalse);
      expect(t.contains('QuickSight → Amazon Quick'), isFalse);
    });

    // 금지: ML 인사이트의 세부를 단정하는 것(이번 조회로 확보하지 못했다).
    test('ML 인사이트 세부를 단정하지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('이상 탐지 알고리즘은'), isFalse);
      expect(t.contains('예측 모델은 자동으로'), isFalse);
    });
  });

  group('B8c-2 G-3.5-04 Kinesis 설계 세부 (saa-t3-9)', () {
    test('EFO와 공유 처리량의 차이가 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('향상된 팬아웃') || t.contains('EFO'), isTrue);
      expect(t.contains('2 MB/초'), isTrue);
      expect(t.contains('SubscribeToShard'), isTrue);
      expect(t.contains('HTTP/2'), isTrue);
    });

    test('전파 지연과 등록 한도가 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('70 ms'), isTrue, reason: 'EFO 평균 전파 지연');
      expect(t.contains('200 ms'), isTrue, reason: '공유 소비자 1개');
      expect(t.contains('Advantage'), isTrue, reason: '온디맨드 두 등급');
    });

    test('보존 기간 모델이 공식대로 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('24시간'), isTrue, reason: '기본값이자 최솟값');
      expect(t.contains('8,760시간'), isTrue, reason: '최댓값 = 365일');
      expect(t.contains('DecreaseStreamRetentionPeriod'), isTrue);
    });

    // 금지: 보존 기간의 기본값·최솟값을 7일로 적는 것.
    // 갭 노트의 "보존 확장(7일)"은 요금 등급 틀이고, 공식 보존 모델은
    // **기본 24시간 · 최소 24시간 · 최대 8,760시간(365일)** 이다.
    // ⚠️ `최대 365일` 자체를 금지하면 안 된다 — §3 표의 기존 서술이 옳다.
    test('보존 기본값·최솟값을 7일로 적지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('기본 보존 기간은 7일'), isFalse);
      expect(t.contains('최소 7일'), isFalse);
      expect(t.contains('기본값 7일'), isFalse);
    });

    // 금지: 보존 기간을 늘리면 이미 만료된 데이터가 되살아난다는 서술.
    // 공식: 늘려도 **이전 보존 기간보다 오래된 데이터는 접근 불가**다.
    test('보존을 늘리면 만료 데이터가 되살아난다고 적지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('만료된 데이터도 다시 접근'), isFalse);
      expect(t.contains('늘리면 과거 데이터를 복구'), isFalse);
    });

    // 금지: EFO 가 샤드의 **입력(쓰기) 처리량**을 늘린다는 서술.
    // EFO 는 소비자별 **읽기** 처리량을 독립시키는 기능이다.
    test('EFO가 쓰기 처리량을 늘린다고 적지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('EFO로 쓰기 처리량'), isFalse);
      expect(t.contains('샤드 입력 처리량도 늘'), isFalse);
    });
  });

  group('B8c-3 G-3.5-02 데이터 형식 변환 (saa-t3-9)', () {
    test('Athena CTAS 동작이 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('CTAS'), isTrue);
      expect(t.contains('Glue Data Catalog'), isTrue);
      expect(t.contains('비어 있어야'), isTrue, reason: '출력 위치 전제');
      expect(t.contains('INSERT INTO'), isTrue);
    });

    test('Firehose 변환 제약이 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('Snappy'), isTrue);
      expect(t.contains('S3 목적지'), isTrue);
      expect(t.contains('동적 파티셔닝'), isTrue);
    });

    test('Glue 작업 북마크가 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('북마크'), isTrue);
      expect(t.contains('job.commit') || t.contains('`job.commit`'), isTrue);
      expect(t.contains('타임스탬프'), isTrue, reason: 'S3 소스 증분 필터');
    });

    // 금지: Firehose 형식 변환이 모든 목적지에서 된다는 서술.
    // 공식: "Only S3 Destinations support data format conversion."
    test('모든 목적지에서 형식 변환이 된다고 적지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('모든 목적지에서 형식 변환'), isFalse);
      expect(t.contains('목적지와 무관하게 Parquet'), isFalse);
    });

    // 금지: Firehose 버퍼 크기·간격 수치 — 이번 조회로 확보하지 못했다.
    test('Firehose 버퍼 수치를 단정하지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('버퍼 크기 5 MB'), isFalse);
      expect(t.contains('버퍼 간격 60초'), isFalse);
      expect(t.contains('버퍼 한도는 128 MB'), isFalse);
    });
  });

  group('B8c-4 G-3.5-03 크기·속도 요건 (saa-t3-9)', () {
    test('DataSync 대역폭 제한 수단이 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('BytesPerSecond'), isTrue);
      expect(t.contains('MiB/s'), isTrue);
      expect(t.contains('60초'), isTrue, reason: '제한 적용 시간');
    });

    test('전송 시간 산술이 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('÷') || t.contains('나누'), isTrue);
    });

    // 금지: 실행 중에는 대역폭 제한을 바꿀 수 없다는 서술.
    // 공식: 실행 중이거나 대기 중인 태스크 실행의 제한을 수정할 수 있다.
    test('실행 중 변경이 불가하다고 적지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('실행 중에는 바꿀 수 없'), isFalse);
      expect(t.contains('시작 전에만 설정'), isFalse);
    });
  });

  group('B8c-5 G-3.5-01 수집 접점 보안 (saa-t3-9)', () {
    test('Kinesis 인터페이스 엔드포인트와 정책이 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('엔드포인트 정책'), isTrue);
      expect(t.contains('kinesis:List'), isTrue, reason: '읽기 전용 예시');
      expect(t.contains('인터페이스'), isTrue);
    });

    // 금지: 엔드포인트 정책 하나로 "그 경로만" 이 성립한다는 서술.
    // 공식: IAM 정책과 **함께** 써야 지정 엔드포인트 경유만 허용된다.
    test('엔드포인트 정책만으로 경로가 제한된다고 적지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('엔드포인트 정책만으로 경로를 제한'), isFalse);
      expect(t.contains('엔드포인트 정책 하나로 충분'), isFalse);
    });

    // 금지: KMS·Lake Formation 세부를 단정하는 것 — 미확보.
    test('Lake Formation 세부를 단정하지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('서비스 연결 역할을 반드시'), isFalse);
      expect(t.contains('S3 위치 등록은 필수적으로'), isFalse);
    });
  });

  group('B8c-6 G-3.5-08 분석 서비스 선택표 (saa-t3-9)', () {
    test('Redshift Spectrum 행이 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('Redshift Spectrum'), isTrue);
      expect(t.contains('RCFile'), isTrue, reason: '직접 쿼리 형식 목록');
      expect(t.contains('공통 데이터 카탈로그') || t.contains('카탈로그를 공유'),
          isTrue);
    });

    test('OpenSearch 행과 선택 이유가 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('OpenSearch'), isTrue);
      expect(t.contains('전문 검색'), isTrue);
      expect(t.contains('필드 수준'), isTrue, reason: 'CloudWatch 대비 선택 이유');
    });

    // 금지: Spectrum 이 데이터를 Redshift로 적재한다는 서술.
    // 공식: S3 의 데이터를 **이동 없이 제자리** 쿼리한다.
    test('Spectrum이 데이터를 적재한다고 적지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('Spectrum은 S3 데이터를 Redshift로 적재'), isFalse);
      expect(t.contains('Spectrum으로 적재한 뒤'), isFalse);
    });

    // 금지: OpenSearch 세부 구성을 단정하는 것 — `99-gaps` V-42 가 열려 있다.
    test('OpenSearch 세부 구성을 단정하지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('노드 수는'), isFalse);
      expect(t.contains('샤드 수를 반드시'), isFalse);
    });
  });

  group('B8c-7 G-3.5-05 수집 패턴·구성 선택 (saa-t3-9)', () {
    test('패턴 축이 있다', () {
      final t = doc('saa-t3-9');
      expect(t.contains('마이크로 배치'), isTrue);
      expect(t.contains('하이브리드'), isTrue);
    });

    // 금지: MSK vs Kinesis 선택을 수치로 단정하는 것 — 미확보.
    test('MSK 선택 기준을 수치로 단정하지 않는다', () {
      final t = body('saa-t3-9');
      expect(t.contains('MSK가 Kinesis보다 빠르'), isFalse);
      expect(t.contains('파티션 수는 최대'), isFalse);
    });
  });
}
