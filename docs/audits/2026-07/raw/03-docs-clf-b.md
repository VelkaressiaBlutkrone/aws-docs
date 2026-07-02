# ③ 학습문서 사실성 감사 샤드 — 03-docs-clf-b (t2-2~t3-2) — 2026-07

## 요약 (3~5줄)
- 대상 5개 문서(t2-2 보안·거버넌스·컴플라이언스 / t2-3 IAM / t2-4 보안 구성요소 / t3-1 배포·운영 / t3-2 글로벌 인프라) 전문 정독 + 고위험 수치·시점 주장 4건을 공식 문서·웹으로 1차 검증했다.
- 발견 6건: 사실의심 2건(H 1 · M 1), 참조·표현·일관성 4건(L).
- 핵심 1(H): t2-3이 "AWS Support 플랜 변경·취소"를 루트 전용 작업으로 3곳(본문·시험 포인트·Q1 정답)에서 단정하나, 현행 IAM 공식 root-only 목록에 이 항목이 없음(2022-09 Support Plans IAM 제어 도입 후 IAM 주체도 가능) — 시험 오답 유발 가능.
- 핵심 2(M): t2-2 정직성 메모의 Audit Manager 신규 고객 중단 시점 "2024년 이후"는 연도 오류 — 공식 공지는 2026-04-30부터 신규 중단(유지보수 모드; 기존 고객 계속 사용이라는 취지 자체는 유효).
- 검증 후 이상 없음 확인: KMS FIPS 140-3 Security Level 3(공식 인증 확인됨), Trusted Advisor 무료 플랜 "서비스 한도 전체 + 보안·내결함성 일부"(현행 공식 서술과 일치), MFA 기기 최대 8개, Identity Center 개명일(2022-07-26), SG/NACL 대비표, WAF 보호 리소스 목록(Amplify 포함), 글로벌 인프라(리전/AZ/엣지·CloudFront vs GA·Local Zones/Wavelength/Outposts) 서술 전반.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| DOC-CLF-101 | assets/content/clf/t2-2.md#audit-trio (§6 ℹ️ 정직성 메모) | Audit Manager가 "2024년 이후 신규 고객 등록을 중단"했다고 기술. 근거: 공식 "AWS Audit Manager availability change" 페이지는 신규 고객 중단 시점을 **2026-04-30**로 명시(유지보수 모드 전환, 기존 고객 계속 사용). 2024-07 신규중단 배치(CodeCommit·Cloud9 등)와 혼동 추정 — 실질 취지(신규 중단·기존 유지·시험 출제 가능)는 유효, 연도만 오류 | M | 높 | "2026-04-30부터 신규 고객 중단(유지보수 모드 전환)"으로 시점 정정 | A | Y |
| DOC-CLF-102 | assets/content/clf/t2-3.md#root-user §3 루트 전용 목록 · ✍️ 시험 포인트 1항 · 자가 점검 Q1 정답 | "AWS Support 플랜 변경·취소"를 루트 전용 작업으로 단정(시험 포인트는 "보기에 나오면 '루트 사용자'"라고 정답 지침까지 제공). 근거: 현행 IAM 공식 root-only 목록(id_root-user.html, 2026-07 실측)에 Support 플랜 항목이 없고, 2022-09 "Support Plans console IAM controls" 공지로 IAM 주체도 변경 가능. 문서가 나열한 나머지 루트 전용 항목(계정 해지·계정 설정·Billing IAM 활성화·IAM 권한 복구·RI Marketplace 판매자·S3 MFA Delete)은 전부 현행 목록과 일치. 단, 레거시 CLF 교재·기출 다수는 여전히 루트 전용으로 취급 — 실제 출제 관례 판단은 2단 검증 필요 | H | 높 | 3개 위치에서 삭제하거나 "(과거 루트 전용, 현재는 IAM 권한으로도 가능)" 주석으로 완화. t2-3.questions.json에 동일 단정 문항이 있는지 교차 점검 | B | Y |
| DOC-CLF-103 | assets/content/clf/t2-2.md#pitfalls 함정 8~10 | 함정 8~10의 "(원리: §6 …)"이 실제로 가리키는 내용은 §5와 §6 사이의 **무번호** "인증서·키·전용 HSM — ACM·KMS·CloudHSM" 섹션의 원리인데, 문서상 §6은 감사 3종(CloudTrail·Config·CloudWatch) — 섹션 번호 누락에서 파생된 참조 불일치(문서 내 상호 모순) | L | 높 | ACM·KMS·CloudHSM 섹션에 번호를 부여하고 함정 8~10의 참조 번호 정정 | A | N |
| DOC-CLF-104 | assets/content/clf/t2-3.md#pitfalls 함정 8~10 | 함정 8~10이 "(원리: §9 …)"를 참조하나 본문 번호는 §7(Secrets Manager)까지이고 그 뒤 "IAM 글로벌"·"Cognito/Directory" 두 보강 섹션은 무번호 — §9가 문서에 존재하지 않아 독자가 원리 출처를 추적 불가 | L | 높 | 보강 섹션에 번호(§8·§9) 부여 또는 참조를 섹션명으로 교체 | A | N |
| DOC-CLF-105 | assets/content/clf/t3-1.md#connectivity 표 · ✍️ 시험 포인트 | Site-to-Site VPN을 "빠르고 저렴"으로 축약 — '구축·시작이 빠름' 의미인데 네트워크 성능(대역폭·지연)이 빠른 것으로 오독될 소지(성능 일관성·고대역폭 우위는 Direct Connect라는 시험 관례와 충돌 가능). 같은 절 원리 문단은 "빠르고 간단하게 시작"으로 올바르게 설명하고 있어 표·시험 포인트 표현만 정밀화하면 됨 | L | 높 | 표와 시험 포인트 2곳을 "구축이 빠르고 저렴"으로 명시 | A | N |
| DOC-CLF-106 | assets/content/clf/t3-1.md#deployment-ops-tools CodeCommit 행 | CodeCommit이 2024-07-25부터 신규 고객 중단된 사실 미언급 — 같은 샤드의 t2-2가 Audit Manager에는 '정직성 메모'를 단 관례와 비대칭(샤드 내 문서 간 일관성). 서비스 설명 자체는 사실이고 CLF-C02 시험 가이드 등재 서비스라 학습 유효성은 문제없음 | L | 높 | t2-2와 같은 형식의 정직성 메모 1줄 추가 여부 편집 결정 | B | N |

