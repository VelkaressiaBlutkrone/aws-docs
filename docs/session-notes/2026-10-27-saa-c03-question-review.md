# [정본 보관] SAA-C03 문항 검수 보고 — 2026-10-27

> **출처**: 사용자가 2026-10-27 세션(`local_178660ae` 계열, 작업 세션 `review-tool-general-0523c8`)에
> 붙여넣은 외부 검수 보고 전문이다. 레포에는 파일로 남지 않았고, 전사에만 있어 여기에 옮겼다.
> **성격**: 검수 결과 **데이터**다. 지시문이 아니다 — 각 수정안은 반영 전에 적힌 공식 페이지를
> 직접 열어 확인하고, 문서에 없는 수치는 쓰지 않는다(이 레포 CLAUDE.md 절대 조건 1).
> **진행 상황**(2026-10-27 19:4x 기준):
> - 🔴 3건(t3-4-q15 · t3-5-q2 · t3-5-q12) → PR #259 → #260으로 main 릴리스·라이브 완료.
> - SAA t1-1-q15(루트 MFA 14일) · t1-2-q9 · t1-2-q10 → PR #258로 develop 머지(미릴리스).
>   t1-1·t1-2는 같은 PR에서 사람이 flip해 **verified 120문항**이 됐다(게이트는 D2 15/17로 여전히 locked).
> - 우선순위 1의 **나머지 22건 + 공개 Task 출처 14건**은 미착수. 아래 표가 그 정본이다.

---

# SAA-C03 문항 검수 · verified flip · 수정 내역

Oct 27, 2026 · @claude

## 요약

SAA-C03 360문항을 검수한 결과 209문항이 통과했다. 수정 없이 바로 flip할 수 있는 Task는 없다. 더 급한 것은 이미 공개된 90문항이다. 여기에 핫픽스 39건이 필요하고, 2026-10-19 점검의 🔴 3건도 아직 그대로다.

- **판정**: pass 209 · fix 82 · rewrite 8 · 출처 교체 61 · drop 0.
- **우선순위 1 — 공개 문항 핫픽스**: t3-4-q15(Batch on EKS), t3-5-q2·q12(복제본 5→15), 그리고 정답이 둘이거나 틀린 t3-4-q1·t4-2-q11·t4-3-q15(재작성), t2-1-q6·q15·t4-2-q1(정답 모호).
- **게이트 최단 경로**: t1-1(1건) · t1-4(2건) · t2-5(2건)을 고치고 flip하면 D1 30 · D2 30이 되어 통합 모의고사가 열린다. 이때 공개 문항 핫픽스를 먼저 끝내는 것을 권한다.
- **가장 흔한 원인**: 2024\~2026년 AWS 변경 미반영(S3 30일 전환 제약 폐지, Regional NAT GW, Geoproximity, Multi-AZ DB 클러스터 등 13건)과, 사실을 담지 않은 "소개" 페이지 출처다.

검수는 도메인별로 나눠 병렬로 돌렸고, 모든 결함은 공식 페이지를 열어 확인한 것만 적었다. 확인하지 못한 의심 사항은 "확인 필요" 목록에 따로 두었다. 이전 점검: 프로젝트 문서 `2026-10-19-clf-saa-question-audit.md`.

## 현황

SAA-C03은 24개 Task × 15문항 = 360문항이고, 그중 6개 Task 90문항이 이미 `verified:true`다. 게이트를 막는 것은 D1(0/19)과 D2(15/17)이며, D3·D4는 이미 충족했다.

| 도메인 | 공식 비중 | 필요(65문항 배분) | verified | 부족 | Task (✔ = verified) |
| --- | --- | --- | --- | --- | --- |
| D1 보안 아키텍처 | 30% | 19 | 0 | **19** | t1-1 · t1-2 · t1-3 · t1-4 · t1-5 |
| D2 복원력 아키텍처 | 26% | 17 | 15 | **2** | t2-1 ✔ · t2-2 · t2-3 · t2-4 · t2-5 |
| D3 고성능 아키텍처 | 24% | 16 | 45 | — | t3-1 · t3-2 ✔ · t3-3 · t3-4 ✔ · t3-5 ✔ · t3-6 · t3-7 · t3-8 · t3-9 |
| D4 비용 최적화 | 20% | 13 | 30 | — | t4-1 · t4-2 ✔ · t4-3 ✔ · t4-4 · t4-5 |

flip 단위가 Task(15문항)이므로, D1은 Task 2개(30문항), D2는 Task 1개(15문항)를 flip하면 게이트가 열린다. 이전 점검(2026-10-19)은 D3·D4 초안 135문항을 범위에서 뺐으므로, 이번 검수가 그 9개 Task의 첫 검토다.

**정답 쏠림 배지는 고치지 않는다.** t1-1·t2-1(idx1 15/15), t2-4·t3-1(13/15), t3-2·t3-3·t3-7(10/15)에 배지가 있지만, 앱이 모든 경로에서 보기를 섞으므로 학습자에게 보이지 않는다(루브릭 1-4번).

## verified flip 절차

SAA는 freeze 가드가 걸린 상태에서 `saa-review/*` 브랜치로만 작업하고, Task 15문항이 모두 통과하면 그 Task를 flip한다.

**착수 전 (1회)**

1. develop→main 릴리스로 검수 인프라가 main에 있는지 확인한다.
2. `git config core.hooksPath .githooks` → `touch .saa-frozen`. 이후 SAA 콘텐츠 변경은 `saa-review*` 브랜치에서만 된다.
3. `git checkout -b saa-review/d1` (D2는 `saa-review/d2`, 공개 문항 핫픽스는 `saa-review/hotfix`).

**Task마다**

1. 학습문서 선행 수정(T6): 이 문서의 수정 사항이 학습문서에서 온 오류라면 문서부터 고친다.
2. `cd flutter_app && node tool/saa_prescreen.mjs build` → 구조 플래그 확인(산출물은 커밋하지 않음).
3. `node tool/review.mjs build saa` → `build/saa_review/index.html`에서 아래 "수정 필요 문항 상세"를 반영한다.
4. 다시 `saa_prescreen.mjs build`로 구조 플래그 0 확인.
5. `node tool/review.mjs flip saa <taskId>` — `verified` 전환, `content_index` questionCount 동기화, `saa_questions_test`·`content_index_test` 실행. `--force`는 쓰지 않는다.
6. 커밋 메시지에 Task ID와 반영한 수정 문항 ID를 남긴다(승인 로그).

**이미 verified인 Task의 핫픽스**: 공개 문항은 학습자에게 이미 노출되므로 flip과 별도로 먼저 고친다. 수정 후 `saa_questions_test`·`content_index_test`만 다시 돌리면 된다.

**종료**: `certExamHasWeightedCapacity('SAA-C03')`가 true가 된 것을 확인하고 `rm .saa-frozen` → `saa-review/*` → develop PR → 릴리스. 약점 집중 모의고사는 비검토 응시 3회가 더 필요하다.

## Task별 판정표

