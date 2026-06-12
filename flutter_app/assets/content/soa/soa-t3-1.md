---
examGuideTaskId: soa-t3-1
certCode: SOA-C03
domain: 3
domainName: 배포, 프로비저닝 및 자동화
domainWeightPct: 22
title: CloudFormation 프로비저닝 (템플릿·스택·StackSets·드리프트)
coversTasks:
  - "3.1"
sources:
  - title: AWS CloudFormation이란 무엇인가 (공식)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html
  - title: 템플릿 구조 (Anatomy) (공식)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html
  - title: 변경 세트로 스택 업데이트 (Change Sets) (공식)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html
  - title: StackSets로 여러 계정·리전에 스택 배포 (공식)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html
  - title: 드리프트 감지로 구성되지 않은 변경 탐지 (공식)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-stack-drift.html
  - title: DeletionPolicy 속성 (공식)
    url: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html
lastVerified: 2026-06-09
---

# CloudFormation 프로비저닝 (템플릿·스택·StackSets·드리프트)

> **커버하는 공식 Task** — SOA-C03 · 도메인 3 「배포, 프로비저닝 및 자동화」(22%) · **Task 3.1 클라우드 리소스 프로비저닝 및 유지 관리** (`soa-t3-1`)
> 이 문서는 CloudFormation(IaC)로 인프라를 코드로 배포·유지하는 데 집중합니다. AMI·패치·배포 전략은 `soa-t3-2`, SSM 운영 자동화는 `soa-t3-3`에서 다룹니다.

---

## ✅ 학습 목표 체크리스트

이 문서를 끝내면 다음을 스스로 설명하고, 콘솔/CLI에서 직접 구성할 수 있어야 합니다.

- [ ] **템플릿 구조** — Resources(유일한 필수 섹션) 외 Parameters·Mappings·Conditions·Outputs의 역할을 설명할 수 있다
- [ ] **변경 세트(Change Set)** — 적용 전에 변경 내용을 미리보기하는 절차를 안다
- [ ] **롤백** — 업데이트/생성 실패 시 자동 롤백 동작과 그 의미를 이해한다
- [ ] **중첩 vs 교차 스택** — 중첩 스택과 `Export`/`Fn::ImportValue` 교차 스택 참조를 구분할 수 있다
- [ ] **StackSets** — 다중 계정·다중 리전에 동일 스택을 배포하는 용도를 안다
- [ ] **드리프트 감지** — 콘솔 밖 수동 변경(out-of-band)을 탐지하는 방법을 안다
- [ ] **DeletionPolicy** — Retain·Snapshot·Delete의 차이와 데이터 보호 용도를 안다
- [ ] **내장 함수** — `Ref`, `Fn::GetAtt`, `Fn::Sub`와 의사 파라미터를 사용할 수 있다

---

## 🎯 왜 중요한가

- 도메인 3(22%)의 핵심은 **"인프라를 손으로 클릭하지 말고 코드로 재현 가능하게 배포·유지하라"**입니다. CloudFormation은 그 출발점이며, SOA 시험은 "무엇이 IaC인가"가 아니라 **운영 절차**(변경을 안전하게 미리보고 적용하기, 수동 변경을 탐지하기, 다계정에 일괄 배포하기)를 묻습니다.
- 시험은 **구체적 동작**을 함정으로 냅니다. 변경 세트는 적용이 아니라 미리보기라는 점, `DeletionPolicy: Retain`이면 스택을 지워도 리소스가 남는다는 점, StackSets는 다중 계정·리전 전용이라는 점, 드리프트 감지는 변경을 "탐지"할 뿐 자동으로 되돌리지는 않는다는 점이 반복 출제됩니다.
- 운영자 관점에서 CloudFormation은 **표준화·재현성·감사 가능성**을 줍니다. 동일 템플릿으로 dev/stage/prod를 똑같이 찍어내고, 변경 세트로 안전하게 검토·승인하며, 드리프트 감지로 "누가 콘솔에서 몰래 바꿨나"를 잡아냅니다.

---

## 🔤 먼저 알아야 할 용어

이 문서를 읽는 데 필요한 기초 용어입니다. 이미 알면 건너뛰세요.

