# ③ 학습문서 사실성 감사 샤드 — 03-docs-soa-a (t1-1~t1-5) — 2026-07

## 요약 (3~5줄)

- SOA 도메인 1 문서 5건(soa-t1-1~t1-5) 전문 정독 결과 **발견 9건(H2·M3·L4, 사실의심 7건)**.
- 핵심 수치(지표 보존기간 3h/15d/63d/455d, EC2 기본 5분/세부 1분, 로그 기본 보존 무기한, CloudTrail 데이터 이벤트 기본 미기록, gp3 3,000 IOPS/125 MB/s, X-Ray 기본 샘플링 1건/초+5% 등)는 공식 문서와 일치 — 전반 품질 양호.
- 최대 이슈 2건: ① t1-5의 **gp2 16,000 IOPS 도달 용량을 ≈3,334GB로 오기**(정답 ≈5,334GiB; 구세대 10,000 IOPS 상한 시절 수치와 혼동 추정), ② t1-1의 **경보 작업 대상 표에 EventBridge를 직접 작업으로 오분류 + Lambda 직접 작업(2022-12~) 누락** — 둘 다 "시험 빈출 수치/선택형" 포인트라 오답 유발 가능.
- 문서 내 모순 1건: t1-1이 §1에서 "기간·통계"를 지표 '식별' 요소로 묶었으나 같은 문서 시험 포인트는 "식별=네임스페이스+이름+차원"으로 올바르게 서술.

## 발견 항목

