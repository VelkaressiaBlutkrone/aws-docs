# ③ 시험 가이드 현행성 감사 샤드 — 03-exam-guides — 2026-07

## 요약
- **세 시험 모두 2026-07-02 기준 현행 버전이다.** CLF-C02(후속 버전 발표 없음), SAA-C03(SAA-C04 발표 없음), SOA-C03(2025-09-30 출시). AWS 공식 "Coming Soon" 페이지에 CLF·SAA 전환 공지 없음 — **사용자의 2~4주 내 CLF-C02 응시에 버전 리스크 없음.**
- 세 JSON의 도메인 수·이름·비중(CLF 24/30/34/12, SAA 30/26/24/20, SOA 22/22/22/16/18), 문항 구성(50 채점+15 비채점=65), 시험 시간(90/130/130분), 합격선(700/720/720)은 공식 가이드와 **전부 일치**.
- 단, SOA-C03 공식 가이드가 **v1.1(2026-06-01 발행)로 개정**됐는데 JSON은 v1.0(2025-09-30) 문구다 — 스킬 11건 변경 + in-scope에 Amazon Bedrock·Kiro·AWS DevOps Agent 등 5종 추가(GUIDE-001). 또한 SOA-C03부터 자격증 공식명이 **"AWS Certified CloudOps Engineer - Associate"로 개명**(GUIDE-002).
- 참고(오정보 차단): 서드파티 덤프 사이트의 "CLF-C02에 생성형 AI 도메인(~9%) 신설" 주장은 공식 가이드에서 확인되지 않음 — 공식 CLF-C02는 4개 도메인 그대로 유지 중.

## 확인 방법 (조회한 출처 URL)
- https://aws.amazon.com/certification/coming-soon/ — 시험 버전 전환 공지: SOA-C02→SOA-C03(2025-09-29 종료/09-30 개시)만 존재, CLF·SAA 전환 공지 없음
- https://aws.amazon.com/certification/certified-cloud-practitioner/ — CLF-C02 현행 · 90분 · 65문항 · 후속 버전 공지 없음(인도네시아어 시험만 2026-07-16 이후 은퇴)
- https://aws.amazon.com/certification/certified-solutions-architect-associate/ — SAA-C03 현행 · 130분 · 65문항 · SAA-C04 공지 없음
- https://aws.amazon.com/certification/certified-cloudops-engineer-associate/ — SOA-C03 현행 · 130분 · 65문항 · 공식명 "AWS Certified CloudOps Engineer - Associate"(구 SysOps 보유자는 재응시 불요)
- https://docs.aws.amazon.com/aws-certification/latest/cloud-practitioner-02/cloud-practitioner-02.html + domain1~4 페이지 — CLF 도메인 4개(24/30/34/12) · 50+15문항 · 합격 700 · 태스크 문장 전수 대조
- https://docs.aws.amazon.com/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html + domain1~4 페이지 — SAA 도메인 4개(30/26/24/20) · 50+15문항 · 합격 720 · 태스크 문장 전수 대조
- https://docs.aws.amazon.com/aws-certification/latest/sysops-administrator-associate-03/sysops-administrator-associate-03.html + domain1 + soa-03-revisions 페이지 — SOA 도메인 5개(22/22/22/16/18) · 50+15문항 · 합격 720 · v1.0→v1.1 개정 diff 전문 확보
- (웹 검색) AWS Training and Certification Blog "Exam update and new name for operations certification" — SysOps→CloudOps 개명·전환 일정 교차 확인

**커버리지 명시:** CLF-C02·SAA-C03은 전 도메인 태스크 문장 레벨까지 축자 대조 완료(SAA의 "AWS Cognito/AWS GuardDuty/AWS Macie", "Amazon QuickSuite" 표기는 현행 공식 영문 가이드 원문과 동일함을 확인 — 오류 아님). SOA-C03은 도메인 구성·비중·기본정보 + 도메인 1 태스크 축자 대조 + 공식 Revisions 페이지의 v1.0→v1.1 전체 변경표로 대조했고, JSON이 v1.0과 일치함을 개정 11건 전부에서 확인함. 도메인 2~5의 미개정 항목 축자 대조는 미수행(해당 부분 무결성 확신도는 '중').

## 발견 항목
| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| GUIDE-001 | assets/exam_guides/SOA-C03.json | 공식 시험 가이드가 v1.1(2026-06-01 발행)로 개정됐으나 JSON은 v1.0(2025-09-30) 문구. 변경: 스킬 11건(예: 1.2.1 예시 "AWS 사용자 알림·오토 스케일링"→"Kiro, AWS DevOps Agent"; 1.1.1에 워크로드 예시(서버리스·컴퓨팅·AI) 추가; 1.3.4에 Amazon S3 Files 추가; 2.3.4 DR 모범사례 예시(백업·파일럿 라이트·웜 스탠바이·활성/활성) 추가; 3.2.2에 EventBridge·AWS DevOps Agent 추가; 4.1.3에 Organizations·SCP·IAM Identity Center 예시, 4.1.5에 지속 모니터링·AWS Config conformance packs, 4.2.5에 AWS Security Agent, 5.1.2에 VPC 엔드포인트·PrivateLink·VPC 피어링 예시 추가), in-scope에 Amazon Bedrock·AWS DevOps Agent·AWS Health Dashboard·Kiro·AWS Security Agent 5종 추가, out-of-scope 목록에서 AppStream 2.0·A2I·AppSync·Cloud Directory·Kendra·Q Developer 제거. 개정은 발행 ≥1개월 후 시험 반영 원칙 — 2026-07 현재 응시분부터 적용 시점 | M | 높 | ko_kr 공식 가이드(v1.1) 기준으로 SOA-C03.json tasks 재동기화. 도메인 수·이름·비중, 문항 수·시간·합격선은 v1.1에서도 변경 없음(확인 완료)이므로 overview는 유지 | B | Y |
| GUIDE-002 | 공식 가이드 대비 (SOA-C03 자격증 명칭) | SOA-C03부터 자격증 공식명이 "AWS Certified CloudOps Engineer - Associate"로 개명(구 "AWS Certified SysOps Administrator - Associate", 2025-09-30 발효). exam_guides JSON에는 표시명 필드가 없어 이 파일 자체는 무결(slug "sysops-administrator-associate-03"은 AWS docs URL 경로와 일치해 내부 식별자로 유효)하나, 앱이 자격증명을 구명으로 표시하고 있다면 낡은 정보 노출 | M | 높 | 앱 내 SOA 자격증 표시명의 소스(자격증 카탈로그 에셋/코드 — 이 샤드 대상 파일 밖)를 확인해 구명이면 신명칭으로 갱신 | B | Y |
| GUIDE-003 | assets/exam_guides/CLF-C02.json (task 3.7 skills) | 예시 서비스가 "Amazon SageMaker"로 표기 — 현행 공식 영문 가이드는 "Amazon SageMaker AI"(서비스 개명 반영 갱신됨). 그 외 CLF 전 도메인(1~4) 태스크·knowledge·skills는 공식과 1:1 일치(WorkSpaces Secure Browser 등 최신 개명은 이미 반영돼 있음). 분석 예시의 QuickSight는 CLF 가이드에선 공식도 여전히 "Amazon QuickSight"라 일치 | L | 높 | ko_kr 공식 페이지 표기 확인 후 해당 스킬 문구를 "Amazon SageMaker AI"로 갱신 | A | Y |