| 용어 | 영문 | 한 줄 풀이 |
|---|---|---|
| **코드형 인프라** | IaC (Infrastructure as Code) | 인프라 구성을 코드 파일로 정의해 버전 관리·재현 배포를 가능하게 하는 방식 — 설계도를 찍어내는 공장과 같다 |
| **프로비저닝** | Provisioning | 템플릿 정의를 바탕으로 실제 클라우드 리소스를 생성·구성하는 과정 |
| **아웃-오브-밴드** | Out-of-band | CloudFormation 스택 외부에서(콘솔·CLI 직접 명령 등) 리소스를 수동으로 변경하는 행위 |
| **물리 ID** | Physical Resource ID | CloudFormation이 리소스를 생성할 때 부여하는 실제 AWS 식별자(예: EC2 인스턴스 ID, S3 버킷 이름) |
| **스택 인스턴스** | Stack Instance | StackSets가 특정 계정·리전 조합에 배포한 개별 스택 단위 |
| **스택 정책** | Stack Policy | 스택 내 특정 리소스에 대한 업데이트 작업을 IAM 정책 형식으로 제한하는 리소스 수준 보호 장치 |
| **종료 보호** | Termination Protection | 스택 자체의 실수 삭제를 막는 스택 수준 잠금 설정 |

---

## 📖 핵심 개념

### 1) 템플릿 구조 — 섹션의 역할

> 공식 정의: **"템플릿은 AWS 리소스와 그 속성을 기술하는 JSON 또는 YAML 형식의 텍스트 파일이며, 이를 기반으로 CloudFormation이 스택을 프로비저닝한다."**

| 섹션 | 필수 여부 | 역할 |
|---|---|---|
| **AWSTemplateFormatVersion** | 선택 | 템플릿 형식 버전(현재 유일 값 `2010-09-09`) |
| **Description** | 선택 | 템플릿 설명 문자열 |
| **Parameters** | 선택 | 스택 생성/업데이트 시 입력받는 값(환경별 차이 주입) |
| **Mappings** | 선택 | 키→값 조회 테이블(예: 리전별 AMI ID) |
| **Conditions** | 선택 | 조건부 리소스 생성(예: prod일 때만 생성) |
| **Resources** | **필수(유일)** | 실제 생성할 AWS 리소스 정의 |
| **Outputs** | 선택 | 스택의 반환값(다른 스택이 Import하거나 콘솔 표시) |

**핵심 사실:**

- **`Resources`만 필수**입니다. 나머지 섹션은 모두 선택입니다.
- **Parameters**로 환경별 차이(인스턴스 크기, VPC ID 등)를 주입하면 **하나의 템플릿을 여러 환경에 재사용**할 수 있습니다. `AllowedValues`, `Default`, `NoEcho`(민감값 마스킹) 같은 제약을 걸 수 있습니다.
- **Mappings**는 정적 조회 테이블입니다. `Fn::FindInMap`으로 참조하며, 리전별 AMI를 고르는 고전적 패턴에 씁니다.
- **Conditions**는 환경에 따라 리소스를 켜고 끕니다(예: `CreateProdResources`가 참일 때만 RDS 다중 AZ).

> 🧠 원리: 왜 `Resources` 하나만 필수이고 나머지 섹션은 모두 선택일까요?
> CloudFormation의 최소 역할은 "어떤 리소스를 만들지" 선언하는 것입니다. Parameters·Conditions·Mappings는 그 선언을 상황에 따라 다르게 만들어 주는 도구이므로, 단일 환경에서 고정값만 사용하면 없어도 스택이 동작합니다.
> 반면 리소스 없는 템플릿은 만들 것이 없어 CloudFormation 자체가 의미를 잃으므로 Resources는 생략할 수 없습니다.
> 이 설계 덕분에 간단한 실험 스택은 Resources 한 섹션만으로 즉시 시작하고, 다환경 재사용이 필요할 때 점진적으로 다른 섹션을 추가할 수 있습니다.

### 2) 의사 파라미터와 내장 함수