| ID | 위치 | 발견 내용 | 심각도(H/M/L) | 확신도(높/중/낮) | 권장 조치 | Phase(A/B) | 사실의심(Y/N) |
|---|---|---|---|---|---|---|---|
| DOC-SOA-001 | assets/content/soa/soa-t1-1.md#핵심개념 §1 "지표의 구조" 표 도입부 | "CloudWatch 지표를 **고유하게 식별하는 4가지 요소**"로 네임스페이스·차원·**기간·통계**를 묶음. 기간(Period)·통계(Statistic)는 조회/집계 파라미터이지 식별 요소가 아님(식별=네임스페이스+이름+차원). 같은 문서 시험 포인트("지표 식별 = 네임스페이스+이름+차원")·본문("통계는 측정값이 아니라 집계 방식")과 **자기모순** — "무엇이 지표를 식별하나" 유형 문항 오답 소지. 근거: 문서 내 L76 vs L242 상호 대조 + CloudWatch 개념 문서의 metric 정의 | M | 높 | 도입부를 "지표를 다룰 때의 4가지 핵심 요소"로 바꾸고, 식별(네임스페이스·이름·차원) vs 조회(기간·통계)를 분리 서술 | A | N |
| DOC-SOA-002 | assets/content/soa/soa-t1-1.md#핵심개념 §4 "경보 작업 대상" 표 + 시험 포인트("경보 작업 대상: …, EventBridge") | **EventBridge를 경보 작업(alarm action) 대상으로 표기**. 실제로는 alarm-actions에 EventBridge를 지정할 수 없고, 경보 상태 변경 이벤트가 EventBridge로 **자동 발행**되는 통합임(t1-3 §5는 올바른 프레이밍이라 문서 간 불일치). 또한 **Lambda가 직접 경보 작업 대상**(2022-12 추가)인데 표·시험 포인트에 누락(SNS 경유로만 서술) — "직접 구성 가능한 경보 작업 고르기"·"가장 단순한 Lambda 트리거 방법" 유형 문항에서 오답 유발. 근거: PutMetricAlarm AlarmActions 허용 ARN 목록(EC2 automate·ASG 정책·SNS·SSM·Lambda)에 EventBridge 없음 | H | 높 | EventBridge 행을 "자동 통합(작업 아님)"으로 재분류하거나 각주 처리, Lambda를 직접 작업 대상으로 추가. 시험 포인트 동기 수정 | A | Y |
| DOC-SOA-003 | assets/content/soa/soa-t1-1.md#핵심개념 §4 경보 작업 대상 표 Systems Manager 행 | "OpsItem 생성·**자동화 런북 실행**"으로 서술. 직접 경보 작업은 **OpsItem 생성·Incident Manager 인시던트 생성**이며, 자동화 런북 실행은 응답 플랜 또는 EventBridge **경유 간접 실행** — 직접/간접 구분 문항에서 혼동 소지. 근거: CloudWatch 경보 SSM 작업 ARN은 opsitem·response-plan 2종 | M | 중 | "OpsItem·인시던트 생성(런북은 응답 플랜/EventBridge 경유)"로 정정 | A | Y |
| DOC-SOA-004 | assets/content/soa/soa-t1-1.md#흔한함정 5 | "고해상도 **지표**·고해상도 경보는 추가 비용" — 고해상도 **경보**는 표준 대비 고가(0.10→0.30 USD/월)가 맞지만, 고해상도 **지표** 자체는 표준 커스텀 지표와 지표당 단가 동일(비용 증가는 PutMetricData 호출량 증가에 의한 간접 효과). 근거: CloudWatch 요금표의 커스텀 지표 단가는 해상도 구분 없음, 경보만 해상도별 단가 상이 | L | 중 | "고해상도 경보는 표준 경보보다 비싸고, 1초 게시로 API 호출량이 늘어 지표 비용도 증가할 수 있다"로 뉘앙스 정정 | A | Y |
| DOC-SOA-005 | assets/content/soa/soa-t1-2.md#핵심개념 §7 EMF | "고대수(custom) 지표를 자동 추출" — **'고대수'는 의미 불명 오탈자**(문맥상 '사용자 지정(custom)'). 같은 절 아래 문장은 "고해상도·고카디널리티"로 정상 표기. 근거: 국문 용어로 존재하지 않는 어휘, 괄호 병기 원문이 custom | L | 높 | "사용자 지정(custom) 지표"로 자구 정정 | A | N |
| DOC-SOA-006 | assets/content/soa/soa-t1-2.md#핵심개념 §4 구독 필터 표·시험 포인트 (soa-t1-1과 무관) | "Kinesis Data Firehose" 구명칭 사용. 2024-02부로 **Amazon Data Firehose**로 리브랜딩 — SOA-C03(2025-09 출시) 실제 문항은 신명칭 표기 가능성이 높아 이름 매칭에서 머뭇거릴 수 있음(기능 설명 자체는 정확). 근거: AWS 공식 리브랜딩 공지(2024-02) | L | 중 | "Amazon Data Firehose(구 Kinesis Data Firehose)" 병기 | A | Y |
| DOC-SOA-007 | assets/content/soa/soa-t1-4.md#핵심개념 §3 도입부 | "추가로 **EBS·연결 상태 확인** 등도 제공" — 실제 제3의 검사는 **연결된 EBS 상태 확인(Attached EBS status checks, 지표 StatusCheckFailed_AttachedEBS)** 단일 항목인데, 가운뎃점 때문에 'EBS'와 '연결' 2개 검사로 읽혀 상태 확인 종류 수를 오인할 수 있음. 근거: EC2 상태 확인 공식 문서의 검사 3종(system/instance/attached EBS) | L | 중 | "연결된 EBS 상태 확인(Attached EBS)"으로 명칭 정정 | A | Y |
| DOC-SOA-008 | assets/content/soa/soa-t1-4.md#흔한함정 4 (및 §4 인메모리 유실 서술) | "(인메모리·**인스턴스 스토어 데이터는 유실될 수 있음**)" — 자동 복구(recover)는 **EBS 전용 인스턴스만 지원**(인스턴스 스토어 볼륨 장착 인스턴스는 복구 미지원)이므로, 이 표현은 "인스턴스 스토어가 있어도 복구되고 데이터만 잃는다"는 오개념을 심을 수 있음. "자동 복구 지원 조건" 유형 문항 오답 소지. 근거: EC2 인스턴스 복구 요구사항(EBS 볼륨만 사용) 명시 | M | 중 | 2단 검증 후 "(인메모리 데이터 유실 가능; 자동 복구는 EBS 전용 인스턴스만 지원)"으로 재작성할지, 인스턴스 스토어 언급을 삭제할지 결정 | B | Y |
| DOC-SOA-009 | assets/content/soa/soa-t1-5.md#핵심개념 §2 "시험 빈출 수치" gp2 항목 | "약 1,000 GB(**≈3,334 GB에서 16,000 IOPS 상한**) 이상부터…" — gp2는 3 IOPS/GiB이므로 16,000 IOPS 도달 용량은 **≈5,334 GiB**(16,000÷3). 3,334 GiB는 **구세대 상한 10,000 IOPS 시절**(2018-11 이전) 도달 용량으로, 신·구 수치가 뒤섞임. "반드시 기억" 수치 절에 위치해 시험 오답 직결 가능. 근거: 산술 3,334×3≈10,000≠16,000 + EBS 볼륨 유형 문서(5,334 GiB에서 16,000 IOPS) | H | 높 | "≈5,334 GiB에서 16,000 IOPS 상한"으로 수치 정정 | A | Y |

## 검증 노트 (2단 검증 참고)

- 이상 없음 확인(대조 완료): 지표 보존 롤업 4단(3h/15d/63d/455d), 차원 최대 30개, 고해상도 경보 10/30초·표준 60초 배수, 누락 데이터 4종·기본 missing, 로그 기본 보존 Never expire·1일~10년, 지표 필터 소급 미적용, 구독 필터 4대상, CWAgent 네임스페이스, SSM 문서명 AmazonCloudWatch-ManageAgent, CloudTrail 관리/데이터 이벤트 기본값·Event history 90일 무료·SHA-256+RSA 다이제스트, EventBridge cron/rate 구문, X-Ray 기본 샘플링(1/초+5%), 상태 확인 2종 책임 경계·recover ARN 형식·ID/사설IP/EIP 보존, ELB 임계값 4종·ASG-ELB 헬스체크 연동, gp3/gp2/io/st1/sc1 특성, 200GB gp2=600 IOPS 예제, RDS 복제본 비동기 vs Multi-AZ 동기, Redis/Memcached·Lazy Loading/Write-Through 구분.
- v1.1 개정 범위 차이는 별도 감사에서 기발견 — 본 샤드는 사실 오류만 수록(재보고 생략).
