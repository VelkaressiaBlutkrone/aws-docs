# SOA-C03 · DEA-C01 출처 URL 전수 실측 (2026-10-29)

_사람 검수 **착수 전** 준비 작업([착수 노트](2026-10-29-soa-dea-review-prep.md) §6-3). 루브릭 C4("URL 유효")는 사람 몫인데 **어느 자동 가드도 URL이 실재하는지 보지 않아서**, 먼저 기계로 전수 실측했다. 결과와 교체 근거의 정본은 이 문서다._

> **왜 먼저 했나.** 문항 구조 가드(`<cert>_questions_test` · `review.mjs`의 `questionFlags`)는 `sources`가 비어 있지 않고 `http(s)`로 시작하는지만 본다. 그래서 죽은 링크가 조용히 쌓인다 — SAA에서 `rds-reserved-instances.html`이 **6문항**의 깨진 링크였고(2026-10-28 발견), MLA 도메인 3에서는 작성 URL **23건**이 실제 오류였다. 둘 다 사람이 읽다가 발견했다.

---

## 0. 결과 요약

| | 수 |
|---|---|
| 측정 대상 문항 | **556** (SOA 300 + DEA 256) |
| `sources` 참조 | **813** |
| 고유 URL | **561** |
| 호스트 | `docs.aws.amazon.com` 526 · `aws.amazon.com` 30 · `repost.aws` 5 |
| ✅ 정상(리다이렉트 없음) | **534** |
| ⚠️ 리다이렉트 | **22** — 전부 **SOA**, DEA는 **0건** |
| 🤖 봇 체크로 curl 403 | **5** (`repost.aws`) → 실제 브라우저로 **전부 실재 확인** |

**교체한 문항 42건 · 학습문서 2편**(`soa-t1-1.md` · `soa-t3-1.md` — **라이브 문서라 본문이 바뀐다**).
**정답 인덱스(`correct`) 변경 0건 · `verified` 변경 0건** — 출처 교체는 사실 서술을 바꾸지 않는 핫픽스다.

---

## 1. 측정 방법과 ⚠️ 함정

```sh
# 1) sources 전수 수집(문항 JSON에서)
# 2) 각 URL을 실측 — 상태 코드만 보면 안 된다(아래)
curl -sS -o /dev/null -L --max-time 30 \
  -w '%{http_code}|%{num_redirects}|%{url_effective}' "<url>"
```

### ⚠️ `docs.aws.amazon.com`은 없는 페이지에도 404를 주지 않는다

**대조군을 먼저 세워 확인했다**(0건·전부 200이라는 결과를 그냥 믿지 않기 위해):

| 넣은 URL | 결과 |
|---|---|
| 정상 페이지(`cloudwatch_concepts.html`) | `200` · 리다이렉트 **0** |
| 이미 알려진 죽은 링크(`rds-reserved-instances.html`) | `200` · 리다이렉트 **1** → `AmazonRDS/latest/UserGuide/` |
| **일부러 틀린 슬러그**(`this-page-does-not-exist-xyz.html`) | `200` · 리다이렉트 **1** → `AmazonRDS/latest/UserGuide/` |

→ **판정 신호는 상태 코드가 아니라 리다이렉트 발생 여부**다. 561개 전부 `200`이었고, 실제 결함은 리다이렉트 22건이었다. 그리고 **인덱스(`…/`)로 보내는 것이 "페이지 소멸"**, 다른 `.html`로 보내는 것이 "이름 변경"이다.

### ⚠️ `repost.aws`는 기본 curl에 403을 준다

봇 체크다 — 죽은 링크가 아니다. 브라우저 User-Agent 위조는 하지 않고(분류기가 차단하며, 애초에 적절한 방법이 아니다) **내장 브라우저(실제 브라우저)로 5건을 직접 열어** 본문이 뜨는 것을 확인했다. 전부 실재한다.

### ⚠️ 슬러그(파일명)로 세면 거짓 양성이 난다