| 함수/파라미터 | 역할 | 예 |
|---|---|---|
| **`Ref`** | 파라미터값 또는 리소스의 기본 식별자 반환 | `!Ref MyVPC` → VPC ID |
| **`Fn::GetAtt`** | 리소스의 특정 속성 반환 | `!GetAtt MyBucket.Arn` |
| **`Fn::Sub`** | 변수를 문자열에 치환 | `!Sub "arn:aws:s3:::${BucketName}/*"` |
| **`Fn::FindInMap`** | Mappings 조회 | `!FindInMap [RegionAMI, !Ref "AWS::Region", ami]` |
| **`AWS::Region`** | 의사 파라미터: 스택이 배포된 리전 | — |
| **`AWS::AccountId`** | 의사 파라미터: 현재 계정 ID | — |
| **`AWS::StackName`** | 의사 파라미터: 스택 이름 | — |

> 의사 파라미터(pseudo parameter)는 선언 없이 항상 쓸 수 있는 미리 정의된 값입니다. 리전·계정·스택 이름을 하드코딩하지 않고 동적으로 참조할 때 핵심입니다.

> 🧠 원리: 왜 CloudFormation은 `AWS::Region` 같은 의사 파라미터를 제공할까요?
> 동일한 템플릿을 여러 리전에 배포하면 ARN·엔드포인트·AMI ID 등 리전마다 달라지는 값이 있습니다. 이를 하드코딩하면 복사·붙여넣기 후 수정을 빠뜨릴 위험이 생깁니다.
> 의사 파라미터는 CloudFormation이 스택을 생성하는 시점에 배포 컨텍스트(어느 리전·계정인지)에서 자동으로 채워주므로, 템플릿 작성자는 "지금 어디에 배포되든 올바른 값"을 한 번만 표현하면 됩니다.
> 결과적으로 하나의 템플릿이 리전·계정에 무관하게 올바르게 작동하며, 운영자가 여러 환경에서 같은 템플릿을 재사용할 수 있는 기반이 됩니다.

### 3) 스택 생성·업데이트와 변경 세트(Change Set)

> 공식 정의: **"변경 세트는 스택에 제안된 변경 사항을 실제로 적용하기 전에 미리 볼 수 있게 해 주는 요약이다."**

**스택 업데이트의 핵심 — "미리 보고 적용":**

- 템플릿을 수정한 뒤 **변경 세트를 생성**하면, CloudFormation이 어떤 리소스가 **수정·교체(Replacement)·삭제**될지 목록으로 보여줍니다.
- 특히 **교체(Replacement: True)**가 표시되면 그 리소스는 **삭제 후 재생성**됩니다 — 새 물리 ID가 부여되고, 데이터가 사라질 수 있어 가장 주의해야 합니다.
- 검토 후 **변경 세트를 실행(Execute)**해야 비로소 변경이 적용됩니다. 즉 **변경 세트 생성 자체는 인프라를 바꾸지 않습니다**.

```
# ① 변경 세트 생성 (미리보기)
aws cloudformation create-change-set \
  --stack-name prod-web --change-set-name cs-add-rds \
  --template-body file://template.yaml

# ② 변경 내용 검토
aws cloudformation describe-change-set \
  --stack-name prod-web --change-set-name cs-add-rds

# ③ 승인 후 실행 (이때 실제 적용)
aws cloudformation execute-change-set \
  --stack-name prod-web --change-set-name cs-add-rds
```

**롤백:**

- **생성(Create) 실패** 시 기본 동작은 **전체 롤백**으로, 부분 생성된 리소스를 정리하고 스택을 제거(또는 `ROLLBACK_COMPLETE`)합니다.
- **업데이트(Update) 실패** 시 스택을 **이전 정상 상태로 자동 롤백**합니다.
- 롤백 자체가 실패하면 `UPDATE_ROLLBACK_FAILED` 등으로 멈추며, 수동 개입이 필요합니다.

