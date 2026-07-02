# 2단 반박 검증 — V9 CFN·거버넌스 — 2026-07

독립 검증자로서 각 의심 항목의 "오탐" 가능성을 적극 반박 시도함. 판정 근거는 AWS 공식 문서 실조회.
결론: 12항목 전부, 발견자 지적이 AWS 공식 사실과 일치 → 문서 진술이 부정확. 반박(REFUTE) 실패 = 전부 CONFIRMED.
(단 일부는 문서가 애매하게 서술했거나 다른 곳에서 자기모순인 "경미" 유형 — 근거란에 명시.)

## 조회 출처 (URL 목록)

- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html (RDS 기본 DeletionPolicy=Snapshot 명시)
- https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-stack-failure-options.html (create 실패 기본 OnFailure=ROLLBACK)
- https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings-severity.html (Critical/High/Medium/Low 4단)
- https://docs.aws.amazon.com/awssupport/latest/user/trusted-advisor-check-reference.html (범주 6개 = 5 + Operational Excellence)
- https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-patch-patchgroups.html (`Patch Group` 또는 `PatchGroup` 둘 다 허용)
- https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-scheduled-rule-pattern.html (cron 6필드 연도 포함, 일·요일 동시 * 불가)
- https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config-rules.html (트리거 3종: 변경/주기/하이브리드)
- https://repost.aws/knowledge-center/ec2-instance-ami-share (기본 aws/ebs 키 암호화 AMI 공유 불가, CMK 필요)
- https://aws.amazon.com/about-aws/whats-new/2024/02/aws-systems-manager-parameter-store-cross-account-sharing/ + https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-shared-parameters.html (Parameter Store RAM 교차계정 공유, 2024-02, 고급티어)
- https://docs.aws.amazon.com/IAM/latest/APIReference/API_PutGroupPolicy.html (그룹에 인라인 정책 임베드)
- https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_scps.html (SCP는 멤버계정 루트 포함 모든 주체 적용; 관리계정만 예외)

## 판정

| ID | 판정 | 근거(3줄 이내) |
|---|---|---|
| DOC-SOA-201 (M) | CONFIRMED | create 실패 기본 OnFailure=ROLLBACK → 스택은 `ROLLBACK_COMPLETE`로 잔존(동명 재생성 전 수동 삭제 필요), 제거는 OnFailure=DELETE만. 문서 §3·Q5는 "부분 리소스 정리하고 스택을 제거"로 서술 — 리소스 롤백과 스택 셸 제거를 혼동(경미하나 부정확). 발견자 핵심(기본=잔존) 정확. |
| DOC-SOA-203 (M) | CONFIRMED | 공식 DeletionPolicy 문서 명시: **예외 — `AWS::RDS::DBCluster` 및 `DBClusterIdentifier` 없는 `DBInstance`의 기본 정책은 Snapshot**. 문서의 "RDS 기본 DeletionPolicy=삭제" 단정(함정2·Q4)은 오류. 발견자 정확. |
| DOC-SOA-204 (L) | CONFIRMED | StackSets는 단일 계정×다중 리전 배포에 표준 사용 가능(셀프관리형으로 자기 계정 여러 리전). 문서의 "다중 계정×다중 리전 전용"·"단일 계정·리전은 일반 스택으로 충분"(§5·함정3)의 **전용** 프레이밍이 부정확. 발견자 정확. |
| DOC-SOA-209 (L) | CONFIRMED | EventBridge cron은 **6 필수 필드(분 시 일 월 요일 연도)**, 일·요일 동시 `*` 불가(한쪽 `?` 필요). 문서 t3-4 용어표는 cron을 "분 시 일 월 요일" 5필드로 정의 → EventBridge 기준 부정확. 발견자 정확. |
| DOC-SOA-206 (M) | CONFIRMED | 기본 AWS 관리형 키(aws/ebs) 암호화 스냅샷 기반 AMI는 **공유 자체 불가**(관리형 키 교차계정 공유 불가) → CMK로 재암호화 필요. 문서 "KMS 키도 함께 공유하면 됨"은 기본키 케이스에서 오도. 발견자 정확. |
| DOC-SOA-207 (L) | CONFIRMED | 공식 문서 명시: 패치 그룹은 태그 키 **`Patch Group` 또는 `PatchGroup` 둘 다** 정의 가능(IMDS 태그 허용 시 `PatchGroup` 필수). 문서(t3-2·t3-3)의 "`Patch Group`(공백)만 인식" 단정은 오류. 발견자 정확. |
| DOC-SOA-208 (L) | CONFIRMED | Parameter Store는 2024-02부터 **AWS RAM 교차계정 공유 지원**(고급 티어). 문서 t3-3의 "교차 계정 비밀 공유가 핵심이면 Secrets Manager" 차별점은 현행성 상실. 발견자 정확. |
| DOC-SOA-211 (M) | CONFIRMED | `PutGroupPolicy` API는 IAM **그룹에 인라인 정책 임베드** — 인라인은 사용자·그룹·역할 모두 가능. 문서 t4-1 정책유형표는 인라인 부착 대상을 "사용자·역할"로만 표기(그룹 누락). 발견자 정확. |
| DOC-SOA-212 (M) | CONFIRMED | 멤버 계정 루트도 SCP 적용 대상(공식: 관리계정만 예외). 문서 t4-1 자체가 다른 곳(§7·시험포인트·Q1·Q5)에서 "루트 포함 모든 주체 적용"을 옳게 서술 → line 208 "특정 S3/SCP 우회"는 자기모순·오류. 발견자 정확. |
| DOC-SOA-301 (M) | CONFIRMED | Config 규칙 트리거는 **변경(configuration changes)·주기(periodic)·하이브리드 3종**이며 변경 시 CI 변경알림 후 평가함. 문서 t4-2의 "변경 시가 아니라 지속적으로 평가"(§1 제목·함정)는 변경 트리거 존재를 부정 → 부정확. 발견자 정확. |
| DOC-SOA-302 (M) | CONFIRMED | 현행 GuardDuty severity는 **Critical(9.0–10.0)·High·Medium·Low 4단**. 문서 t4-2의 "Low/Medium/High 3단"은 구식. 발견자 정확. |
| DOC-SOA-304 (M) | CONFIRMED | 현행 Trusted Advisor 점검 범주는 **6개**(비용·성능·보안·내결함성·서비스 한도 + **Operational Excellence**). 문서 t4-2의 "5개 범주" 단정(체크리스트·시험포인트·§5)은 구식. 발견자 정확. |