교체 URL이 옛 URL의 **부분 문자열**인 경우가 있다:

- `ebs/latest/userguide/ebs-optimized.html` → `AWSEC2/latest/UserGuide/ebs-optimized.html`
- `AWSCloudFormation/latest/**UserGuide**/intrinsic-function-reference-findinmap.html` → `…/**TemplateReference**/…`

가드와 집계는 **전체 URL**로 센다. (#270에서 `drop: 'ElastiCache/latest/dg/WhatIs'`가 새 출처 `WhatIs.deployment.html`의 부분 문자열이어서 거짓 실패한 것과 같은 계열이다.)

### ⚠️ 학습문서(`.md`)도 함께 센다 — **3건이 거기 있었다**

문항 가드는 `.md`를 보지 않는다. 2026-10-28에 §D 출처 교체를 `.questions.json`만 대상으로 해서 `saa-t4-3.md`에 같은 깨진 링크가 2곳 남았다. 그래서 이번에는 `assets/content/**` **전수**(모든 자격증의 `.md` + `.questions.json`)를 훑었고 **라이브 학습문서 2편에서 3개소**를 찾았다:

| 파일 | 위치 | URL |
|---|---|---|
| `soa-t1-1.md` | 프런트매터 `sources:` + 📌 출처 목록 | `AlarmThatSendsEmail.html` · `Create_alarm_on_alarm.html` |
| `soa-t3-1.md` | 프런트매터 `sources:` + 📌 출처 목록 | `aws-attribute-deletionpolicy.html` |

다른 자격증(CLF·SAA·MLA·DEA) 콘텐츠에는 **0건**이었다.

---

## 2. A군 — 인덱스로 리다이렉트 = **페이지 소멸** (7건)

대체 페이지를 **공식 문서 본문을 열어** 고르고, 그 페이지가 문항이 인용하는 사실을 실제로 담는지 확인했다.

| # | 소멸한 URL | 대체 | 문항 | 근거(대체 페이지가 적는 문장) |
|---|---|---|---|---|
| A1 | `AmazonCloudWatch/…/Create_alarm_on_alarm.html` | `AmazonCloudWatch/…/CloudWatch_Alarms.html` | `soa-t1-1-q8`·`q11` + `soa-t1-1.md`는 `Create_Composite_Alarm.html` | "A *composite alarm* includes a rule expression…" / "**Using composite alarms can reduce alarm noise.**" / "Composite alarms can send Amazon SNS notifications … but **can't perform EC2 actions or Auto Scaling actions**" |
| A2 | `ebs/latest/userguide/ebs-optimized.html` | `AWSEC2/latest/UserGuide/ebs-optimized.html` | `soa-t1-5-q9` | "An instance's EBS performance is **bounded by the instance type's performance limits, or the aggregated performance of its attached volumes, whichever is smaller**." |
| A3 | `autoscaling/…/consolidated-view-of-warm-up-settings.html` | `autoscaling/…/ec2-auto-scaling-default-instance-warmup.html` | `soa-t2-1-q6` | "how long after an instance reaches the `InService` state it waits before **contributing usage data to the aggregated metrics** … keeps dynamic scaling from being affected by metrics for individual instances … **temporarily high usage**" + "To optimize the performance of your **target tracking and step scaling** policies…" |
| A4 | `wellarchitected/latest/reliability-pillar/testing-disaster-recovery.html` | `wellarchitected/latest/reliability-pillar/rel_planning_for_recovery_dr_tested.html` (REL13-BP03) | `soa-t2-4-q15` | "Regularly test failover to your recovery site to verify that it operates properly and that **RTO and RPO are met**." |
| A5 | `eventbridge/…/eb-service-event.html` | `eventbridge/…/eb-log-api-call.html` | `soa-t3-4-q6` | "You can use Amazon EventBridge rules to **react to API calls made by an AWS service that are recorded by AWS CloudTrail**." |
| A6 | `directconnect/…/high_resiliency_selftest.html` | `wellarchitected/latest/framework/rel_planning_network_topology_ha_conn_private_networks.html` (REL02-BP02) | `soa-t5-2-q10` | "You can also consider AWS Site-to-Site VPN ending on an AWS Transit Gateway as a **cost-effective backup to your primary AWS Direct Connect connection**." |
| A7 | `vpc/latest/userguide/vpc-troubleshooting.html` | `vpc/latest/userguide/infrastructure-security.html` | `soa-t5-4-q12` | "Use security groups as the **primary mechanism** for controlling network access … network ACLs … **apply to an entire subnet** … Configure subnet route tables … **bastion host or NAT gateway**" + §Compare security groups and network ACLs |

### A6에서 기각한 후보 2개 — ⚠️ **"DX over VPN"과 "VPN over DX"를 또 섞을 자리였다**

- `directconnect/…/resiliency_toolkit.html` (살아 있음) — **전용 연결을 몇 개 주문해 99.99%/99.9% SLA를 맞추는가**를 다루고, "VPN을 백업으로 쓴다"는 말이 없다. 기각.
- `whitepapers/latest/aws-vpc-connectivity-options/aws-direct-connect-site-to-site-vpn.html` (살아 있음) — 제목이 맞아 보이지만 내용은 **퍼블릭 VIF 위에 IPsec을 얹는 암호화 DX**(= `VPN over Direct Connect`)다. `soa-t5-2-q10`이 묻는 **장애 시 우회용 백업**이 아니다. 기각.
  - 같은 혼동이 2026-10-28에 라이브 `saa-t3-8.md`에서 5개소 발견돼 정정됐다(#266). 제목만 보고 고르면 반복된다.

### A7은 ⚠️ **검수자 판단이 필요하다**

`soa-t5-4-q12`는 "SG → NACL → 라우팅 테이블 → IGW/NAT → DNS"라는 **진단 순서**를 묻는다. `infrastructure-security.html`은 **계층 위계**(SG가 1차 수단·NACL은 서브넷 단위 2차 통제)를 적지만 **그 순서를 진단 절차로 규정하지는 않는다.** 교체로 죽은 링크는 사라졌으나 C4 적합성은 사람이 판정한다.

---

## 3. B군 — 다른 페이지로 이름 변경 (15건)

AWS 자신의 301이 가리키는 곳을 정본으로 쓴다(= AWS가 "내용이 여기로 옮겨졌다"고 말한 것). 다만 **4건은 보고의 리다이렉트 대상보다 정확한 페이지가 있어 그쪽을 썼고, 그 4건은 본문을 열어 확인했다.**

| # | 옛 URL | 새 URL | 문항 | 비고 |
|---|---|---|---|---|
| B1 | `AmazonCloudWatch/…/AlarmThatSendsEmail.html` | **사실별로 3분할**(아래) | `soa-t1-1` q1·q4·q5·q6·q7·q8·q11·q14 (**8문항**) + `soa-t1-1.md` | 301은 `CloudWatch_Alarms.html` 하나로 보내지만 옛 페이지가 **네 페이지로 쪼개졌다** |
| B2 | `systems-manager/…/sysman-patch-group-tagging.html` | `…/patch-manager-tag-a-patch-group.html` | `soa-t3-2-q10` · `soa-t3-3-q8` | 301 |
| B3 | `guardduty/…/guardduty_findings_cloudwatch.html` | `…/guardduty_findings_eventbridge.html` | `soa-t1-3-q10` | 301 (제목이 이미 EventBridge였다) |
| B4 | `autoscaling/…/as-add-elb-healthcheck.html` | `…/attach-load-balancer-asg.html` | `soa-t1-4-q12` | 301 |
| B5 | `AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-findinmap.html` | `…/**TemplateReference**/…` | `soa-t3-1-q3` | 301 — 가이드가 갈렸다 |
| B6 | `AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks.html` | `…/UserGuide/stack-failure-options.html` | `soa-t3-1-q6` | ⭐ **301은 `stacks.html`(상위 묶음)로 보낸다.** 문항이 묻는 것은 *업데이트 실패 시 롤백 동작*이라 "Choose how to handle failures when provisioning resources"가 정본이다 |
| B7 | `AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-importvalue.html` | `…/**TemplateReference**/…` | `soa-t3-1-q8` | 301 |
| B8 | `AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html` | `…/**TemplateReference**/…` | `soa-t3-1-q13` + `soa-t3-1.md` | 301 |
| B9 | `systems-manager/…/systems-manager-maintenance.html` | `…/maintenance-windows.html` | `soa-t3-2-q11` | 301 |
| B10 | `systems-manager/…/execute-remote-commands.html` | `…/run-command.html` | `soa-t3-3-q3` | 301 |
| B11 | `systems-manager/…/patch-manager-about-aws-runpatchbaseline.html` | `…/patch-manager-aws-runpatchbaseline.html` | `soa-t3-3-q7` | 301 (`about-` 만 빠졌다) |
| B12 | `IAM/…/id_roles_create_for-user_externalid.html` | `IAM/…/confused-deputy.html` | `soa-t4-1-q9` | ⭐ **301은 `id_roles_common-scenarios_third-party.html`로 보낸다.** 외부 ID의 정본 설명은 "The confused deputy problem"에 있다 — "One important aspect of this scenario is the **external ID** … The primary function of the external ID is to address and prevent the confused deputy problem." 문항이 묻는 것이 바로 그것이다 |
| B13 | `IAM/…/access_policies_access-advisor.html` | `IAM/…/access_policies_last-accessed.html` | `soa-t4-1-q12` | 301 (제목 "마지막 액세스 정보로 권한 정제"와 그대로 맞는다) |
| B14 | `config/…/evaluate-config-rules.html` | `config/…/evaluate-config_components.html` | `soa-t4-2-q3` | 301 — 본문 확인: "Components of an AWS Config Rule"에 **Trigger Types · Evaluation Modes** 절이 있어 제목 "평가 모드"와 맞는다 |
| B15 | `vpc/latest/peering/invalid-peering-configurations.html` | `…/vpc-peering-basics.html#vpc-peering-limitations` | `soa-t5-2-q2` | 301이 **앵커까지** 준다 |

### B1 — `AlarmThatSendsEmail.html`이 네 페이지로 쪼개졌다

301 대상 하나로 8문항을 다 보내면 **그 페이지에 없는 사실을 인용**하게 된다(특히 "누락 데이터 처리 4가지 옵션"은 분리된 페이지에만 있다). 그래서 문항이 인용하는 사실별로 갈랐다 — 네 페이지 전부 살아 있는 것을 실측하고 본문을 열어 확인했다.

| 사실 | 페이지 | 문항 |
|---|---|---|
| 경보 상태(OK·ALARM·INSUFFICIENT_DATA) · 평가 기간/데이터 포인트 | `alarm-evaluation.html` | q1 · q4 · q6 |
| 누락 데이터 처리 `notBreaching`·`breaching`·`ignore`·`missing`(기본 `missing`) | `alarms-and-missing-data.html` | q5 · q14 |
| 경보 작업(SNS · **Lambda** · EC2 작업 · Auto Scaling · Systems Manager · 조사) | `alarm-actions.html` | q7 · q8 · q11 |
| 경보 개념 · 복합 경보의 규칙 표현식·노이즈 감소·작업 제약 | `CloudWatch_Alarms.html` | q8·q11의 둘째 출처 + `soa-t1-1.md` 프런트매터 |

`soa-t1-1.md`의 📌 출처 목록은 옛 항목 3("경보 상태·평가·누락 데이터"를 한 페이지로 묶었다)이 쪼개졌으므로 **항목을 둘로 나누고 뒤 번호를 밀었다**(6 → 8항목). 본문이 참고자료 번호를 인용하지 않는 것을 먼저 확인한 뒤 바꿨다.

---

## 4. ⚠️ 검수자 확인 필요 — 이번 교체로 **드러난 내용 결함**

출처를 교체하며 공식 문서 본문을 열다가 발견했다. **이 PR은 URL만 고쳤고 아래는 손대지 않았다** — C1~C3 판정과 정답 변경은 사람 몫이다(루브릭 §2·§3, 정답 인덱스 변경은 사용자 승인 사항).

### `soa-t1-1-q11` — 지문·해설이 EventBridge를 "경보 작업 대상"으로 적는다 (판정: `rewrite` 후보)

- 문항: "경보 상태 변경을 받아 여러 대상으로 라우팅하고 필터링하려 한다. **어떤 경보 작업 대상을 사용하는가?**" / 정답 보기 "EventBridge — 경보 상태 변경 이벤트를 규칙으로 라우팅한다" / 해설 "경보 작업 대상에는 SNS 주제, EC2 작업, Auto Scaling 정책, Systems Manager, **EventBridge**가 있습니다."
- 공식 `alarm-actions.html`이 적는 **경보 작업**: SNS 주제 · **Lambda 함수** · EC2 작업 · Auto Scaling / Application Auto Scaling · Systems Manager OpsItem·Incident · 조사 시작.
- 그리고 EventBridge는 **작업이 아니다** — "Alarms also **emit events to** Amazon EventBridge when they change state, and you can set up Amazon EventBridge to trigger other actions."
- 즉 **지문의 전제("경보 작업 대상")가 틀렸고, 해설은 실제 작업인 Lambda를 빠뜨렸다.** 라우팅·필터링의 해법으로 EventBridge를 고르는 것 자체는 맞지만, 그것은 "작업 대상"이 아니라 "경보가 이벤트를 내보내는 곳"이다.
- 전부 드래프트(`verified: false`)라 **라이브 노출은 없다.**

---

## 5. 회귀 가드

[`flutter_app/test/source_url_retired_test.dart`](../../flutter_app/test/source_url_retired_test.dart) — 24건.

- **대조군 1건** — 콘텐츠 파일이 실제로 읽혔는지(0건 통과가 "파일을 못 읽어서"일 수 있다).
- **은퇴 URL 22건** — 각 URL이 `assets/content/**` **전 자격증 전수**(`.md` + `.questions.json`)에 0건. 전체 URL로 센다.
- **교체 정본 1건(집계)** — 새 URL이 해당 파일에 실재. *"지웠다"만 보면 출처를 통째로 삭제해도 통과*하므로 쌍으로 고정한다.

**운영:** 앞으로 실측에서 리다이렉트한 URL을 교체하면 그 테스트의 `retiredUrls`에 한 줄 추가한다. 그러면 다음 문항·학습문서 작성에서 되살아나지 않는다.

**남은 공백(후속):** URL 실재 자체를 CI가 보지는 않는다(네트워크 의존). 이 가드는 **이미 알려진** 은퇴 URL의 재유입만 막는다. 새 URL의 실재는 작성 시 위 `curl` 레시피로 확인한다.

---

## 6. 재측정 명령

```sh
cd flutter_app
# 1) sources 전수 수집
node -e 'const fs=require("fs"),p=require("path");const s=new Set();
for (const c of ["soa","dea"]) { const d="assets/content/"+c;
  for (const f of fs.readdirSync(d).filter(f=>f.endsWith(".questions.json")))
    for (const q of (JSON.parse(fs.readFileSync(p.join(d,f),"utf8")).questions||[]))
      for (const x of (q.sources||[])) s.add(x.url); }
console.log([...s].join("\n"));' > /tmp/urls.txt
# 2) 실측 — 판정은 num_redirects다(상태 코드는 전부 200이다)
grep -v '^https://repost\.aws' /tmp/urls.txt | xargs -P 6 -I@ sh -c \
  'printf "%s\t%s\n" "@" "$(curl -sS -o /dev/null -L --max-time 30 -w "%{http_code}|%{num_redirects}|%{url_effective}" "@")"'
# 3) repost.aws 는 curl 403(봇 체크) — 실제 브라우저로 확인한다
```
