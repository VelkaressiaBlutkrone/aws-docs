# SAA 도메인 1·2 학습문서 지적 판정 (오디오 대본 검수 파생)

- 판정일: 2026-11-22 · 입력 `saa-d12.md`의 `## 컨트롤러 요청` §A(A1~A17)와 항목 본문의 문서 쪽 의심
- 고친 파일: 없음(이 보고서 한 편만 썼다). git 쓰기·테스트·오디오 도구 실행 없음

## 요약

| 판정 | 건수 | 항목 |
|---|---|---|
| **채택** | 15 | A1·A2·A3·A4·A5·A6·A7·A8·A9·A11·A12·A13·A15·A16·A17 |
| **기각** | 1 | A10 |
| **보류** | 1 | A14 |
| 합계 | 17 | |

- 입력 표는 지시문의 「A1~A14」보다 많은 **A1~A17**이다. 17건 전부 판정했다.
- 항목 본문에 적힌 문서 쪽 의심 5곳(`saa-t1-1` seg039 · `saa-t1-2` seg022 뒤 비고 · `saa-t1-3` seg054 비고 · `saa-t2-4` seg014 · `saa-t2-5` seg038)은 전부 §A의 A2·A1·A3·A12·A13과 같은 건이라 따로 세지 않았다. 본문에서 §A 밖의 문서 쪽 의심은 찾지 못했다(「문서 유래·문서 쪽·문서 내부·컨트롤러 요청」 표지로 전수 검색).
- 대상이 아닌 요청(건수만): §B 발화 판정 4건(R3 채택 범위·챕터 목록·App2Container·`sourceHash`), §C 발음 표기 9개 이름 + 제목·연결 세그먼트 영문 잔존 1묶음, §D 0건.
- 채택 15건의 성격: 문서 내부 모순(이미 정정된 본문이 표·시험 포인트·원리 줄에 전파되지 않음) 8건(A1·A3·A6·A7·A8·A11·A12·A15) · 사실 과장/오류 5건(A2·A4·A5·A9·A13) · 오기/표기 2건(A16·A17).
- 문항 쪽 후속(보고만, 수정하지 않았다): `saa-t2-2-q7`(A11 — 오답 보기·근거가 HTTP API 저지연을 전제) · `saa-t2-5-q8`(A14 판정에 따라).
- 가드 관련 메모: A5의 md `saa-t2-4.md:487` 현재 문장은 문항 가드의 금지 문구와 같다 · A7은 금지 문자열과 조사 한 글자 차이로 비켜 갔다 · A1은 `saa_question_propagation_test.dart:185`의 설명문에 35일이 남아 있다 · A10은 문항 가드의 `reason` 문구가 현행 공식 문구와 결이 다르다.

### 측정 방법

- 줄은 전부 작업 트리에서 직접 읽었고, 「현재 문장」·「교체 문장」은 스크립트가 파일에서 뽑아 **치환 횟수 1회를 단정**한 뒤 만들었다(손으로 옮겨 적지 않았다). 파일 줄 끝의 CR은 떼고 실었다.
- 전체 주소로 인용한 URL 25개와 파일명만 든 `apigateway/.../http-api.html` 1개는 `curl -sL -w "%{http_code} %{num_redirects}"`로 재서 전부 `200 r=0`이다.
- 「공식에 없다」는 A11 한 건이고, 두 페이지 + 같은 추출의 양성 대조군으로 확인했다. 표 안의 사실(A8·A9)은 태그를 벗긴 전문에서 찾았다.
- 「같은 주장의 다른 자리」는 `saa-*.md` 24편과 `saa-*.questions.json` 24파일(문항의 지문·보기·해설·오답 근거·출처 제목)을 정규식으로 전수 검색한 결과다.

## 항목

### A1 · saa-t1-2.md:116 — 채택
- 지적: 관리 계정 루트 MFA 유예를 「첫 로그인 후 35일」로 적는다. `saa-t1-1.md:300`은 14일이고 `:398` 정정 메모가 35일을 틀린 값으로 명시한다(전파 누락).
- 현재 문장(그대로):
  - `saa-t1-2.md:116`

    ```text
    > 🔐 **멤버 계정 루트는 없애는 것이 현행 모범 사례입니다(중앙 루트 접근 관리).** Organizations에서 이 기능을 켜면 멤버 계정의 루트 비밀번호·액세스 키·서명 인증서·MFA를 제거할 수 있고, 제거된 계정은 **루트 로그인도 비밀번호 복구도 불가**합니다. **새로 만드는 계정은 기본적으로 루트 자격증명이 없습니다.** 루트만 할 수 있는 일(잘못 설정된 S3 버킷 정책·SQS 정책 복구 등)은 관리 계정이나 위임 관리자가 **권한 작업(`sts:AssumeRoot`)** 으로 수행하고, 필요할 때만 **비밀번호 복구 허용**을 켭니다. 관리 계정 루트는 제거할 수 없으므로 **MFA가 요구**되며(첫 로그인 후 35일 유예) 다중 승인 보관을 권장합니다.
    ```
