import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 2026-11-22 대본 교차 검증에서 드러난 학습문서·발음사전 정정의 회귀 가드.
///
/// 공식 VPC 요금 페이지의 NAT 예시는 같은 리전 S3 로 가는 트래픽에 데이터 전송
/// 요금이 없다고 적고, 게이트웨이 엔드포인트 페이지는 그 트래픽이 AWS 네트워크를
/// 벗어나지 않는다고 적는다. 붙는 것은 NAT 시간·처리 요금이다.
String _doc(String id) => File('assets/content/saa/$id.md')
    .readAsStringSync()
    .replaceAll('\r\n', '\n');

void main() {
  test('대조군: 대상 문서를 실제로 읽었다', () {
    expect(_doc('saa-t4-4'), contains('Gateway Endpoint'));
    expect(_doc('saa-t1-3'), contains('NAT 게이트웨이'));
  });

  test('같은 리전 S3 의 NAT 경유 트래픽에 아웃바운드 요금을 적지 않는다', () {
    final t = _doc('saa-t4-4');
    expect(t, isNot(contains('| 데이터 전송 요금 | 인터넷 아웃바운드 단가 적용 |')));
    expect(t, isNot(contains(r'NAT $0.045/GB + 아웃바운드 요금')));
    expect(t, isNot(contains('EC2 → NAT GW → 인터넷 → S3')));
    expect(t, contains('같은 리전 S3·DynamoDB는 없음'));
    expect(t, contains('같은 리전이면 데이터 전송 요금 없음'));
    expect(t, contains('EC2 → NAT GW → IGW → S3 (AWS 네트워크 안)'));
  });

  test('VPC 피어링을 무조건 저렴하다고 단정하지 않는다', () {
    expect(_doc('saa-t4-4'), isNot(contains('VPC 피어링이 무조건 저렴')));
  });

  test('자가 점검의 NAT 배치 답이 영역형으로 한정된다', () {
    final t = _doc('saa-t1-3');
    expect(t, isNot(contains('\n**NAT 게이트웨이**를 퍼블릭 서브넷에 배치')));
    expect(t, contains('**영역형(zonal) NAT 게이트웨이**를 퍼블릭 서브넷에 배치'));
  });

  test('발음사전: TB 는 테라바이트, DSSE 는 글자대로 읽는다', () {
    final entries =
        (json.decode(File('tool/lexicon.json').readAsStringSync())
            as Map<String, dynamic>)['entries'] as Map<String, dynamic>;
    expect((entries['TB'] as Map)['say'], '테라바이트');
    expect((entries['DSSE'] as Map)['say'], '디에스에스이');
  });
}