- Phase 해석(본 샤드): **A** = 사실 확인이 끝나 단순 자구 수정으로 즉시 반영 가능, **B** = 출제 관례·편집 방침 등 사람 결정 또는 추가 교차 점검 필요.

### 1차 검증에 사용한 근거 (2단 검증용)
1. AWS Audit Manager availability change — https://docs.aws.amazon.com/audit-manager/latest/userguide/audit-manager-availability-change.html (신규 고객 중단 2026-04-30, 유지보수 모드)
2. AWS account root user — Tasks that require root user credentials — https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html (2026-07 실측: Support 플랜 변경 항목 없음)
3. AWS announces updated Support Plans Console with new IAM controls (2022-09) — https://aws.amazon.com/about-aws/whats-new/2022/09/aws-updated-support-plans-console-new-iam-controls/
4. AWS KMS is now FIPS 140-3 Security Level 3 — https://aws.amazon.com/blogs/security/aws-kms-now-fips-140-2-level-3-what-does-this-mean-for-you/ (t2-2의 FIPS 140-3 L3 서술 이상 없음 확인)
5. AWS Trusted Advisor — https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor.html 및 re:Post Trusted Advisor 안내 (Basic/Developer = 서비스 한도 전체 + 보안·내결함성 일부 — t2-4 서술 이상 없음 확인)