- 공식 근거: `https://docs.aws.amazon.com/IAM/latest/UserGuide/enable-mfa-for-root.html` (200 r=0) — "Users must register MFA within 14 days of their first sign-in attempt". 같은 페이지에서 `35 days` 0건(대조군 `14 days` 1건). 레포 선행 판정: `CLAUDE.md`·`saa_t1_facts_test.dart:49`가 35일을 금지(2026-10-27 정정) — 이 줄은 그 판정의 미전파분이다.
- 교체 문장(줄 전체):
  - `saa-t1-2.md:116`

    ```text
    > 🔐 **멤버 계정 루트는 없애는 것이 현행 모범 사례입니다(중앙 루트 접근 관리).** Organizations에서 이 기능을 켜면 멤버 계정의 루트 비밀번호·액세스 키·서명 인증서·MFA를 제거할 수 있고, 제거된 계정은 **루트 로그인도 비밀번호 복구도 불가**합니다. **새로 만드는 계정은 기본적으로 루트 자격증명이 없습니다.** 루트만 할 수 있는 일(잘못 설정된 S3 버킷 정책·SQS 정책 복구 등)은 관리 계정이나 위임 관리자가 **권한 작업(`sts:AssumeRoot`)** 으로 수행하고, 필요할 때만 **비밀번호 복구 허용**을 켭니다. 관리 계정 루트는 제거할 수 없으므로 **MFA가 요구**되며(MFA가 없으면 첫 콘솔 로그인 시도 후 14일 안에 등록) 다중 승인 보관을 권장합니다.
    ```
- 같은 주장의 다른 자리: SAA md·문항 본문 0건(`35일` 전수 grep — 나머지는 RDS 백업 보존 0~35일·정정 메모 `saa-t1-1.md:398`). 참고: 테스트 주석 문자열 `test/saa_question_propagation_test.dart:185`의 `why`가 「첫 로그인 후 35일 유예」로 남아 있다(콘텐츠 아님, 가드 설명문).

### A2 · saa-t1-1.md:271 — 채택
- 지적: 「외부 IdP에서 사용자가 삭제되면 즉시 AWS 접근이 차단」 — 이미 발급된 임시 자격증명은 만료 전까지 유효하므로 과장이다(같은 문서 `:310-311`과도 어긋난다).
- 현재 문장(그대로):
  - `saa-t1-1.md:271`

    ```text
    > OIDC 토큰을 검증해 임시 자격증명을 발급하면 IAM 사용자 수명 주기 관리 자체가 없어집니다 — 외부 IdP에서 사용자가 삭제되면 즉시 AWS 접근이 차단됩니다.
    ```
- 공식 근거: `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp.html` (200 r=0) — "After the credentials expire, AWS no longer recognizes them". 만료 전 차단은 별도 조치다: `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_revoke-sessions.html` (200 r=0, 제목 "Revoke IAM role temporary security credentials"). IdP 삭제가 발급된 세션을 무효화한다는 서술은 두 페이지에 없다.
- 교체 문장(줄 전체):
  - `saa-t1-1.md:271`

    ```text
    > OIDC 토큰을 검증해 임시 자격증명을 발급하면 IAM 사용자 수명 주기 관리 자체가 없어집니다 — 외부 IdP에서 사용자가 삭제되면 새 임시 자격증명을 받을 수 없고, 이미 발급된 자격증명은 만료될 때까지만 유효합니다(만료 전에 끊으려면 역할 세션 취소).
    ```
- 같은 주장의 다른 자리: 0건(`즉시 AWS 접근|즉시 차단|바로 차단` 전수 grep — 나머지 3건은 NACL·예산 시나리오로 무관).

### A3 · saa-t1-3.md:378 — 채택
- 지적: 시험 포인트가 Flow Logs 저장 대상을 두 곳으로 적는다. 같은 문서 `:280`은 세 곳으로 정정됐다(내부 모순).
- 현재 문장(그대로):
  - `saa-t1-3.md:378`

    ```text
    - **네트워크 트래픽 감사·모니터링** → **VPC Flow Logs** (CloudWatch 또는 S3 저장).
    ```
- 공식 근거: `https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html` (200 r=0) — "Amazon CloudWatch Logs, Amazon S3, or Amazon Data Firehose". `CLAUDE.md` B조(1)도 「발행 대상은 세 곳」으로 기록.
- 교체 문장(줄 전체):
  - `saa-t1-3.md:378`

    ```text
    - **네트워크 트래픽 감사·모니터링** → **VPC Flow Logs** (CloudWatch Logs·S3·Data Firehose 저장).
    ```
- 같은 주장의 다른 자리: 0건(md·문항 전수 grep).

### A4 · saa-t1-3.md:201 — 채택
- 지적: 「기본 경로는 NAT 게이트웨이 → 인터넷 → AWS 퍼블릭 엔드포인트」, 「인터넷 없이 AWS 내부망으로 대체」 — NAT 경유 S3·DynamoDB 트래픽은 IGW를 지나지만 AWS 네트워크를 벗어나지 않는다.
- 현재 문장(그대로):
  - `saa-t1-3.md:201`

    ```text
    프라이빗 서브넷의 EC2가 S3·DynamoDB 같은 AWS 관리형 서비스에 접근할 때, 기본 경로는 NAT 게이트웨이 → 인터넷 → AWS 퍼블릭 엔드포인트입니다. VPC 엔드포인트는 이 경로를 **인터넷 없이 AWS 내부망으로** 대체합니다.
    ```
