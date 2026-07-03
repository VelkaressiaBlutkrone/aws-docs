# ④ 문항 품질 감사 샤드 — 04-q-clf-t3-5 — 2026-07

## 요약
- 대상: `flutter_app/assets/content/clf/t3-5.questions.json` 17문항(예상 17과 일치) × 점검 7항목(정답 유일성·해설-정답 일치·wrongExplanations·section 앵커·skill/difficulty·AWS 사실·스키마) 전수 수행. 대조 문서 `t3-5.md`의 사용 앵커 5종(`{#vpc}`·`{#vpc-security}`·`{#flow-logs-privatelink}`·`{#route53}`·`{#onprem-connect}`) 실존 확인.
- 정답 유일성 17/17, 해설-정답 일치 17/17, wrongExplanations 키 정합(오답 3키 정확, 누락·잉여 0) 17/17, 태그 채움·정합 17/17, 스키마(id 유일·correct 0~3 범위·verified 전부 true·옵션 4개) 17/17 통과. AWS 사실 오류 0건(SG stateful/NACL stateless, NAT GW 아웃바운드 전용, DX 인터넷 우회/VPN IPsec, Route 53 3기능, Flow Logs 게시 대상 CloudWatch Logs·S3·Data Firehose, PrivateLink 'IGW·NAT·공인IP·DX·VPN 없이' 등 공식 문서 표현과 합치).
- 발견 1건: H 0 / M 0 / L 1 — q12(VPC 피어링)의 개념이 대응 학습문서에 미수록 + 딥링크 부재(아래 표).
- section 빈 값 2건(q10·q12)은 스펙상 통과(모델 `question.dart:45`가 미기재를 `''`로 처리하는 유효 스키마). q10(ELB)은 ELB가 3.3 문서 범위(문서 함정 1이 [3.3] 링크로 위임)라 의도적 공백으로 판단해 발견에서 제외.
- 부기(비점검 항목 실측): 저장 correct 인덱스 0 편중(14/17)은 quiz·review·exam 3개 노출 경로 모두 로드 시 `randomOptionOrders`로 보기 순서를 셔플(`quiz_page.dart:40-41`, `review_page.dart:81`, `mock_exam.dart:123`)해 사용자 노출 편향 없음 확인.

## 발견 항목
| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| Q-CLF-t3-5-01 | t3-5.questions.json:clf-t3-5-q12 | VPC 피어링 문항인데 대응 학습문서 t3-5.md에 '피어링' 개념이 본문·표·함정 어디에도 미수록. section도 빈 값이라 오답 시 약점 리포트·개념 딥링크로 이어지는 복습 경로가 없음(문항 자체의 정답·해설·wrongExplanations·출처는 모두 정상) | L | 높 | t3-5.md VPC 절 부근에 VPC 피어링 1~2줄 설명+앵커를 추가하고 문항 section을 연결하거나, 문서 범위 외(출처 링크로 충분)로 수용할지 결정 | B | N |
