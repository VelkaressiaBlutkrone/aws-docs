# ④ 문항 품질 감사 샤드 — 04-q-clf-t3-2 — 2026-07

## 요약

- 대상: `flutter_app/assets/content/clf/t3-2.questions.json` 15문항(clf-t3-2-q1~q15) × 7개 점검 항목(정답 유일성·해설-정답 일치·wrongExplanations 논리·section 앵커·skill/difficulty 태그·AWS 사실·스키마 위생) 전수 수행.
- 결과: **14문항 전 점검 통과, 발견 1건(M)** — q13 스템의 S3 버킷 콘솔 가시성 전제가 실제 콘솔 동작과 불일치(정답·핵심 교훈은 유효).
- 스키마 위생 이상 없음: id 15개 유일, correct 전부 0~3 범위, verified 15/15 true, 옵션 각 4개, wrongExplanations 키가 전 문항에서 비정답 인덱스 3개와 정확히 일치(q7=0/2/3, q8=0/1/3, q9=0/1/2 포함).
- section 앵커 5종(regions-az·multi-az·multi-region·cloudfront-ga·proximity) 모두 `t3-2.md`의 `{#id}`에 실존. skill·difficulty(foundational 12 / applied 3) 태그는 내용과 정합.
- 참고(발견 아님): correct 인덱스 0 편중(12/15)은 런타임 옵션 셔플로 노출 시 중화됨을 코드로 확인(`quiz_page.dart:40-41 randomOptionOrders`, `review_page.dart:81`, `mock_exam.dart:123`).

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t3-2-01 | t3-2.questions.json:clf-t3-2-q13 | 스템 전제 부정확: 워크로드가 "EC2 인스턴스와 S3 버킷"인데 "도쿄 리전 콘솔을 열어 보니 서울에서 만든 리소스가 **전혀** 보이지 않는다"고 서술. EC2 콘솔은 리전별이라 맞지만, **S3 콘솔의 버킷 목록은 리전 선택과 무관한 글로벌 뷰**(전 리전 버킷을 AWS Region 열과 함께 표시)라 서울 버킷은 도쿄 콘솔에서도 보인다(버킷/데이터 자체는 서울 리전 소속 — 리전 격리·자동 복제 없음이라는 교훈과 정답 유일성은 훼손되지 않음). wrongExplanations["3"]의 "보이지 않는 것은 … 다른 리전에서 만들었기 때문"도 S3에 한해 같은 부정확을 내포 | M | 높 | 스템의 가시성 서술을 EC2로 한정(예: "도쿄 리전의 EC2 콘솔에는 서울에서 만든 인스턴스가 보이지 않는다")하거나 S3는 "버킷 이름은 보이지만 데이터는 서울 리전에 저장돼 있다"로 분리 서술. wrongExplanations["3"]도 동일하게 정비(정답 인덱스·보기 구성 변경 불필요) | A | Y |

(그 외 q1~q12·q14·q15: 발견 없음 — 전 점검 통과. 통과 집계는 요약 참조.)