- 공식 근거: `https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-endpoints.html` (200 r=0) — "traverses the internet gateway, it does not leave the AWS network". 레포 선행 판정: `CLAUDE.md` B조(1)이 같은 인용으로 `saa-t1-3-q9`를 고쳤다(문항만 고치고 md는 남았다).
- 교체 문장(줄 전체):
  - `saa-t1-3.md:201`

    ```text
    프라이빗 서브넷의 EC2가 S3·DynamoDB 같은 AWS 관리형 서비스에 접근할 때, 기본 경로는 NAT 게이트웨이 → 인터넷 게이트웨이 → AWS 퍼블릭 서비스 엔드포인트입니다(이 트래픽은 인터넷 게이트웨이를 지나지만 AWS 네트워크를 벗어나지는 않습니다). VPC 엔드포인트는 이 경로를 **인터넷 게이트웨이·NAT 없이** 대체합니다.
    ```
- 같은 주장의 다른 자리: `saa-t4-4.md:322` 표 행 「EC2 → NAT GW → 인터넷 → S3」(같은 표현, 「인터넷」→「인터넷 게이트웨이」 권장). `saa-t1-3.md:200` 절 제목 「인터넷 없이 AWS 서비스 접근」·`:374`·`:427`·`saa-t1-3-q9` 지문의 「인터넷 경유 금지」는 시나리오 요건 문구라 대상 아님. 문항 0건.

### A5 · saa-t1-3.md:159·161·164, saa-t2-4.md:122·273·487 — 채택
- 지적: NAT 게이트웨이 「퍼블릭 서브넷에 배치」「AZ마다 배치」에 영역형(zonal) 한정이 없다. (보고서는 `:159·164`로 적었으나 한정 없는 단정은 `:159`(시험 포인트)·`:161`(경고)·`:164`(원리 질문) 세 줄이다.)
- 현재 문장(그대로):
  - `saa-t1-3.md:159`

    ```text
    > 시험 포인트: NAT 게이트웨이는 **퍼블릭 서브넷에 배치**하고 Elastic IP를 연결합니다. 프라이빗 서브넷의 라우트 테이블에 `0.0.0.0/0 → NAT 게이트웨이`를 추가해야 아웃바운드가 동작합니다.
    ```
  - `saa-t1-3.md:161`

    ```text
    > ⚠️ **"NAT 게이트웨이는 자동으로 고가용"이 아닙니다.** 각 NAT 게이트웨이는 **특정 AZ에 만들어지고 그 AZ 안에서만 이중화**됩니다. 여러 AZ의 리소스가 하나의 NAT 게이트웨이를 공유하면 **그 AZ가 내려갈 때 다른 AZ 리소스까지 인터넷이 끊깁니다.** 공식 권고는 **AZ마다 NAT 게이트웨이를 만들고 같은 AZ의 NAT로 라우팅**하는 것입니다. 이 구성이 시험에서 "AZ 장애에도 아웃바운드 유지" 요구의 정답 방향입니다.
    ```
  - `saa-t1-3.md:164`

    ```text
    > 🧠 원리: 왜 NAT 게이트웨이는 프라이빗이 아닌 퍼블릭 서브넷에 배치해야 할까요?
    ```
  - `saa-t2-4.md:122`

    ```text
    | 단일 NAT 게이트웨이 | AZ마다 NAT 게이트웨이 1개씩 배치 |
    ```
  - `saa-t2-4.md:273`

    ```text
    | NAT 게이트웨이 | AZ마다 미리 배치 → 한 AZ 장애 시 다른 AZ 독립 동작 |
    ```
  - `saa-t2-4.md:487`

    ```text
    6. **"NAT 게이트웨이 1개로 전체 VPC를 커버하면 된다."** → NAT 게이트웨이가 있는 AZ에 장애가 나면 다른 AZ의 프라이빗 서브넷이 인터넷에 나갈 수 없습니다. AZ마다 NAT 게이트웨이를 배치해야 합니다.
    ```