> 🧠 원리: 왜 변경 세트는 "생성"과 "실행"이 별도 단계로 나뉘어 있을까요?
> 스택에 변경을 가하려면 현재 배포된 리소스 상태를 기준으로 어떤 리소스가 교체(Replacement)·삭제될지 사전에 계산해야 합니다. 이 계산 결과를 먼저 사람이 검토할 수 있게 저장한 것이 변경 세트입니다.
> 특히 Replacement가 발생하면 리소스의 물리 ID가 바뀌고 데이터가 사라질 수 있으므로, 적용 전 확인 단계가 없으면 운영자가 위험성을 인지하지 못한 채 변경이 실행됩니다.
> 두 단계를 분리함으로써 검토·승인 절차를 변경 파이프라인에 자연스럽게 끼워 넣을 수 있고, 변경 세트를 폐기하는 것만으로 적용을 취소할 수 있습니다.

### 4) 중첩 스택 vs 교차 스택 참조

| 방식 | 메커니즘 | 용도 |
|---|---|---|
| **중첩 스택(Nested Stack)** | 부모 템플릿이 `AWS::CloudFormation::Stack`으로 자식 템플릿을 포함 | 공통 컴포넌트(예: 표준 VPC)를 모듈화·재사용 |
| **교차 스택 참조(Cross-Stack)** | 한 스택이 `Outputs`에서 `Export`, 다른 스택이 `Fn::ImportValue`로 가져옴 | 독립적으로 관리되는 스택 간 값 공유(예: 네트워크 스택의 VPC ID를 앱 스택이 사용) |

**핵심 사실:**

- **Export 이름은 리전 내에서 고유**해야 합니다.
- **다른 스택이 `Fn::ImportValue`로 참조 중인 Export 값은 변경/삭제할 수 없습니다** — 먼저 의존하는 스택을 끊어야 합니다. 이 제약 때문에 강하게 결합된 교차 스택은 운영이 번거로울 수 있습니다.
- 중첩 스택은 부모가 자식의 수명주기를 함께 관리하지만, 교차 스택은 **독립적으로 배포·업데이트**됩니다.

> 🧠 원리: 왜 교차 스택에서 다른 스택이 참조 중인 Export 값을 변경할 수 없을까요?
> `Fn::ImportValue`로 값을 가져온 스택은 해당 Export가 변하지 않는다는 전제 하에 배포·동작합니다. CloudFormation이 Export 변경을 허용하면 의존하는 스택들이 자신도 모르는 사이에 잘못된 값을 참조하게 되어 런타임 오류가 발생할 수 있습니다.
> 이 잠금은 "인터페이스 계약"과 같습니다. Export를 바꾸려면 먼저 그 값에 의존하는 모든 스택을 분리해야 하는데, 이 절차가 번거롭더라도 의존 관계를 명시적으로 끊게 함으로써 운영자가 영향 범위를 의식하게 만듭니다.

### 5) StackSets — 다중 계정·다중 리전 배포

> 공식 정의: **"StackSets는 단일 작업으로 여러 계정과 리전에 걸쳐 스택을 생성·업데이트·삭제할 수 있도록 스택 기능을 확장한다."**

- 하나의 템플릿을 **여러 AWS 계정 × 여러 리전**의 조합(스택 인스턴스)에 일괄 배포합니다. 예: 조직 전체 계정에 표준 IAM 역할·가드레일·로깅 구성을 한 번에 배포.
- **권한 모델 2가지:**
  - **셀프 관리형(Self-managed)**: 관리자/실행 IAM 역할을 직접 만들어 신뢰 관계를 구성.
  - **서비스 관리형(Service-managed)**: AWS Organizations와 통합 — 조직/OU 단위 배포, 신규 계정 추가 시 **자동 배포(automatic deployment)**까지 가능.
- 배포 시 **롤아웃 옵션**(동시 처리 수·실패 허용치 등)으로 점진적·안전하게 펼칠 수 있습니다.

> **시험 포인트:** "여러 계정·여러 리전에 동일 구성을 배포"라는 단서가 나오면 정답은 거의 항상 **StackSets**입니다. 단일 스택은 한 계정·한 리전 범위입니다.

