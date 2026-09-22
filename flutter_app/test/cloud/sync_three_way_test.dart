import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/data/cloud/sync_three_way.dart';

const Map<String, dynamic> _a = {'id': 'p1', 'label': 'A'};
const Map<String, dynamic> _b = {'id': 'p1', 'label': 'B'};
const Map<String, dynamic> _c = {'id': 'p1', 'label': 'C'};

void main() {
  group('decideDoc', () {
    test('양쪽 모두 그대로면 아무것도 하지 않는다', () {
      expect(decideDoc(base: _a, local: _a, cloud: _a), DocAction.none);
    });

    test('로컬만 바뀌면 push', () {
      expect(decideDoc(base: _a, local: _b, cloud: _a), DocAction.pushLocal);
    });

    test('클라우드만 바뀌면 채택', () {
      expect(decideDoc(base: _a, local: _a, cloud: _b), DocAction.adoptCloud);
    });

    test('둘 다 바뀌면 늦은 쪽, 동률이면 클라우드', () {
      expect(
        decideDoc(
            base: _a,
            local: _b,
            cloud: _c,
            cloudUpdatedAtMs: 100,
            localDirtyAtMs: 200),
        DocAction.pushLocal,
      );
      expect(
        decideDoc(
            base: _a,
            local: _b,
            cloud: _c,
            cloudUpdatedAtMs: 200,
            localDirtyAtMs: 200),
        DocAction.adoptCloud,
      );
    });

    test('로컬에서 사라졌고 base에 있었으면 클라우드에서도 삭제', () {
      expect(decideDoc(base: _a, local: null, cloud: _a), DocAction.deleteCloud);
    });

    test('로컬에 없고 base에도 없으면 새 클라우드 문서를 채택', () {
      expect(
          decideDoc(base: null, local: null, cloud: _a), DocAction.adoptCloud);
    });

    test('삭제 표식이 있으면 로컬에서 지운다', () {
      expect(decideDoc(base: _a, local: _a, cloud: null, cloudDeleted: true),
          DocAction.deleteLocal);
      expect(decideDoc(base: _a, local: null, cloud: null, cloudDeleted: true),
          DocAction.none);
    });

    test('표식 없이 클라우드 문서만 사라지면 다시 올린다(손실 방지)', () {
      expect(decideDoc(base: _a, local: _a, cloud: null), DocAction.pushLocal);
    });
  });

  group('mergeSets', () {
    test('양쪽 추가를 모두 살린다', () {
      expect(
        mergeSets(base: {'a'}, local: {'a', 'b'}, cloud: {'a', 'c'}),
        {'a', 'b', 'c'},
      );
    });

    test('한쪽 삭제는 병합 결과에서도 빠진다', () {
      expect(
        mergeSets(base: {'a', 'b'}, local: {'a'}, cloud: {'a', 'b'}),
        {'a'},
      );
    });

    test('추가와 삭제가 섞여도 둘 다 반영된다', () {
      expect(
        mergeSets(base: {'a', 'b'}, local: {'a', 'c'}, cloud: {'b'}),
        {'c'},
      );
    });
  });
}