360문항 중 209문항이 pass, 82문항이 fix, 8문항이 rewrite, 61문항이 출처 교체(resource)다. drop은 없다. **수정 없이 바로 flip할 수 있는 Task는 없다.** 이미 공개된 6개 Task(90문항)에도 39건의 핫픽스가 필요하다.

| Task | pass | fix | rewrite | resource | 판정 | 남은 작업 |
| --- | --- | --- | --- | --- | --- | --- |
| t1-1 IAM | 14 | 1 | 0 | 0 | 수정 후 flip | q15 한 문장(35일→14일) |
| t1-2 다중 계정 | 9 | 2 | 0 | 4 | 수정 후 flip | Control Tower 용어·LZ 4.0, 출처 4 |
| t1-3 VPC 보안 | 6 | 4 | 0 | 5 | 수정 후 flip | Regional NAT GW, Interface 엔드포인트, 출처 5 |
| t1-4 앱 보안 | 13 | 1 | 0 | 1 | 수정 후 flip | q2 Anti-DDoS 규칙, q7 출처 |
| t1-5 데이터 보안 | 12 | 3 | 0 | 0 | 수정 후 flip | q4 정답 보기, q7 ACM, q14 Blue/Green |
| t2-1 ✔ 느슨한 결합 | 9 | 5 | 0 | 1 | **핫픽스 6** | q6·q15 정답 모호(C1) 포함 |
| t2-2 서버리스 | 8 | 3 | 0 | 4 | 수정 후 flip | Lambda VPC ENI, Multi-AZ 클러스터, 출처 4 |
| t2-3 ELB+ASG | 10 | 1 | **2** | 2 | 재작성 후 flip | q4·q6 재작성 |
| t2-4 고가용성 | 10 | 5 | 0 | 0 | 수정 후 flip | Regional NAT GW, Multi-AZ 배포 유형, 교체 주체 |
| t2-5 DR | 13 | 1 | 0 | 1 | 수정 후 flip | q12 해설, q15 출처 |
| t3-1 S3 성능 | 6 | 5 | 0 | 4 | 수정 후 flip | 프리사인 URL 세션, BPA 평가, 출처 4 |
| t3-2 ✔ 블록·파일 | 8 | 3 | 0 | 4 | **핫픽스 7** | 스냅샷 AZ 복사, EFS IA 명칭 |
| t3-3 EC2 | 13 | 2 | 0 | 0 | 수정 후 flip | 오답 해설 2건(배치 그룹) |
| t3-4 ✔ 컨테이너·배치 | 11 | 3 | **1** | 0 | **핫픽스 4** | q15 Batch on EKS, q1 재작성 |
| t3-5 ✔ RDS·Aurora | 7 | 5 | 0 | 3 | **핫픽스 8** | q2·q12 복제본 5→15, gp3 크레딧 |
| t3-6 DynamoDB·캐시 | 6 | 4 | 0 | 5 | 수정 후 flip | AOF, q12 정답 모호 |
| t3-7 네트워크 성능 | 4 | 4 | **1** | 6 | 재작성 후 flip | Geoproximity "Traffic Flow 전용" 3문항 |
| t3-8 하이브리드 | 6 | 4 | **1** | 4 | 재작성 후 flip | q10 DXGW, "VPN over DX" 명칭 |
| t3-9 데이터 분석 | 12 | 1 | 0 | 2 | 수정 후 flip | q11 메모·계산, 출처 2 |
| t4-1 스토리지 비용 | 4 | 7 | **1** | 3 | 재작성 후 flip | S3 30일 제약 폐지(q4·q5) |
| t4-2 ✔ 컴퓨팅 비용 | 11 | 2 | **1** | 1 | **핫픽스 4** | q11·q1 정답 모호(C1) |
| t4-3 ✔ DB 비용 | 5 | 4 | **1** | 5 | **핫픽스 10** | 깨진 출처 6, q15 재작성 |
| t4-4 네트워크 비용 | 8 | 2 | 0 | 5 | 수정 후 flip | 해설 2, 요금 출처 5 |
| t4-5 비용 도구 | 4 | 10 | 0 | 1 | 수정 후 flip | CUR Parquet, Budget Actions, M2 4건 |

✔ = 이미 verified. 판정 카운트는 한 문항에 결함이 여럿이면 가장 무거운 것 하나(rewrite > fix > resource)로 셈다.

**작업량이 가장 적은 게이트 경로**: t1-1(1건) + t1-4(2건) → D1 30문항, t2-5(2건) → D2 30문항. 여섯 줄을 고치고 세 Task를 flip하면 통합 모의고사가 열린다. 단, 게이트를 열면 공개 문항이 더 많이 출제되므로 공개 Task 핫픽스(특히 다음 절의 우선순위 1)를 먼저 끝내는 것을 권한다.

## 수정 필요 문항 상세

수정은 우선순위 순서로 적었다. 출처 교체(resource) 61건은 맨 끝 표에 모았다. 수정안의 근거 URL은 검수 때 실제로 열어 확인한 공식 페이지다.

### 우선순위 1 — 이미 공개된 문항 (핫픽스 25건 + 출처 14건)

학습자에게 지금 노출되는 문항이다. 2026-10-19 점검의 🔴 3건을 포함해 그때 지적한 주요 14건 중 반영된 것은 3건(t2-1-q6 SQS 1 MiB, t4-3-q5 Database Savings Plans, t4-3-q13 Timestream)뿐이다.