> 🧠 원리: 왜 StackSets의 서비스 관리형 모드는 신규 계정에 자동으로 스택을 배포할 수 있을까요?
> 서비스 관리형 모드는 AWS Organizations와 통합되어, 조직 내 어느 계정이 어느 OU에 속하는지 실시간으로 파악합니다. 새 계정이 대상 OU에 추가되면 StackSets가 그 이벤트를 감지해 스택 인스턴스를 자동 생성합니다.
> 반면 셀프 관리형 모드는 관리자가 직접 만든 IAM 역할 신뢰 관계에 의존하므로, 새 계정마다 수동으로 역할을 구성해야 해 자동 배포가 불가능합니다.
> 이 차이가 대규모 조직에서 가드레일·로깅 같은 기준선 구성을 누락 없이 강제하는 데 서비스 관리형을 선택하는 이유입니다.

### 6) 드리프트 감지(Drift Detection)

> 공식 정의: **"드리프트는 스택의 실제 구성이 템플릿에 기대된 구성과 달라진 상태이며, 드리프트 감지는 이를 식별한다."**

- 누군가 **콘솔/CLI로 스택 밖에서(out-of-band) 리소스를 직접 수정**하면, 실제 상태가 템플릿과 어긋납니다(예: 보안 그룹 규칙을 수동 추가).
- **드리프트 감지를 실행**하면 각 리소스를 `IN_SYNC` / `MODIFIED` / `DELETED`로 분류하고, 어떤 속성이 달라졌는지 보여줍니다.
- **중요:** 드리프트 감지는 **탐지만** 합니다 — 자동으로 되돌리지 않습니다. 교정하려면 수동 변경을 원복하거나, 템플릿을 현실에 맞게 갱신해 다시 배포해야 합니다.

> 🧠 원리: 왜 드리프트 감지는 차이를 탐지만 하고 자동으로 되돌리지 않을까요?
> out-of-band 변경이 모두 실수는 아닙니다. 장애 대응 중 긴급하게 보안 그룹 규칙을 추가하거나 용량을 늘리는 경우처럼, 운영자가 의도적으로 가한 변경일 수 있습니다.
> 자동 원복이 이런 긴급 조치를 덮어쓰면 장애를 악화시킬 수 있으므로, CloudFormation은 판단을 운영자에게 위임합니다.
> 드리프트 보고서를 보고 원인을 파악한 뒤 "원복할지 vs 템플릿에 반영할지"를 운영자가 결정하는 구조가 안전한 이유입니다.

### 7) DeletionPolicy — 삭제 시 데이터 보호

> 공식 정의: **"DeletionPolicy 속성으로 스택이 삭제될 때 리소스를 보존하거나(백업) 백업할지 지정한다."**

| 값 | 동작 |
|---|---|
| **Delete** (기본값 대부분) | 스택 삭제 시 리소스도 삭제 |
| **Retain** | 스택을 삭제해도 **리소스는 남김**(고아 리소스로 보존) |
| **Snapshot** | 삭제 전에 **스냅샷 생성**(지원 리소스만: RDS, EBS, ElastiCache, Redshift 등) |

> **운영 핵심:** RDS·EBS 같은 **상태 저장(stateful) 리소스**에는 `Retain` 또는 `Snapshot`을 걸어, 실수로 스택을 지워도 데이터가 사라지지 않게 합니다. 비슷한 보호 장치로 **스택 종료 보호(termination protection)**와 리소스 수준 변경을 막는 **스택 정책(stack policy)**이 있습니다.

> 🧠 원리: 왜 `DeletionPolicy: Snapshot`은 RDS·EBS 같은 특정 리소스에만 적용할 수 있을까요?
> 스냅샷은 해당 서비스가 특정 시점의 디스크 상태를 캡처하는 API를 지원해야 동작합니다. RDS·EBS·ElastiCache 같은 상태 저장 서비스는 이 API를 제공하지만, EC2 보안 그룹·IAM 역할처럼 데이터가 아닌 구성 리소스에는 캡처할 영구 데이터 자체가 없습니다.
> 따라서 Snapshot을 지원하지 않는 리소스에 이 값을 지정하면 CloudFormation은 오류를 반환합니다.
> 운영자 관점에서 핵심은 "상태가 있는 리소스에는 반드시 Retain 또는 Snapshot을 선택하고, 구성만 있는 리소스는 Delete(기본값)를 유지한다"는 규칙입니다.

---

## ✍️ 시험 포인트