- 공식 근거: `https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateways-regional.html` (200 r=0) — "Unlike standard NAT gateways (referred to as zonal NAT gateways)", "No public subnets required", "automatically expands across Availability Zones". 영역형 서술 자체는 맞다: `https://docs.aws.amazon.com/vpc/latest/userguide/nat-gateway-basics.html` (200 r=0) — "created in a specific Availability Zone". 레포 선행 판정: `CLAUDE.md` 우선순위 2 A조(SAA 문항 지문을 zonal로 한정)·SOA P1(문맥 규칙 전수)이 같은 방향으로 이미 정정했다.
- 교체 문장(줄 전체):
  - `saa-t1-3.md:159`

    ```text
    > 시험 포인트: **영역형(zonal) NAT 게이트웨이**는 **퍼블릭 서브넷에 배치**하고 Elastic IP를 연결합니다(리전 NAT 게이트웨이는 퍼블릭 서브넷이 필요 없습니다). 프라이빗 서브넷의 라우트 테이블에 `0.0.0.0/0 → NAT 게이트웨이`를 추가해야 아웃바운드가 동작합니다.
    ```
  - `saa-t1-3.md:161`

    ```text
    > ⚠️ **"NAT 게이트웨이는 자동으로 고가용"이 아닙니다.** 여기서 말하는 것은 **영역형(zonal)** 입니다. 각 영역형 NAT 게이트웨이는 **특정 AZ에 만들어지고 그 AZ 안에서만 이중화**됩니다. 여러 AZ의 리소스가 하나의 NAT 게이트웨이를 공유하면 **그 AZ가 내려갈 때 다른 AZ 리소스까지 인터넷이 끊깁니다.** 공식 권고는 **AZ마다 NAT 게이트웨이를 만들고 같은 AZ의 NAT로 라우팅**하는 것입니다. 이 구성이 시험에서 "AZ 장애에도 아웃바운드 유지" 요구의 정답 방향입니다. **리전 NAT 게이트웨이**를 고르면 워크로드가 있는 AZ로 자동 확장됩니다.
    ```
  - `saa-t1-3.md:164`

    ```text
    > 🧠 원리: 왜 영역형 NAT 게이트웨이는 프라이빗이 아닌 퍼블릭 서브넷에 배치해야 할까요?
    ```
  - `saa-t2-4.md:122`

    ```text
    | 단일 NAT 게이트웨이 | 영역형은 AZ마다 NAT 게이트웨이 1개씩 배치(또는 리전 NAT 게이트웨이) |
    ```
  - `saa-t2-4.md:273`

    ```text
    | NAT 게이트웨이 | 영역형은 AZ마다 미리 배치 → 한 AZ 장애 시 다른 AZ 독립 동작 |
    ```
  - `saa-t2-4.md:487`

    ```text
    6. **"NAT 게이트웨이 1개로 전체 VPC를 커버하면 된다."** → NAT 게이트웨이가 있는 AZ에 장애가 나면 다른 AZ의 프라이빗 서브넷이 인터넷에 나갈 수 없습니다. 영역형은 AZ마다 배치하고, 리전 NAT 게이트웨이를 쓰면 워크로드가 있는 AZ로 자동 확장됩니다.
    ```
- 같은 주장의 다른 자리: 한정 없는 같은 단정 — `saa-t1-3.md:165-167`(원리 본문 「퍼블릭 서브넷에 있어야만 가능」; `:164` 제목을 한정하면 문맥상 덮인다), `saa-t1-3.md:373`(시험 포인트 「퍼블릭 서브넷 배치 + Elastic IP 필수」), `saa-t1-3.md:417`(자가 점검 Q1 정답), `saa-t2-4.md:488`(함정 6 원리 「NAT 게이트웨이도 AZ마다 사전 배치돼야」), `saa-t4-4.md:107`·`:250`·`:344`(같은 문서 `:252`가 Regional NAT gateway를 따로 소개해 문서 수준에서는 병기돼 있다). 문항: `saa-t1-3-q7`·`saa-t2-4-q2`·`saa-t2-4-q11`은 해설·오답 근거가 이미 「영역형」으로 한정돼 있다 — 수정 필요 0건. ⚠️ `test/saa_question_facts_test.dart:1174`가 문항에서 「AZ마다 NAT 게이트웨이를 배치해야 합니다」를 금지 문구로 둔다(문항 대상 가드이나 md `:487`의 현재 문장과 글자 그대로 같다).

### A6 · saa-t1-4.md:70 — 채택
- 지적: 용어 표가 「첫 매칭 액션(Allow/Block/Count)을 실행」으로 적는다. 본문 `:103`은 종료/비종료 구분으로 정정됐고 Count는 평가를 끝내지 않는다(내부 모순).
- 현재 문장(그대로):
  - `saa-t1-4.md:70`

    ```text
    | **웹 ACL** | Web Access Control List | WAF의 규칙 컨테이너 — 요청을 순서대로 평가해 첫 매칭 액션(Allow/Block/Count)을 실행 |
    ```
- 공식 근거: `https://docs.aws.amazon.com/waf/latest/developerguide/waf-rule-action.html` (200 r=0) — Count: "This is a non-terminating action". `https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-processing-order.html` (200 r=0) — "until it either finds a match that terminates the evaluation". 문서 자신의 `:448` 정정 메모 ①과 같은 판정.
- 교체 문장(줄 전체):
  - `saa-t1-4.md:70`

    ```text
    | **웹 ACL** | Web Access Control List | WAF의 규칙 컨테이너 — 규칙을 우선순위 순서로 평가해 처음 매칭된 종료 액션(Allow/Block)에서 끝남(Count는 비종료) |
    ```
- 같은 주장의 다른 자리: 0건. `saa-t1-3.md:178`·`:441`·`saa-t1-3-q6`의 「첫 매칭에서 결정」은 NACL 서술(정확)이라 대상 아님. `saa-t1-4-q6`은 이미 「처음 매칭된 종료 액션」.

### A7 · saa-t1-5.md:82 — 채택
- 지적: 용어 표가 「IAM 정책만으로는 CMK 접근 불가」로 단정한다. 본문 `:143-149`·함정 `:314`는 「키 정책에 위임 문장이 있으면 IAM 정책만으로 접근 가능」으로 정정됐다(내부 모순).
- 현재 문장(그대로):
  - `saa-t1-5.md:82`

    ```text
    | **키 정책** | Key Policy | CMK에 붙이는 리소스 기반 정책 — IAM 정책만으로는 CMK 접근 불가 |
    ```