| 문항 | 항목 | 판정 | 문제 | 수정안 |
| --- | --- | --- | --- | --- |
| t3-4-q15 🔴 | C3 | fix | \[3\] "EKS Fargate를 Compute Environment로 구성하는 것은 가능" | "AWS Batch on EKS는 EC2(온디맨드·스팟)만 지원하며, Fargate는 ECS 컴퓨팅 환경에서만 쓸 수 있습니다." [출처](https://docs.aws.amazon.com/batch/latest/userguide/eks.html) |
| t3-5-q2 🔴 | C2 | fix | 해설 "RDS는 최대 5개" | "RDS for MySQL·MariaDB·PostgreSQL은 소스당 최대 15개, Aurora는 클러스터당 최대 15개." [출처](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_MySQL.Replication.ReadReplicas.html) |
| t3-5-q12 🔴 | C1·C3 | fix | \[1\] "RDS MySQL은 최대 5개"로 참인 보기 B를 반박 → B·C 구분 불가 | 지문에 "페일오버 시간 최소화"를 추가, \[1\]을 "복제본 수는 같고, 3 AZ 공유 스토리지·통상 60초 미만 페일오버가 없다"로 |
| t3-4-q1 | C1·C5 | **rewrite** | "Fargate → EKS → ECS EC2" 운영 부담 순서가 논쟁적 | EKS를 빼고 "Lambda → ECS on Fargate → ECS EC2 → EC2" 4단계로 재구성 |
| t4-2-q11 | C1 | **rewrite** | "평일 낮 높고 야간·주말 낮은" 패턴은 공식 문서가 Predictive Scaling 예시로 드는 그대로라 D도 정답 | 보기 D를 Simple Scaling으로 교체, 또는 지문을 "매주 월 09:00 정기 배치"로. [출처](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html) |
| t4-3-q15 | C1·C2 | **rewrite** | 정답 A와 오답 D가 둘 다 "서버 교체 없이"를 근거로 들고, "공유 스토리지 때문"이라는 인과는 문서에 없음 | "대부분의 스케일링이 같은 호스트에서 이뤄져 최소 0.5 ACU 단위로 중단 없이 바뀐다"를 묻는 문항으로 재작성 |
| t4-2-q1 | C1 | fix | Spot도 공식적으로 개발·테스트 적합 → C도 정답 | 지문에 "중단되면 처음부터 다시 해야 해 중단을 허용할 수 없다" 추가 |
| t2-1-q6 | C1 | fix | 보기 D "SQS는 이메일·SMS 전송 기능이 없다"도 참 | D를 거짓 진술("소비자를 하나만 등록할 수 있다")로 교체 |
| t2-1-q15 | C1 | fix | 배치를 쓰면 기본 FIFO로도 초당 500건 충족. 해설만 고치고 지문은 그대로 | 지문을 "배치를 사용하지 않고 SendMessage를 초당 500회 호출"로 |
| t2-1-q7 | C3 | fix | \[3\] "소비자별 재시도·DLQ에는 SQS가 필요" — EventBridge도 대상별 재시도·DLQ 지원 | 지문에 "소비자가 자기 속도로 가져간다" 추가, \[3\]을 "EventBridge 재시도는 전달 실패용, 내구성 버퍼는 SQS"로 |
| t2-1-q9 | C3 | fix | \[2\] "SNS는 구독자 측 자체 필터링 필요" | "SNS도 구독 필터 정책이 있지만, AWS 서비스 이벤트를 패턴으로 직접 매칭하는 기본 경로는 EventBridge" |
| t2-1-q11 | C2·C3 | fix | "Express는 콘솔에서 조회 불가" — 로깅을 켜면 가능 | 지문을 "별도 로깅 설정 없이 보관되는 실행 이력"으로, \[2\]·\[3\]을 "Express는 로깅을 켜야 이력 조회 가능"으로 |
| t3-5-q6 | C1 | fix | "일반 RDS Multi-AZ"가 배포 유형 미지정. DB 클러스터는 보통 35초 미만 페일오버. 정답 길이 단서 | 지문을 "Multi-AZ DB 인스턴스 배포(스탠바이 1개)"로 한정, 오답 길이 맞춤 |
| t3-5-q11 | C2·C5 | fix | gp3에 버스트 크레딧이 있다고 서술, Magnetic을 "신규 사용 비권장"으로 | 보기 B·해설을 gp2로 한정, "Magnetic은 사용 중단되어 신규 인스턴스에 제공되지 않음" |
| t4-3-q9 | C2·C1 위험 | fix | 지문은 규칙적 패턴인데 해설은 "불규칙" — q10과 충돌 | 지문에 "피크 시각과 규모가 날마다 크게 달라 예측이 어렵다" 추가 |
| t3-2-q7 · q14 | C2·C3 | fix | "스냅샷을 다른 AZ로 복사" — 스냅샷은 리전 리소스 | "같은 리전 어느 AZ에서든 복원, 다른 리전으로는 복사" |
| t3-2-q15 | C5 | fix | EFS "Standard-IA"는 옛 명칭, One Zone은 파일 시스템 유형 | "Infrequent Access(IA)"로, 보기 A를 "One Zone 파일 시스템을 새로 만들어 옮긴다"로 |
| t3-4-q2 | M2·C2 | fix | "문서에 없습니다" 메타 2건, Lambda 15분 단정 | 메타 삭제, "표준 Lambda는 최대 900초(Lambda Managed Instances의 비동기 호출은 최대 90분)" |
| t3-4-q7 | C3 | fix | \[0\] "Job Definition은 ECS 리소스" — Batch 구성요소 | \[0\]·\[2\]·해설에 Job Definition = Batch 구성요소로 정정 |
| t3-5-q5 | C2·M2 | fix | "최대 128TiB, 공식 문서 기준 256TiB" 혼재 | "엔진 버전에 따라 최대 256TiB(이전 버전 128TiB)" |
| t4-3-q6 | C3 | fix | \[2\] "Aurora 최대 128TB, 10GB 단위" | "엔진 버전에 따라 128TiB 또는 256TiB" |
| t4-3-q7 | C3 | fix | \[1\] "Multi-AZ 스탠바이는 읽기 처리 안 함" — DB 클러스터는 처리 | "Multi-AZ DB 인스턴스 배포의 스탠바이"로 한정 |
| t4-3-q1 | C2 | fix | 0 ACU 자동 일시정지 미반영 | "최소 0 ACU면 유휴 시 일시정지되어 컴퓨팅 요금 0" 추가 |
| t4-2-q12 | C3 | fix | \[0\] "권장만 제안" — 2025-11 자동화 규칙 미반영 | "인스턴스 크기는 자동 변경하지 않음. 2025-11부터 EBS 정리·유형 업그레이드만 자동 적용 가능" |

t4-3의 출처 `rds-reserved-instances.html` 6건(q5·q6·q7·q11·q12·q14)은 현재 UserGuide 루트로 리디렉트되는 깨진 링크다. 나머지 공개 문항 출처 교체는 맨 끝 표에 있다.

### 우선순위 2 — 게이트용 D1·D2 초안 (fix 21건 + rewrite 2건)

게이트를 막고 있는 D1·D2 초안이다. t1-1·t1-4·t2-5는 각각 1\~2건만 고치면 flip할 수 있다.

| 문항 | 항목 | 판정 | 문제 | 수정안 |
| --- | --- | --- | --- | --- |
| t1-1-q15 | C2 | fix | 루트 MFA 등록 유예 "35일" | "찫 로그인 시도 후 14일". [출처](https://docs.aws.amazon.com/IAM/latest/UserGuide/root-user-best-practices.html) |
| t1-2-q9 | C3·C5 | fix | \[0\] "SCP는 IAM API 호출을 차단", "가드레일" 옛 용어 | "예방적 제어는 SCP·RCP로 구현해 금지된 API 작업을 거부", 지문은 "제어(control, 이전 명칭 가드레일)" |
| t1-2-q10 | C3·C5 | fix | \[3\] "Control Tower가 OU·SCP·Identity Center를 자동 구성" — 랜딩 존 4.0부터 선택 | "랜딩 존 4.0부터 Identity Center 등 서비스 통합과 Security OU는 선택 사항" |
| t1-3-q7 | C2·C5 | fix | "NAT GW는 퍼블릭 서브넷에 배치" — 2025-11 Regional NAT GW는 불필요 | 지문을 "영역형(zonal) 퍼블릭 NAT GW"로 한정, 해설에 Regional NAT GW 참고 추가 |
| t1-3-q9 | C3 | fix | \[0\] NAT 경유 S3 트래픽이 "인터넷"을 경유 — AWS 네트워크를 벗어나지 않음 | "퍼블릭 엔드포인트 경로(AWS 네트워크는 벗어나지 않음)이며 NAT 요금이 발생" |
| t1-3-q10 | C3 | fix | \[2\]·\[3\] S3·DynamoDB가 Interface 엔드포인트를 지원하지 않는 것처럼 읽힘(q9와 모순) | "두 서비스는 Gateway와 Interface 엔드포인트를 모두 지원" |
| t1-3-q13 | C2 | fix | Flow Logs 대상에 Data Firehose 누락 | 보기 D·해설에 "CloudWatch Logs·S3·Data Firehose" |
| t1-4-q2 | C3 | fix | \[1\] "WAF는 DDoS 자동 완화 서비스가 아님" — Anti-DDoS 관리형 규칙 그룹 있음 | "웹 ACL을 구성해야 동작하는 유료 서비스라 추가 설정 없이 자동 적용되지 않음" |
| t1-5-q4 | C1·C2 | fix | 해설은 고쳤지만 정답 보기 B가 여전히 "키 정책에 역할이 명시적으로 허용돼야" | B: "키 정책이 역할을 직접 허용하지 않고 IAM 정책 위임 문장도 없어 IAM 정책의 Allow가 효력을 갖지 못한다" |
| t1-5-q7 | C2 | fix | 갱신 적격에 "내보낸 인증서" 누락, 유효기간 198일 미반영 | "AWS 서비스에 연결돼 있거나 내보낸 인증서", "(198일 인증서 기준) 만료 45일 전". [출처](https://docs.aws.amazon.com/acm/latest/userguide/dns-renewal-validation.html) |
| t1-5-q14 | C2 | fix | "유일한 경로는 스냅샷 경유" — Blue/Green으로도 암호화 가능 | "대표 경로는 스냅샷 경유, 또는 Blue/Green에서 green에 TargetKmsKeyId 지정" |
| t2-2-q2 | C3 | fix | \[2\] "VPC 연결 시 ENI 생성으로 콜드 스타트가 길어진다" — 2019년 이전 모델 | "ENI는 함수 생성·VPC 설정 시점에 미리 만들어지므로 콜드 스타트 대책이 아님" |
| t2-2-q6 | C3 | fix | \[3\] "스탠바이는 읽기 분산 안 함" — DB 클러스터는 처리 | "Multi-AZ DB 인스턴스 배포는 커넥션 풀링을 제공하지 않음"으로 한정 |
| t2-2-q15 | C3 | fix | \[0\] "인터넷 접근은 NAT GW·VPC 엔드포인트로" — 엔드포인트는 인터넷 경로가 아님 | "외부 인터넷은 NAT GW, AWS 서비스는 VPC 엔드포인트" |
| t2-3-q4 | C1 | **rewrite** | 정답 "ALB 교차 영역은 기본 활성이므로 원인 아님" — 대상 그룹 수준에서 끌 수 있어 맞는 보기 없음 | "대상 그룹에서 교차 영역을 끈 2/8 배치에서 AZ-a 인스턴스의 트래픽 비율(각 25%)"을 묻는 문항으로 |
| t2-3-q6 | C1 | **rewrite** | 스티키 대상이 비정상이면 ALB는 새 대상으로 재라우팅하는데 정답이 반대로 설명 | D: "새 대상으로 다시 라우팅하지만 종료된 인스턴스의 세션 데이터는 사라진다", C는 명확한 거짓으로. [출처](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/sticky-sessions.html) |
| t2-3-q12 | C3 | fix | \[2\] "NLB는 HTTP 500을 감지하지 않음" — NLB도 HTTP 헬스 체크 지원 | "NLB도 감지하지만, 교체는 ASG 헬스 체크 유형에 ELB를 켜야 일어난다" |
| t2-4-q2 | C3 | fix | \[1\] "AZ마다 NAT GW를 배치해야" | "AZ마다 영역 NAT GW를 두거나 Regional NAT GW를 사용" |
| t2-4-q4 · q6 | C1 | fix | "RDS Multi-AZ"가 배포 유형 미지정 — DB 클러스터는 반동기 복제·읽기 가능 | 지문을 "Multi-AZ DB 인스턴스 배포(단일 스탠바이)"로 한정 |
| t2-4-q11 | C1 | fix | "NAT GW는 다중 AZ를 지원하지 않음" — Regional NAT GW면 보기 A가 참 | 지문을 "영역(zonal) NAT GW를 AZ-a에만"으로. [출처](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html) |
| t2-4-q13 | C2·C3 | fix | 정답 "ALB 헬스 체크가 인스턴스 교체" — 교체는 ASG | "ALB는 라우팅에서 제외, 교체는 ELB 헬스 체크를 쓰는 ASG" |
| t2-5-q12 | C2 | fix | "DB 데이터만 복제" — DRS는 서버 전체를 블록 레벨 복제 | "서버 디스크 복제본과 꺼진 리소스를 스테이징 영역에 유지", DR 백서 출처 추가 |

### 우선순위 3 — D3·D4 초안 (fix 39건 + rewrite 3건)

D3·D4는 게이트를 이미 충족했으므로 품질을 위한 작업이다.

| 문항 | 항목 | 판정 | 문제 | 수정안 |
| --- | --- | --- | --- | --- |
| t3-1-q1 | C2 | fix | "모든 클래스 11 nine" — RRS는 99.99% | "현재 권장되는 모든 클래스" |
| t3-1-q4 | C1·C3 | fix | "수 분 이내" — Flexible Retrieval 신속 검색(1\~5분)도 충족. Deep Archive "최대 12시간" | 지문을 "복원 절차 없이 밀리초 단위"로, "표준 12시간·대량 48시간 이내" |
| t3-1-q7 | M2 | fix | "학습 문서의 예시와 정확히 일치" | 삭제 |
| t3-1-q11 | C3 | fix | 공식 문서에 없는 평가 순서, BPA가 IAM 정책에도 작용하는 것처럼 읽힘 | "BPA는 리소스 정책·ACL을 통한 공개 접근을 차단" |
| t3-1-q13 | C2 | fix | 역할로 서명한 URL은 세션 만료 시 무효 | "URL 만료와 서명 역할 세션 만료 중 이른 시점까지 유효" |
| t3-3-q11 | C3 | fix | 분산 배치 그룹을 단일 AZ로 가정 | "AZ마다 최대 7개(3 AZ면 21개)" |
| t3-3-q12 | C3 | fix | "배치 그룹은 전용 인스턴스와 사용 불가" — 파티션은 가능 | "분산 배치 그룹은 전용 인스턴스를 지원하지 않음" |
| t3-6-q9 | C3 | fix | "CloudFront는 정적 콘텐츠 캐시" | "정적·동적 가속은 가능하지만 쓰기는 단일 리전 DynamoDB까지 간다" |
| t3-6-q11 | C2 | fix | 금융 거래 = RDS 신호 — DynamoDB도 ACID 트랜잭션 | "금융 거래 여부는 결정 신호가 아님" |
| t3-6-q12 | C1 | fix | 지문 조건만으로 DynamoDB도 정답 | 지문에 "서브밀리초 인메모리" 추가, Memcached 서술을 노드 기반으로 한정 |
| t3-6-q13 | C2 | fix | "Redis는 RDB와 AOF로 영속성" — ElastiCache는 2.8.22부터 AOF 미지원 | "복제·Multi-AZ·스냅샷으로 보존, 진짜 영속은 MemoryDB" |
| t3-7-q6 | C1 | **rewrite** | 정답 "Geoproximity는 Traffic Flow에서만" — 2024-01부터 일반 레코드 지원, 맞는 보기 없음 | 정답을 "리소스 위치 + bias(-99\~99)"로. [출처](https://aws.amazon.com/about-aws/whats-new/2024/01/amazon-route-53-expands-geoproximity-routing) |
| t3-7-q1 · q5 | C3 | fix | 오답 해설에 같은 "Traffic Flow 전용" 서술 | 해당 문구 삭제 |
| t3-7-q3 | C2 | fix | "헬스 체크는 필수" — 별칭 대상은 Evaluate Target Health | 지문을 비별칭 레코드로 한정, 해설에 예외 추가 |
| t3-7-q11 | C3 | fix | "CloudFront는 고정 IP 없음" — Anycast 고정 IP 기능 있음 | "기본은 가변 IP, 고정 IP 기능도 HTTPS용이라 UDP에는 못 씀" |
| t3-8-q10 | C1 | **rewrite** | DXGW 슈퍼넷 광고(2021-11\~)로 VPC 간 통신 가능 — C도 정답, "hair-pinning 불가"도 틀림 | C를 존재하지 않는 기능으로 교체, 해설에 예외 명시 |
| t3-8-q2 | C1·C5 | fix | "온프레미스를 피어링만으로" — 전제 불성립 | 지문을 "VPC 10개 완전 메시"로 |
| t3-8-q6 · q7 · q9 | C2 | fix | "DX over VPN" 명칭이 거꾸로 | "VPN over DX", MACsec 대안 추가 |
| t3-9-q11 | M2·C5 | fix | 메타 문장 노출, "1 Gbps로 500 TB는 수개월"(실제 약 46일) | 메타 삭제, "가용 대역폭 약 200 Mbps"로 |
| t4-1-q5 | C1 | **rewrite** | "20일에 전환해도 30일분 청구" — 최소 보관은 전환 후부터, 2026-07-16 30일 전환 제약 폐지 | "전환 후 10일 안에 삭제되면 30일분 청구"를 묻는 문항으로. [출처](https://aws.amazon.com/about-aws/whats-new/2026/07/s3-removes-30-day-transitions-standard-ia-one-zone-ia/) |
| t4-1-q4 | C3 | fix | \[0\] "Day 15 전환 시 최소 보관 미충족", Deep Archive "최대 12시간" | 전환 제약 폐지 반영, "표준 12시간·대량 48시간" |
| t4-1-q1 · q3 · q6 · q8 | C2·C3 | fix | S3 요금 "세 축", Bulk 검색 무료 누락, Deep Archive 12시간, EBS 삭제 기본값 단순화 | 각 문장 정정(대량 검색 무료, 48시간, AMI 설정 따름) |
| t4-1-q9 | C2 | fix | "Cost Explorer도 미연결 볼륨 식별" — Cost Explorer rightsizing은 EC2만 | "Trusted Advisor 또는 Compute Optimizer(유휴 권장)" |
| t4-1-q14 | M2 | fix | "문서에서 설명하는 방법이 아님", S3 출처로 EFS 문항 | 메타 삭제, EFS 수명주기 문서로 |
| t4-4-q6 | C2 | fix | "Interface Endpoint를 쓸 이유가 없음" — 온프레미스·타 리전은 필요 | "같은 리전 VPC 안이면 Gateway가 유리" |
| t4-4-q12 | C2 | fix | "GB당 총비용"인데 한 방향만 계산 | 지문을 "송신 측 1 GB 기준"으로 |
| t4-5-q2 | C2 | fix | Budget Actions를 "IAM·SNS·SSM"으로 | "IAM 정책 적용, SCP 적용, EC2·RDS 인스턴스 중지" |
| t4-5-q3 · q9 | C2 | fix | "CUR(S3 CSV) → Athena" — Athena 통합은 Parquet만 | "CUR(Parquet) → Athena". [출처](https://docs.aws.amazon.com/cur/latest/userguide/cur-query-athena.html) |
| t4-5-q5 · q12 · q13 · q15 | M2 | fix | "(게이트 검수 반영: 2026-06-12)" 라벨, "이 문서에서 언급되지 않습니다" | 메타 삭제. q13은 "backfill은 관리 계정이 요청"으로 사실도 정정 |
| t4-5-q7 | C3 | fix | "Compute Optimizer는 유휴 EBS 탐지 안 함" | "유휴·미연결 EBS는 권장하지만 LB는 안 함" |
| t4-5-q8 | C3 | fix | 원칙명 "Practice cloud financial management" | "Implement cloud financial management" |
| t4-5-q14 | C3 | fix | "Well-Architected 5개 기둥" | 6개(지속 가능성 포함) |

### 출처 교체 (resource 61건)

사실은 맞지만 인용한 페이지가 그 사실을 담고 있지 않다. 대부분 서비스 "소개(welcome·what-is)" 페이지를 출처로 쓴 경우다. ✔는 공개 문항이다.

| Task | 문항 → 교체할 공식 페이지 |
| --- | --- |
| t1-2 | q11 [Control Tower 공유 계정](https://docs.aws.amazon.com/controltower/latest/userguide/special-accounts.html) · q12 [Organizations 전체 기능](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_org_support-all-features.html) · q13·q14 [Identity Center 권한 세트](https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html) |
| t1-3 | q1 [서브넷](https://docs.aws.amazon.com/vpc/latest/userguide/configure-subnets.html) · q2 [서브넷 크기](https://docs.aws.amazon.com/vpc/latest/userguide/subnet-sizing.html) · q8 [NAT GW](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html) · q11·q15 [VPC 피어링 기본](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html) |
| t1-4 | q7 [Firewall Manager](https://docs.aws.amazon.com/waf/latest/developerguide/fms-chapter.html) |
| t2-1 ✔ | q5 [SQS 롱·숏 폴링](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-short-and-long-polling.html) |
| t2-2 | q1 [Lambda 비동기 오류 처리](https://docs.aws.amazon.com/lambda/latest/dg/invocation-async-error-handling.html) · q5 [실행 역할](https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html) · q8 [REST vs HTTP API](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html) · q10 [사용량 계획](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-api-usage-plans.html) |
| t2-3 | q8 [대상 추적](https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-scaling-target-tracking.html) · q9 [예측 조정](https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html) |
| t2-5 | q15 [DR 백서](https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html) |
| t3-1 | q8 [객체 업로드](https://docs.aws.amazon.com/AmazonS3/latest/userguide/upload-objects.html) · q12 [OAC](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html) · q14 [복제 요건](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-requirements.html) · q15 [Batch Replication](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-batch-replication-batch.html) |
| t3-2 ✔ | q1 [EFS](https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html) · q5 [Multi-Attach](https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volumes-multi.html) · q6 [인스턴스 스토어 수명](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-store-lifetime.html) · q13 [FSx for ONTAP](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/what-is-fsx-ontap.html) |
| t3-5 ✔ | q7 [Aurora Global Database](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database.html) · q8 [Aurora Serverless v2](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html) · q14 [특정 시점 복구](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html) |
| t3-6 | q2 [파티션 키 설계](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/bp-partition-key-uniform-load.html) · q5 [프로비저닝 용량](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/provisioned-capacity-mode.html) · q10 [TTL](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/TTL.html) · q14·q15 [캐싱 전략](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/Strategies.html) |
| t3-7 | q2 [별칭 레코드](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html) · q7 [OAC](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html) · q8 [서명 URL·쿠키](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-choosing-signed-urls-cookies.html) · q9 [대체 도메인 HTTPS](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/cnames-and-https-requirements.html) · q13 [NLB](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/introduction.html) · q15 [ALB](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html) |
| t3-8 | q1 [VPC 피어링 기본](https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html) · q11 [게이트웨이 엔드포인트](https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html) · q12 [VPC 연결 옵션 — PrivateLink](https://docs.aws.amazon.com/aws-technical-content/latest/aws-vpc-connectivity-options/aws-privatelink.html) · q13 [엔드포인트 서비스 생성](https://docs.aws.amazon.com/vpc/latest/privatelink/create-endpoint-service.html) |
| t3-9 | q3 [KDS 핵심 개념](https://docs.aws.amazon.com/streams/latest/dev/key-concepts.html) · q15 [Kinesis Video Streams](https://docs.aws.amazon.com/kinesisvideostreams/latest/dg/what-is-kinesis-video.html) |
| t4-1 | q10 [NAT GW 요금](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-pricing.html) · q12 [S3 요금](https://aws.amazon.com/s3/pricing/)·[CloudFront 요금](https://aws.amazon.com/cloudfront/pricing/) · q15 [미완료 멀티파트 삭제](https://docs.aws.amazon.com/AmazonS3/latest/userguide/mpu-abort-incomplete-mpu-lifecycle-config.html) |
| t4-2 ✔ | q13 Lambda 요금 페이지(교체 후보 미확인) |
| t4-3 ✔ | q5 [RDS 예약 인스턴스](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithReservedDBInstances.html) · q11 [RDS 요금](https://aws.amazon.com/rds/pricing/) · q12 RDS 스냅샷 삭제 문서 · q13 [Timestream LiveAnalytics 가용성 변경](https://docs.aws.amazon.com/timestream/latest/developerguide/AmazonTimestreamForLiveAnalytics-availability-change.html) · q14 [Compute Optimizer](https://docs.aws.amazon.com/compute-optimizer/latest/ug/what-is-compute-optimizer.html) |
| t4-4 | q1·q2 [EC2 온디맨드 요금(Data Transfer)](https://aws.amazon.com/ec2/pricing/on-demand/) · q10·q11 [Transit Gateway 요금](https://aws.amazon.com/transit-gateway/pricing/) · q15 [RDS 요금](https://aws.amazon.com/rds/pricing/) |
| t4-5 | q6 [통합 결제](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/consolidated-billing.html) |

## 출처 재확인 목록

결함의 대부분은 2024\~2026년 AWS 변경이 해설에 반영되지 않은 것이다. 같은 변경이 여러 문항에 걸려 있으므로, 변경 단위로 한 번에 고치는 것이 빠르다.

| 변경 | 시점 | 영향 문항 | 근거 |
| --- | --- | --- | --- |
| S3 Standard-IA·One Zone-IA 전환의 30일 대기 제약 폐지 | 2026-07-16 | t4-1-q4·q5 | [What's New](https://aws.amazon.com/about-aws/whats-new/2026/07/s3-removes-30-day-transitions-standard-ia-one-zone-ia/) |
| Regional NAT Gateway(퍼블릭 서브넷 불필요, AZ 자동 확장) | 2025-11 | t1-3-q7, t2-4-q2·q11 | [Regional NAT GW](https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html) |
| Route 53 Geoproximity를 일반 레코드에서 설정 | 2024-01 | t3-7-q1·q5·q6 | [What's New](https://aws.amazon.com/about-aws/whats-new/2024/01/amazon-route-53-expands-geoproximity-routing) |
| ALB 대상 그룹 단위 교차 영역 끄기 | 2022-11 | t2-3-q4 | [What's New](https://aws.amazon.com/about-aws/whats-new/2022/11/application-load-balancers-turning-off-cross-zone-load-balancing-per-target-group) |
| RDS Multi-AZ DB 클러스터(읽기 가능 스탠바이, 반동기) | — | t2-2-q6, t2-4-q4·q6, t3-5-q6, t4-3-q7 | [Multi-AZ DB 클러스터](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html) |
| RDS 읽기 복제본 최대 15개 | — | t3-5-q2·q12 | [RDS Read Replicas](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_MySQL.Replication.ReadReplicas.html) |
| Aurora 최대 256TiB(엔진 버전별) | 2025-07 | t3-5-q5, t4-3-q6 | [What's New](https://aws.amazon.com/about-aws/whats-new/2025/07/amazon-aurora-mysql-database-clusters-256-tib-storage/) |
| Aurora Serverless v2 0 ACU 자동 일시정지 | — | t4-3-q1 | [auto-pause](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2-auto-pause.html) |
| Lambda Managed Instances 비동기 호출 최대 90분 | — | t3-4-q2 (q4·q8·q13은 표현 검토) | [Lambda timeout](https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html) |
| ACM 인증서 198일, 만료 45일 전 갱신 | — | t1-5-q7 | [DNS 갱신](https://docs.aws.amazon.com/acm/latest/userguide/dns-renewal-validation.html) |
| 루트 MFA 등록 유예 14일 | — | t1-1-q15 | [루트 사용자 모범 사례](https://docs.aws.amazon.com/IAM/latest/UserGuide/root-user-best-practices.html) |
| Control Tower 랜딩 존 4.0, "가드레일→제어" | — | t1-2-q8·q9·q10 | [LZ 4.0 변경점](https://docs.aws.amazon.com/controltower/latest/userguide/key-changes-lz-v4.html) |
| Compute Optimizer 자동화 규칙·유휴 EBS 권장 | 2025-11 | t4-2-q12, t4-1-q9, t4-5-q7 | [유휴 권장](https://docs.aws.amazon.com/compute-optimizer/latest/ug/view-idle-recommendations.html) |

이 중 가장 예상 밖이던 네 건(S3 30일 제약 폐지, Lambda Managed Instances 90분, ACM 198일, 루트 MFA 14일)은 검수 후 공식 페이지를 다시 열어 교차 확인했다.

**확인 필요 (결함으로 집계하지 않음)**

- [ ] t2-1-q12 Step Functions 처리량 수치(2,000/100,000) — welcome 표와 쿼터 페이지가 다르다. 수치를 빼는 쪽이 안전하다.
- [ ] t2-2-q3 "Durable functions…" 문장이 작성자 메모처럼 읽힌다(M2 경계).
- [ ] t2-3-q11 수명 주기 훅 "최대 48시간" — 쿼터 페이지로 확인.
- [ ] t3-5-q1 페일오버 "약 1\~2분", t3-5-q7 "RPO 1초·RTO 1분", t3-5-q14 "보존 0\~35일" — 인용 페이지에 수치 없음.
- [ ] t3-6-q6 온디맨드 "스로틀 없이" — 이전 피크 2배 초과 시 스로틀 가능성.
- [ ] t3-8-q12 \[0\] TGW 중복 CIDR 전파 동작.
- [ ] t1-5-q5 "KMS HSM은 공용 플릿" — 문서는 "단일 테넌트가 아님"까지만 말한다.
- [ ] t1-4-q4·q12·q14 WAF 연결 가능 리소스 9종 — 지금은 일치, flip 직전 다시 확인.
- [ ] t4-1-q13 Storage Lens 권장이 고급 티어 전용인지, t4-3-q8 콘솔 기본 최솟값 0.5 ACU, t4-3-q14 Compute Optimizer RDS 메모리 분석.
- [ ] t4-3-q13 Timestream이 SAA-C03 범위 목록에 있는지(C5).
- [ ] t4-4 전반 가격 수치에 "(미국 동부 기준)"을 붙일지.
- [ ] 표기 정책: "ElastiCache for Redis" → 엔진명 Valkey·Redis OSS 병기 여부, "GLB" vs "GWLB" 약어.

## 중복·겹침 문항

거의 같은 문항이 6쌍 있다. flip을 막지는 않지만, 한 모의고사에 함께 뽑히면 같은 문제를 두 번 푼다. 한쪽을 다른 사실로 교체하는 것을 권한다.

| 문항 | 공통 사실 | 메모 |
| --- | --- | --- |
| t1-1-q8 · t1-2-q2 | SCP는 권한을 부여하지 않고 멤버 계정 루트에도 적용 | 지문·보기·해설이 거의 같음 (이전 점검 지적, 미반영) |
| t1-1-q9 · t1-2-q5 | SCP와 권한 경계는 둘 다 상한선 | 보기 구성까지 같음 (미반영) |
| t2-4-q7 · t2-4-q14 | 읽기 복제본은 수동 승격, Multi-AZ는 자동 페일오버 | 같은 Task 안 |
| t3-5-q3 · t3-5-q15 | Multi-AZ = 동기 HA, 읽기 복제본 = 비동기 확장 | q1·q2까지 네 문항이 같은 사실 |
| t4-1-q10 · t4-4-q4 | 프라이빗 서브넷→S3는 Gateway Endpoint로 NAT 요금 회피 | 도메인 안 다른 Task |
| t4-5-q5 · t4-5-q13 | 비용 할당 태그 backfill 최대 12개월 | q5 해설에 q13 정답이 그대로 들어 있음 |

같은 사실을 여러 문항이 반복하는 묶음은 더 많다(예: 스팟 2분 경고, 분산 배치 그룹 AZ당 7개, Gateway Endpoint 무료, Pilot Light 정의, Cognito User Pool→Identity Pool). Task 문서의 핵심 사실을 강조하는 구성이면 두어도 되지만, 한 Task 안에서 정답만 뒤집어 출제한 쌍(t3-6-q14·q15 Lazy Loading/Write-Through, t3-7-q1·q5 Latency/Geolocation)은 서로 답을 알려 준다.

**범위(C5) 메모**: SAA-C03 후속 시험은 아직 공식 공지가 없다(2026-10-19 점검 기준). 범위 밖으로 판정한 문항은 없고, Timestream(t4-3-q13)만 범위 목록 확인이 남아 있다.

---

# (추가) 우선순위 1 잔여 작업표 — 22문항 + 출처 14건

> 위 보고의 "우선순위 1" 표를 작업 단위로 다시 묶은 것이다(내용은 그대로, 순서만 바꿨다).
> 🔴 3건(t3-4-q15 · t3-5-q2 · t3-5-q12)은 PR #259 → #260으로 **완료·라이브**라 빠졌다.
> `근거`가 "표에 없음"인 항목은 검수 보고가 URL을 적지 않았다 — **직접 공식 페이지를 열어 확인**한다.

## A. 재작성 3건 (rewrite)

| 문항 | 항목 | 문제 | 수정안 | 근거 |
| --- | --- | --- | --- | --- |
| t3-4-q1 | C1·C5 | "Fargate → EKS → ECS EC2" 운영 부담 순서가 논쟁적(공식 근거 없음) | EKS를 빼고 "Lambda → ECS on Fargate → ECS EC2 → EC2" 4단계로 재구성 | 표에 없음 |
| t4-2-q11 | C1 | "평일 낮 높고 야간·주말 낮은" 패턴은 공식 문서가 Predictive Scaling 예시로 드는 그대로라 D도 정답 | 보기 D를 Simple Scaling으로 교체, 또는 지문을 "매주 월 09:00 정기 배치"로 | https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-predictive-scaling.html |
| t4-3-q15 | C1·C2 | 정답 A와 오답 D가 둘 다 "서버 교체 없이"를 근거로 들고, "공유 스토리지 때문"이라는 인과는 문서에 없음 | "대부분의 스케일링이 같은 호스트에서 이뤄져 최소 0.5 ACU 단위로 중단 없이 바뀐다"를 묻는 문항으로 재작성 | 표에 없음 |

## B. 정답이 둘이 되는 3건 (C1 — 가장 급함)

| 문항 | 문제 | 수정안 | 근거 |
| --- | --- | --- | --- |
| t2-1-q6 | 보기 D "SQS는 이메일·SMS 전송 기능이 없다"도 참 | D를 거짓 진술("소비자를 하나만 등록할 수 있다")로 교체 | 표에 없음 |
| t2-1-q15 | 배치를 쓰면 기본 FIFO로도 초당 500건 충족. 해설만 고치고 지문은 그대로 | 지문을 "배치를 사용하지 않고 SendMessage를 초당 500회 호출"로 | 표에 없음 |
| t4-2-q1 | Spot도 공식적으로 개발·테스트 적합 → C도 정답 | 지문에 "중단되면 처음부터 다시 해야 해 중단을 허용할 수 없다" 추가 | 표에 없음 |

## C. 해설·오답 정정 16건 (fix)

| 문항 | 항목 | 문제 | 수정안 | 근거 |
| --- | --- | --- | --- | --- |
| t2-1-q7 | C3 | [3] "소비자별 재시도·DLQ에는 SQS가 필요" — EventBridge도 대상별 재시도·DLQ 지원 | 지문에 "소비자가 자기 속도로 가져간다" 추가, [3]을 "EventBridge 재시도는 전달 실패용, 내구성 버퍼는 SQS"로 | 표에 없음 |
| t2-1-q9 | C3 | [2] "SNS는 구독자 측 자체 필터링 필요" | "SNS도 구독 필터 정책이 있지만, AWS 서비스 이벤트를 패턴으로 직접 매칭하는 기본 경로는 EventBridge" | 표에 없음 |
| t2-1-q11 | C2·C3 | "Express는 콘솔에서 조회 불가" — 로깅을 켜면 가능 | 지문을 "별도 로깅 설정 없이 보관되는 실행 이력"으로, [2]·[3]을 "Express는 로깅을 켜야 이력 조회 가능"으로 | 표에 없음 |
| t3-2-q7 | C2·C3 | "스냅샷을 다른 AZ로 복사" — 스냅샷은 리전 리소스 | "같은 리전 어느 AZ에서든 복원, 다른 리전으로는 복사" | 표에 없음 |
| t3-2-q14 | C2·C3 | (q7과 같은 결함) | (q7과 같은 수정) | 표에 없음 |
| t3-2-q15 | C5 | EFS "Standard-IA"는 옛 명칭, One Zone은 파일 시스템 유형 | "Infrequent Access(IA)"로, 보기 A를 "One Zone 파일 시스템을 새로 만들어 옮긴다"로 | 표에 없음 |
| t3-4-q2 | M2·C2 | "문서에 없습니다" 메타 2건, Lambda 15분 단정 | 메타 삭제, "표준 Lambda는 최대 900초(Lambda Managed Instances의 비동기 호출은 최대 90분)" | https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html |
| t3-4-q7 | C3 | [0] "Job Definition은 ECS 리소스" — Batch 구성요소 | [0]·[2]·해설에 Job Definition = Batch 구성요소로 정정 | 표에 없음 |
| t3-5-q5 | C2·M2 | "최대 128TiB, 공식 문서 기준 256TiB" 혼재 | "엔진 버전에 따라 최대 256TiB(이전 버전 128TiB)" | https://aws.amazon.com/about-aws/whats-new/2025/07/amazon-aurora-mysql-database-clusters-256-tib-storage/ |
| t3-5-q6 | C1 | "일반 RDS Multi-AZ"가 배포 유형 미지정. DB 클러스터는 보통 35초 미만 페일오버. 정답 길이 단서 | 지문을 "Multi-AZ DB 인스턴스 배포(스탠바이 1개)"로 한정, 오답 길이 맞춤 | https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html |
| t3-5-q11 | C2·C5 | gp3에 버스트 크레딧이 있다고 서술, Magnetic을 "신규 사용 비권장"으로 | 보기 B·해설을 gp2로 한정, "Magnetic은 사용 중단되어 신규 인스턴스에 제공되지 않음" | 표에 없음 |
| t4-2-q12 | C3 | [0] "권장만 제안" — 2025-11 자동화 규칙 미반영 | "인스턴스 크기는 자동 변경하지 않음. 2025-11부터 EBS 정리·유형 업그레이드만 자동 적용 가능" | https://docs.aws.amazon.com/compute-optimizer/latest/ug/view-idle-recommendations.html |
| t4-3-q1 | C2 | 0 ACU 자동 일시정지 미반영 | "최소 0 ACU면 유휴 시 일시정지되어 컴퓨팅 요금 0" 추가 | https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2-auto-pause.html |
| t4-3-q6 | C3 | [2] "Aurora 최대 128TB, 10GB 단위" | "엔진 버전에 따라 128TiB 또는 256TiB" | https://aws.amazon.com/about-aws/whats-new/2025/07/amazon-aurora-mysql-database-clusters-256-tib-storage/ |
| t4-3-q7 | C3 | [1] "Multi-AZ 스탠바이는 읽기 처리 안 함" — DB 클러스터는 처리 | "Multi-AZ DB 인스턴스 배포의 스탠바이"로 한정 | https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html |
| t4-3-q9 | C2·C1 위험 | 지문은 규칙적 패턴인데 해설은 "불규칙" — q10과 충돌 | 지문에 "피크 시각과 규모가 날마다 크게 달라 예측이 어렵다" 추가 | 표에 없음 |

## D. 공개 Task 출처 교체 14건

보고의 "출처 교체(resource) 61건" 표에서 ✔(이미 공개) Task만 뽑았다. 사실은 맞지만 인용한 페이지가 그 사실을 담고 있지 않은 경우다.

| 문항 | 교체할 공식 페이지 |
| --- | --- |
| t2-1-q5 | https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-short-and-long-polling.html |
| t3-2-q1 | https://docs.aws.amazon.com/efs/latest/ug/whatisefs.html |
| t3-2-q5 | https://docs.aws.amazon.com/ebs/latest/userguide/ebs-volumes-multi.html |
| t3-2-q6 | https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-store-lifetime.html |
| t3-2-q13 | https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/what-is-fsx-ontap.html |
| t3-5-q7 | https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database.html |
| t3-5-q8 | https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html |
| t3-5-q14 | https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html |
| t4-2-q13 | Lambda 요금 페이지 — **교체 후보 미확인**(검수자가 특정하지 못했다) |
| t4-3-q5 | https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithReservedDBInstances.html |
| t4-3-q11 | https://aws.amazon.com/rds/pricing/ |
| t4-3-q12 | RDS 스냅샷 삭제 문서 — **URL 미특정** |
| t4-3-q13 | https://docs.aws.amazon.com/timestream/latest/developerguide/AmazonTimestreamForLiveAnalytics-availability-change.html |
| t4-3-q14 | https://docs.aws.amazon.com/compute-optimizer/latest/ug/what-is-compute-optimizer.html |

⚠️ t4-3의 `rds-reserved-instances.html` **6건(q5·q6·q7·q11·q12·q14)**은 UserGuide 루트로 리디렉트되는 **깨진 링크**다. 위 표(q5·q11·q12·q14)와 C절(q6·q7)에 나눠 있으니 한 번에 처리하면 된다.

## E. 같이 보면 좋은 것 (공개 Task 한정)

- **확인 필요**(결함 미집계): t3-5-q1 페일오버 "약 1~2분" · t3-5-q7 "RPO 1초·RTO 1분" · t3-5-q14 "보존 0~35일" — 인용 페이지에 수치가 없다. t4-3-q8 콘솔 기본 최솟값 0.5 ACU · t4-3-q14 Compute Optimizer RDS 메모리 분석 · t4-3-q13 Timestream의 SAA-C03 범위 여부 · t2-1-q12 Step Functions 처리량 수치(2,000/100,000, welcome 표와 쿼터 페이지 불일치 — 수치를 빼는 쪽이 안전).
- **중복·겹침**: t3-5-q3 · t3-5-q15(+q1·q2까지 네 문항이 "Multi-AZ = 동기 HA, 읽기 복제본 = 비동기 확장"이라는 같은 사실).
- **정답 쏠림 배지는 고치지 않는다** — t2-1(idx1 15/15), t3-2(10/15) 등에 배지가 있지만 앱이 모든 경로에서 보기를 섞으므로 학습자에게 보이지 않는다(루브릭 1-4번).