- **템플릿에서 필수 섹션은 `Resources` 하나뿐**. 나머지는 모두 선택.
- **변경 세트(Change Set)는 적용 전 "미리보기"**. 생성만으로는 바뀌지 않고, **실행(Execute)해야** 적용됨. **Replacement=True는 삭제 후 재생성** 신호.
- **롤백**: 생성 실패는 정리/롤백, 업데이트 실패는 **이전 상태로 자동 롤백**.
- **교차 스택**: `Outputs`의 `Export` ↔ 다른 스택의 `Fn::ImportValue`. **Import 중인 Export는 변경/삭제 불가**.
- **중첩 스택**은 부모가 자식 포함, **교차 스택**은 독립 배포 + 값 공유.
- **StackSets = 다중 계정 × 다중 리전** 일괄 배포. Organizations 통합 시 신규 계정 자동 배포.
- **드리프트 감지 = out-of-band 수동 변경 탐지(탐지만, 자동 복구 아님)**.
- **DeletionPolicy**: Delete / **Retain(남김)** / **Snapshot(스냅샷 후 삭제)**. stateful 리소스 보호에 필수.
- **내장 함수**: `Ref`(식별자), `Fn::GetAtt`(속성), `Fn::Sub`(치환), `Fn::FindInMap`(Mappings). 의사 파라미터 `AWS::Region`·`AWS::AccountId`.

---

## ⚠️ 흔한 함정

1. **"변경 세트를 만들면 변경이 적용된다."** → 아닙니다. 변경 세트 **생성은 미리보기일 뿐**이고, **실행(Execute)**해야 실제로 바뀝니다. 그 사이에 검토·승인을 끼워 넣는 것이 안전 배포의 핵심입니다.
   *(원리: §3 — 변경 세트는 Replacement 등 위험 변경을 사전에 계산·검토하도록 생성과 실행이 분리된 구조다.)*

2. **"DeletionPolicy 없이 스택을 지워도 DB는 안전하다."** → 기본 동작은 **함께 삭제**입니다. RDS·EBS 등은 `DeletionPolicy: Retain`이나 `Snapshot`을 명시해야 데이터가 보존됩니다.
   *(원리: §7 — 상태 저장 리소스에는 명시적 DeletionPolicy 없이는 스택 삭제 시 데이터가 함께 제거된다.)*

3. **"StackSets는 한 계정 안에서 여러 스택을 만드는 기능이다."** → StackSets의 본질은 **다중 계정 × 다중 리전** 배포입니다. 한 계정·한 리전에 여러 리소스는 일반 단일 스택으로 충분합니다.
   *(원리: §5 — StackSets는 계정·리전 조합(스택 인스턴스)에 일괄 배포하기 위한 기능으로, 단일 계정·리전 범위를 벗어나지 않으면 단일 스택으로 충분하다.)*

4. **"드리프트 감지가 수동 변경을 자동으로 되돌린다."** → 드리프트 감지는 **차이를 탐지·보고만** 합니다. 복구는 수동 원복 또는 템플릿 재배포로 직접 해야 합니다.
   *(원리: §6 — out-of-band 변경이 의도적일 수 있어 자동 원복은 위험하므로, 판단을 운영자에게 위임하는 구조다.)*

5. **"Export한 값은 자유롭게 바꿀 수 있다."** → 다른 스택이 `Fn::ImportValue`로 **참조 중인 Export는 변경·삭제할 수 없습니다**. 먼저 의존 스택을 분리해야 합니다.
   *(원리: §4 — 의존 스택이 Export 계약에 기반해 배포되어 있으므로, 잠금을 통해 운영자가 영향 범위를 명시적으로 끊도록 강제한다.)*

6. **"리소스를 in-place로 수정하니 안전하다."** → 변경 세트에 **Replacement: True**가 뜨면 해당 리소스는 **삭제 후 새로 생성**됩니다(새 물리 ID·데이터 손실 가능). 적용 전에 반드시 교체 여부를 확인해야 합니다.
   *(원리: §3 — 변경 세트 실행 전 Replacement 여부를 확인해야 물리 ID 교체와 데이터 손실 위험을 사전에 인지할 수 있다.)*