- 공식 근거: `https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html` (200 r=0) — "Unless the key policy explicitly allows it, you cannot use IAM policies". `https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html` (200 r=0) — 절 제목 "Allows access to the AWS account and enables IAM policies". 즉 무조건 불가가 아니라 키 정책의 허용이 전제다.
- 교체 문장(줄 전체):
  - `saa-t1-5.md:82`

    ```text
    | **키 정책** | Key Policy | CMK에 붙이는 리소스 기반 정책 — 키 정책이 허용(계정 위임 문장 포함)해야 IAM 정책이 효력을 가짐 |
    ```
- 같은 주장의 다른 자리: 0건. `saa-t1-5-q4` 해설의 「그것을 지우거나 좁혔다면 IAM 정책만으로는 접근이 차단」은 조건부 서술이라 정확. (`test/saa_t12_t13_facts_test.dart:123`·`saa_question_propagation_test.dart:215`가 금지하는 문자열은 「IAM 정책만으로는 CMK 접근이 불가」로, 조사 「이」 하나 차이로 이 줄을 비켜 갔다.)

### A8 · saa-t2-1.md:249 — 채택
- 지적: 선택 지도 표가 SNS+SQS 팬아웃의 근거를 「재시도·처리 보장」으로 적는다. 본문 `:189`·함정 3 `:341`은 「유실 방지가 아니라 소비자별 버퍼링·독립 속도·재처리」로 정정됐다(내부 모순).
- 현재 문장(그대로):
  - `saa-t2-1.md:249`

    ```text
    | 여러 구독자 + 재시도·처리 보장 | **SNS + SQS 팬아웃** | SQS가 각 소비자 큐를 안정적으로 버퍼링 |
    ```
- 공식 근거: `https://docs.aws.amazon.com/sns/latest/dg/sns-message-delivery-retries.html` (200 r=0) — AWS 관리형 엔드포인트 "100,015 times, over 23 days"(표 안의 값). SNS 직접 구독에도 재시도가 있으므로 「재시도」는 팬아웃의 갈림길이 아니다.
- 교체 문장(줄 전체):
  - `saa-t2-1.md:249`

    ```text
    | 여러 구독자 + 소비자별 버퍼링·독립 속도·재처리 | **SNS + SQS 팬아웃** | SQS가 각 소비자 큐를 안정적으로 버퍼링 |
    ```
- 같은 주장의 다른 자리: 0건(`재시도·처리 보장` 전수 grep. 문항의 「처리 보장」 2건은 Step Functions Standard exactly-once로 무관).

### A9 · saa-t2-1.md:351 — 채택
- 지적: 「Express는 상태 전이 이력을 콘솔에 보존하지 않아」 — Express도 로깅을 켜면 Step Functions 콘솔에서 실행을 볼 수 있다. 정확한 구분은 「Step Functions가 이력을 기록하지 않는다(로깅 필요)」이다.
- 현재 문장(그대로):
  - `saa-t2-1.md:351`

    ```text
       (원리: §6 — Express는 상태 전이 이력을 콘솔에 보존하지 않아 고빈도·단기에 최적화됐고, 장기 상태 추적은 Standard의 설계 목적이다.)
    ```
- 공식 근거: `https://docs.aws.amazon.com/step-functions/latest/dg/concepts-view-execution-details.html` (200 r=0) — "the history of Express workflow executions are not"(recorded in Step Functions). `https://docs.aws.amazon.com/step-functions/latest/dg/choosing-workflow-type.html` (200 r=0) — Express 열: "CloudWatch Logs or the Step Functions console by enabling logging"(비교 표 안). 레포 선행 판정: `CLAUDE.md` 2차 검수 §C 「Express도 로깅을 켜면 콘솔에서 보인다」(문항 `saa-t2-1-q11`은 이미 반영).
- 교체 문장(줄 전체):
  - `saa-t2-1.md:351`

    ```text
       (원리: §6 — Express는 실행 이력을 Step Functions에 기록하지 않아(로깅을 켜야 CloudWatch Logs·콘솔에서 조회) 고빈도·단기에 최적화됐고, 장기 상태 추적은 Standard의 설계 목적이다.)
    ```
- 같은 주장의 다른 자리: 단정형은 0건. 같은 문서 `:233`(표 「실행 이력 | 콘솔에서 직접 조회 | CloudWatch Logs로 전송」)·`:239`·`:255`와 `saa-t2-1-q12` wrongExplanations.2는 「로깅을 켜야」 전제를 생략했을 뿐 거짓은 아니다 — 수정 불요, `:233` Express 칸에 「(로깅 설정 필요)」 병기는 선택.

### A10 · saa-t2-1.md:140 — 기각
- 지적: 「파티션당 API 액션별 300 TPS」가 레포 기록(「파티션당이 아니라 각 API 작업당」)과 표현이 다르다는 확인 요청.
- 현재 문장(그대로):
  - `saa-t2-1.md:140`

    ```text
    - **FIFO 고처리량 모드** — 기본(비고처리량)은 **파티션당 API 액션별 300 TPS**이고 배칭하면 **3,000 msg/s**(300 호출 × 10건)입니다. 고처리량 모드의 상한은 **리전마다 다릅니다** — 비배칭 TPS가 버지니아·오레곤·아일랜드 **70,000**, 그 외는 더 낮아 최저 **2,400**이고, 배칭하면 각 10배(**700,000** ~ **24,000** msg/s)입니다. 수치를 외우기보다 **"리전 의존 + 배칭이 10배"** 구조를 기억하세요.
    ```