---

## 🧪 자가 점검

> 아래는 학습용 자가 점검입니다. (정식 검증 문항은 별도 문항 파일 참조)

**Q1.** 운영 스택에 RDS를 추가하는 템플릿 변경을 적용하기 전에, 어떤 리소스가 교체·삭제되는지 안전하게 확인하려면 어떤 기능을 쓰나요?

<details><summary>정답 보기</summary>

**변경 세트(Change Set)**를 생성해 검토합니다. 변경 세트는 어떤 리소스가 추가·수정·삭제되는지, 특히 **Replacement: True**(삭제 후 재생성)가 발생하는지 미리 보여 줍니다. 검토·승인 후 **변경 세트를 실행(Execute)**해야 실제로 적용됩니다. 생성만으로는 인프라가 바뀌지 않으므로 운영 변경의 안전장치로 사용합니다.
</details>

**Q2.** AWS Organizations로 관리하는 50개 계정 전체에, 표준 보안 IAM 역할과 로깅 구성을 ap-northeast-2와 us-east-1 두 리전에 일괄 배포하려 합니다. 무엇을 사용하나요?

<details><summary>정답 보기</summary>

**CloudFormation StackSets**를 사용합니다. 하나의 템플릿을 **여러 계정 × 여러 리전**의 스택 인스턴스로 일괄 배포합니다. Organizations와 통합한 **서비스 관리형(Service-managed)** 권한 모델을 쓰면 조직/OU 단위로 배포하고, 신규 계정이 추가될 때 **자동 배포**까지 구성할 수 있습니다.
</details>

**Q3.** 누군가 콘솔에서 스택이 만든 보안 그룹에 인바운드 규칙을 수동으로 추가했습니다. 템플릿과 실제 구성의 차이를 확인하려면?

<details><summary>정답 보기</summary>

**드리프트 감지(Drift Detection)**를 실행합니다. 각 리소스를 `IN_SYNC` / `MODIFIED` / `DELETED`로 분류하고 어떤 속성이 달라졌는지 보고합니다. 단, 드리프트 감지는 **탐지만** 하므로, 교정은 수동 원복 또는 템플릿을 현실에 맞게 수정해 재배포하는 방식으로 직접 해야 합니다.
</details>

**Q4.** 실수로 운영 스택을 삭제하더라도 RDS 데이터베이스만은 보존되도록 하려면 템플릿에 무엇을 설정하나요?

<details><summary>정답 보기</summary>

RDS 리소스에 **`DeletionPolicy: Retain`**(리소스를 남김) 또는 **`Snapshot`**(삭제 전 스냅샷 생성)을 설정합니다. 기본 동작은 스택과 함께 삭제이므로, stateful 리소스에는 명시적 보호 정책이 필요합니다. 추가로 **스택 종료 보호**를 켜서 스택 자체의 실수 삭제도 막을 수 있습니다.
</details>

**Q5 (원리).** 왜 CloudFormation은 스택 생성 실패 시 부분 생성된 리소스를 그대로 두지 않고 전체 롤백으로 정리할까요?

<details><summary>정답 보기</summary>

스택은 여러 리소스의 의존 관계가 있는 단위입니다. 일부 리소스만 남으면 의존 관계가 불완전한 상태가 되고, 운영자가 어떤 리소스가 생성됐는지 추적해 수동으로 정리해야 합니다. CloudFormation이 실패 시 전체를 정리하면 스택이 "존재하거나 없거나" 두 상태만 갖게 되어, 운영자는 재시도 전에 상태를 직접 점검하지 않아도 됩니다.
</details>

---

### 📌 출처 (verified)

이 문서의 사실 진술은 아래 공식 AWS 자료를 기준으로 작성했습니다. (작성·대조: 2026-06-09)

1. AWS CloudFormation이란 무엇인가 — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html
2. 템플릿 구조(Anatomy) — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-anatomy.html
3. 변경 세트로 스택 업데이트 — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks-changesets.html
4. StackSets로 여러 계정·리전에 배포 — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/what-is-cfnstacksets.html
5. 드리프트 감지 — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-stack-drift.html
6. DeletionPolicy 속성 — https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html