- 공식 근거: 문서가 출처로 든 바로 그 페이지 `https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/quotas-messages.html` (200 r=0) — "Each partition in a FIFO queue is limited to 300 transactions per second, per API action". 문서 문장은 공식 문구의 직역이고 「API 액션별」을 빠뜨리지 않았다. 두 번째 확인: `https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/high-throughput-fifo.html` (200 r=0) — "Each partition supports up to 3,000 messages per second with batching". ⚠️ 레포 선행 판정과의 관계: `CLAUDE.md` 우선순위 1·`test/saa_question_facts_test.dart:620`은 문항 `saa-t2-1-q15`에서 「파티션당 300 TPS」(API 액션 한정이 없는 꼴)를 금지한다. 그 판정은 뒤집지 않는다 — 금지 문자열은 이 md 줄과 다르고(「파티션당 API 액션별」), 문항 쪽 결함의 실질은 「배치로 3,000까지 간다」는 전제 누락이었다. 다만 그 가드의 `reason`(「파티션당이 아니라」)은 현행 공식 문구와 결이 다르다는 점을 컨트롤러가 알아 둘 필요가 있다.
- 교체 문장: 없음
- 같은 주장의 다른 자리: 해당 없음(기각). 참고: `saa-t2-1.md:410` 참고자료 항목도 「파티션당 300 TPS」로 요약한다(같은 공식 페이지).

### A11 · saa-t2-2.md:191 — 채택
- 지적: 비교표가 HTTP API를 「더 저렴·단순·저지연」으로 적는다. 함정 3 `:365`는 「지연도 낮다」를 이미 걷었다(내부 모순).
- 현재 문장(그대로):
  - `saa-t2-2.md:191`

    ```text
    | **HTTP API** | 더 저렴·단순·저지연. 기본 기능 위주 | 단순 Lambda 프록시, 비용 우선 |
    ```
- 공식 근거: `https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-vs-rest.html` (200 r=0) — "designed with minimal features so that they can be offered at a lower price". 두 페이지(`http-api-vs-rest.html`·`http-api.html`, 둘 다 200 r=0)에서 `latency` 0건(대조군: 같은 추출에서 `lower price`·`minimal` 각 1건). 레포 선행 판정: `CLAUDE.md` 「HTTP API가 "지연이 낮다"는 어느 공식 페이지에도 없다」(`saa-t2-2-q8` 정정).
- 교체 문장(줄 전체):
  - `saa-t2-2.md:191`

    ```text
    | **HTTP API** | 더 저렴·단순. 기능을 최소화한 기본 기능 위주 | 단순 Lambda 프록시, 비용 우선 |
    ```
- 같은 주장의 다른 자리: 문항 `saa-t2-2-q7` — options[2] 「HTTP API — 저지연 특성으로 빠른 폴링을 구현한다」(오답 보기)와 wrongExplanations.2 「저지연이어도 서버 Push가 불가능해」가 저지연을 사실처럼 전제한다. 문항 수정 제안(보고만): 근거에서 「저지연이어도」를 걷는다. md 다른 자리 0건(`저지연` 전수 grep의 나머지는 NLB·HPC·스토리지 등 무관).

### A12 · saa-t2-4.md:100·105·106·466 (↔ :97) — 채택
- 지적: 표 `:97`은 내결함성을 「중단 없이 계속 동작(설계 목표)·예비 구성 요소가 넘겨받음」으로 고쳤는데, 시험 문구 해석·원리·시험 포인트는 「완전한 능동 이중화」「중단 자체를 허용하지 않아」로 남았다(내부 모순). 판정: 표 `:97`이 공식과 맞고 나머지 네 줄을 맞춘다.
- 현재 문장(그대로):
  - `saa-t2-4.md:97`

    ```text
    | **내결함성(Fault Tolerance)** | 구성 요소가 실패해도 **중단 없이** 계속 동작(설계 목표) | 예비(중복) 구성 요소가 일을 넘겨받음 | 높음 |
    ```
  - `saa-t2-4.md:100`

    ```text
    > **시험 문구 해석**: "highly available" → Multi-AZ + 자동 복구 조합으로 답합니다. "fault tolerant" → 더 강한 요건으로, 완전한 능동 이중화를 암시합니다. "DR"이 나오면 `saa-t2-5`의 4전략으로 답합니다.
    ```
  - `saa-t2-4.md:105`

    ```text
    > HA는 수 초~수 분의 짧은 중단을 허용하며 비용 대비 자동 복구를 목표로 하고, 내결함성은 중단 자체를 허용하지 않아 능동 이중화 비용이 훨씬 크며, DR은 리전 단위 재해를 대상으로 RTO/RPO로 목표를 수치화합니다.
    ```
  - `saa-t2-4.md:106`

    ```text
    > "highly available"이라는 시험 문구는 Multi-AZ 자동 복구를 의미하고, "fault tolerant"는 그보다 강한 무중단 이중화를 암시하므로 두 키워드를 구분해 다른 설계로 답해야 합니다.
    ```
  - `saa-t2-4.md:466`

    ```text
    | "fault tolerant" | 능동 이중화(Multi-AZ/Multi-Region)로 무중단 |
    ```
- 공식 근거: `https://docs.aws.amazon.com/whitepapers/latest/availability-and-beyond-improving-resilience/fault-tolerance-and-fault-isolation.html` (200 r=0) — "workloads use spare (or redundant) subsystems", "another picks up its work, typically almost seamlessly". 공식 정의는 예비(중복)가 넘겨받는 것이고 능동-능동(active-active)을 요건으로 들지 않으며 「typically almost」로 완전 무중단을 단정하지도 않는다.
- 교체 문장(줄 전체):
  - `saa-t2-4.md:100`

    ```text
    > **시험 문구 해석**: "highly available" → Multi-AZ + 자동 복구 조합으로 답합니다. "fault tolerant" → 더 강한 요건으로, 구성 요소가 실패해도 예비(중복) 구성 요소가 넘겨받아 중단 없이 동작하는 설계를 암시합니다. "DR"이 나오면 `saa-t2-5`의 4전략으로 답합니다.
    ```
  - `saa-t2-4.md:105`

    ```text
    > HA는 수 초~수 분의 짧은 중단을 허용하며 비용 대비 자동 복구를 목표로 하고, 내결함성은 구성 요소가 실패해도 중단 없이 동작하는 것이 목표라 예비(중복) 용량을 미리 갖추는 비용이 훨씬 크며, DR은 리전 단위 재해를 대상으로 RTO/RPO로 목표를 수치화합니다.
    ```
  - `saa-t2-4.md:106`

    ```text
    > "highly available"이라는 시험 문구는 Multi-AZ 자동 복구를 의미하고, "fault tolerant"는 그보다 강한, 예비 구성 요소가 넘겨받는 무중단 설계를 암시하므로 두 키워드를 구분해 다른 설계로 답해야 합니다.
    ```
  - `saa-t2-4.md:466`

    ```text
    | "fault tolerant" | 예비(중복) 구성 요소가 넘겨받아 중단 없이 동작(Multi-AZ/Multi-Region 중복) |
    ```
- 같은 주장의 다른 자리: 0건(`능동 이중화|무중단 이중화|중단 자체를` 전수 grep — 위 네 줄 외에는 `saa-t4-2.md:454` Spot 문맥으로 무관). 문항 0건.

### A13 · saa-t2-5.md:199 — 채택
- 지적: 「DRS는 … 타 클라우드 EC2를 추가 에이전트 없이 … 복제」 — DRS는 소스 서버마다 복제 에이전트 설치가 필수다. 「타 클라우드 EC2」도 성립하지 않는 말이다(EC2는 AWS 서비스).
- 현재 문장(그대로):
  - `saa-t2-5.md:199`

    ```text
    > 이 OS 중립적 특성 덕분에 DRS는 온프레미스 Windows·Linux 서버와 타 클라우드 EC2를 추가 에이전트 없이 단일 방식으로 AWS에 복제할 수 있습니다.
    ```
- 공식 근거: `https://docs.aws.amazon.com/drs/latest/userguide/agent-installation.html` (200 r=0) — "You must install the AWS Replication Agent on each source server". 대상 범위: `https://docs.aws.amazon.com/drs/latest/userguide/what-is-drs.html` (200 r=0) — "on-premises or cloud-based applications".
- 교체 문장(줄 전체):
  - `saa-t2-5.md:199`

    ```text
    > 이 OS 중립적 특성 덕분에 DRS는 온프레미스 Windows·Linux 서버와 다른 클라우드의 서버를, 소스 서버마다 AWS Replication Agent를 설치하는 단일 방식으로 AWS에 복제할 수 있습니다.
    ```
- 같은 주장의 다른 자리: 0건(`에이전트 없이|에이전트리스` md·문항 전수 grep). 같은 문서 `:193` 「타 클라우드 → AWS 이전 DR에도 활용 가능」은 공식 범위와 맞아 대상 아님. 참고: 같은 원리 블록 `:198`의 「애플리케이션 레벨 복제는 에이전트가 각 앱을 별도로 지원해야」는 다른 주장이라 그대로 둔다.

### A14 · saa-t2-5.md:133 — 보류
- 지적: Aurora Global Database 「장애 시 1분 내 승격」 — 레포 기록(§D `saa-t3-5-q7`: 공식은 RTO를 수치로 주지 않는다)과 어긋난다.
- 현재 문장(그대로):
  - `saa-t2-5.md:133`

    ```text
    | Aurora | **Global Database** | 전용 인프라, 보조 리전 복제 지연 **1초 미만**, 장애 시 1분 내 승격 |
    ```
- 공식 근거: 공식이 두 갈래로 갈린다. ① 사용자 가이드 `https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-global-database-disaster-recovery.html` (200 r=0) — "RTO can be in the order of minutes", 관리형 장애 조치는 "within a few minutes". ② 제품 페이지 `https://aws.amazon.com/rds/aurora/global-database/` (200 r=0) — "promoted to read and write capabilities in less than 1 minute". 문서 문장은 ②와 글자 그대로 맞고 ①과는 어긋난다. 레포는 이미 ① 쪽으로 기울어 있다: `CLAUDE.md` §D(문항에서 「RTO 약 1분 충족」 삭제), `saa-t3-5.md:250` 「RTO는 분 단위」. 「더 구체적인 쪽(사용자 가이드)이 정본」이라는 레포 관례를 적용하면 채택이지만, 제품 페이지가 현재도 같은 수치를 싣고 있어 「공식에 없다」로 단정할 수는 없다 — 컨트롤러 판정 필요.
- 교체 문장(줄 전체):
  - `saa-t2-5.md:133`

    ```text
    | Aurora | **Global Database** | 전용 인프라, 보조 리전 복제 지연 **1초 미만**, 장애 시 보조 리전 승격(RTO는 분 단위) |   ← 채택으로 판정할 때의 안
    ```
- 같은 주장의 다른 자리: 같은 수치 — `saa-t2-5.md:280`(자가 점검 Q2 정답 「장애 시 1분 내 보조 리전을 Primary로 승격」), 문항 `saa-t2-5-q8` options[0] 「장애 시 1분 내 승격이 가능하다」·explanation 「통상 1분 내 … 승격(보장값이 아니라 전형적 수치)」. 반대쪽(분 단위)으로 적은 자리 — `saa-t3-5.md:250`. 즉 SAA 안에서 두 표기가 공존한다. `saa-t3-5-q7` 지문의 「RTO 약 1분」은 시나리오 요구값이다.

### A15 · saa-t2-5.md:255 (↔ :96) — 채택
- 지적: 함정 4 원리가 「백업 주기만큼 반드시 손실이 발생한다」로 단정한다. 같은 문서 `:96`은 「PITR로 RPO 5분 … 백업 주기가 곧 RPO라고 단정하지 않는 쪽」을 적는다(내부 모순).
- 현재 문장(그대로):
  - `saa-t2-5.md:255`

    ```text
       (원리: §1 — RPO는 복구 가능한 가장 최근 시점까지의 거리이며, 백업 주기만큼 반드시 손실이 발생한다.)
    ```
- 공식 근거: `https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_planning_for_recovery_disaster_recovery.html` (200 r=0) — "can lower RPO to as low as 5 minutes in some cases". 백업 주기와 RPO가 항상 같지는 않다.
- 교체 문장(줄 전체):
  - `saa-t2-5.md:255`

    ```text
       (원리: §1 — RPO는 복구 가능한 가장 최근 시점까지의 거리이며, 마지막 백업(또는 PITR이 닿는 시점) 이후의 변경은 잃을 수 있어 0이 되지 않는다.)
    ```
- 같은 주장의 다른 자리: 0건(`반드시 손실|백업 주기만큼` 전수 grep). 바로 윗줄 `:254` 「RPO가 마지막 백업 이후(수 시간)」는 표 `:89`의 「시간 단위」와 맞아 그대로 둔다.

### A16 · saa-t2-5.md:137 — 채택
- 지적: 오탈자 「최선택」.
- 현재 문장(그대로):
  - `saa-t2-5.md:137`

    ```text
    > Aurora Global Database는 RPO를 가장 낮추고 싶을 때 최선택입니다. "리전 간 1초 미만 복제"가 시험 문구로 자주 등장합니다.
    ```
- 공식 근거: 공식 확인 불요(단순 오기). 발화 seg025는 이미 「최선의 선택」으로 읽는다.
- 교체 문장(줄 전체):
  - `saa-t2-5.md:137`

    ```text
    > Aurora Global Database는 RPO를 가장 낮추고 싶을 때 최선의 선택입니다. "리전 간 1초 미만 복제"가 시험 문구로 자주 등장합니다.
    ```
- 같은 주장의 다른 자리: 0건(`최선택` md·문항 전수 grep).

### A17 · saa-t1-1.md:75 — 채택(경미)
- 지적: 용어 표가 SAML 2.0을 「기업 디렉터리(AD 등) IdP가 발급」으로 적는다. Active Directory 자체는 SAML IdP가 아니다(문서 `:398` 정정 ③, `:248`의 ID 소스 3갈래와 결이 다르다).
- 현재 문장(그대로):
  - `saa-t1-1.md:75`

    ```text
    | **SAML 2.0** | Security Assertion Markup Language | 기업 디렉터리(AD 등) IdP가 발급하는 XML 기반 인증 토큰 표준 |
    ```
- 공식 근거: `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_saml.html` (200 r=0) — "like Microsoft Active Directory Federation Service (AD FS …), Shibboleth". SAML IdP로 드는 것은 AD가 아니라 AD FS다. `https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source.html` (200 r=0)은 외부 IdP와 Active Directory를 별개 갈래로 나열한다.
- 교체 문장(줄 전체):
  - `saa-t1-1.md:75`

    ```text
    | **SAML 2.0** | Security Assertion Markup Language | SAML 2.0 호환 IdP(AD FS·Shibboleth·Okta 등)가 발급하는 XML 기반 인증 토큰 표준 |
    ```
- 같은 주장의 다른 자리: `saa-t1-1.md:249` 표 행 「SAML 2.0 (IAM 직접) | 단일 계정, 기업 디렉터리(AD/Shibboleth)」 — 같은 표기(「AD/Shibboleth」→「AD FS/Shibboleth」 권장). 문항 0건.
