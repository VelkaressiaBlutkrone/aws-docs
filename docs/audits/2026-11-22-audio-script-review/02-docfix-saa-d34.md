# SAA 도메인 3·4 학습문서 지적 판정

- 입력: `saa-d3.md`·`saa-d4.md`의 「컨트롤러 요청」 절 전부 + 항목 본문에 적힌 문서 쪽 의심(`saa-t3-3 seg030`).
- 판정일: 2026-11-22. 이 판정은 보고서 한 파일만 썼고 학습문서·문항·대본은 고치지 않았다.

## 요약

| 판정 | 건수 |
|---|---|
| 채택 | 22 |
| 기각 | 6 |
| 보류 | 0 |

- 학습문서 내용이 아닌 요청(발음·표기·코드 블록·삽입 id·재합성 범위·R3 분량 등)은 36건이고 판정하지 않았다(d3 32 · d4 4).
- ⚠️ **검수자가 제기하지 않은 사실 변경 1건을 판정 중에 찾았다(A-06).** AWS가 2026-11에 Lambda 함수 타임아웃 상한을 15분에서 30분으로 올렸다. 개발자 안내서·API 참조·What's New 셋이 일치하고 FAQ만 아직 15분이다. SAA 전역에 걸친 주제라 채택으로 세되 **별 배치와 사용자 판단이 필요하다**(시험이 무엇을 묻는지는 공식 문서로 정할 수 없다).
- 채택 22건 가운데 문항에도 같은 주장이 남은 것은 5건이다(A-03·A-06·A-08·A-12·A-21). A-02는 문항 출처 제목 한 곳이 요약형으로 남는다. 문항은 고치지 않았고 `verified`·`correct`는 다루지 않았다.
- 이미 레포에 같은 주제의 판정이 있는 건: A-07(RDS 암호화 전환 경로 둘 — 2026-10-28 `saa-t1-5`), A-08(Multi-AZ 배포 유형 한정 — 2026-10-28·11-06), A-11(AOF·노드 기반 Memcached — 2026-10-28), A-14(VPN 터널 「고가용성까지」 — 2026-11-07 SAA P3 §4-6). 전부 같은 방향으로 판정했다.
- 본문을 고치면 `lastVerified`와 「정정」 메모, 새 URL의 참고자료 항목을 함께 손봐야 한다(각 항목에 「출처 추가」로 표시).

## 측정 방법

- 인용 URL은 전부 `curl -sL -w "%{http_code} %{num_redirects} %{url_effective}"`로 재서 `200 r=0`인 것만 썼다. 대조군: 있는 가이드의 없는 슬러그 `lambda/latest/dg/zz-bogus.html` → `200 r=1`(인덱스), 없는 가이드 접두사 → `404 r=0`.
- 본문은 태그를 벗긴 텍스트에 정규식을 걸어 읽었고(문자 수와 양성 일치를 함께 확인), Firehose·PrivateLink·Lambda 변경은 AWS 문서 검색 도구로 한 번 더 확인했다.
- 죽은 슬러그(쓰지 않음): `AmazonElastiCache/latest/dg/RedisAOF.html`·`FaultTolerance.html`, `firehose/latest/dev/buffering-hints.html`·`create-configure.html` — 전부 `200 r=1`.

---

## 채택

### A-01 `saa-t3-2.md:138` — 채택
- 지적: AZ 간 연결을 「리전 간 네트워크」로 적었다.
- 현재 문장: `> AZ를 넘어 연결하려면 이 내부 경로 대신 리전 간 네트워크를 거쳐야 해 지연시간이 크게 늘어나므로, AWS는 동일 AZ 내 연결만 허용해 일관된 저지연 성능을 유지합니다.`
- 공식 근거: 문서 안의 근거로 판정(단순 오기). AZ는 리전 안의 단위이므로 AZ를 넘는 경로는 같은 리전 안의 AZ 간 경로다. 이 문단의 이유 설명 자체는 레포의 해설이고 공식 인용이 아니다.
- 교체 문장: `> AZ를 넘어 연결하려면 이 내부 경로 대신 AZ 간 네트워크를 거쳐야 해 지연시간이 늘어나므로, AWS는 동일 AZ 내 연결만 허용해 일관된 저지연 성능을 유지합니다.`
- 같은 주장의 다른 자리: 0건(대본 `saa-t3-2 seg018`이 같은 문장을 발화한다).

### A-02 `saa-t3-2.md:250`·`:255`·`:462`·`:484`·`:527` — 채택
- 지적: `:264`가 「"중지·종료"만 외우면 틀립니다」라고 적는데 같은 문서 다섯 자리가 중지·종료(·하드웨어 장애)만 적는다.
- 공식 근거: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-store-lifetime.html — "does not persist if the instance is stopped, hibernated, or terminated", 표에 "The instance type is changed — The data does not persist", "The underlying disk fails". `:264`·`:266~276` 표가 옳다.
- 현재 문장과 교체 문장:
  - `:250` 현재: `| **휘발성** | 인스턴스 중지·종료·하드웨어 장애 시 데이터 소실 |`
    교체: `| **휘발성** | 인스턴스 중지·최대 절전·종료·인스턴스 유형 변경, 기반 디스크 장애 시 데이터 소실 |`
  - `:255` 현재: `> 인스턴스 재부팅(reboot)으로는 데이터가 유지됩니다. 중지(stop) 또는 종료(terminate)하면 소실됩니다.`
    교체: `> 인스턴스 재부팅(reboot)으로는 데이터가 유지됩니다. 중지(stop)·최대 절전(hibernate)·종료(terminate)하거나 인스턴스 유형을 바꾸면 소실됩니다.`
  - `:462` 현재: `- **인스턴스 스토어 vs EBS**: 인스턴스 스토어는 인스턴스 중지·종료 시 데이터 소실(임시), EBS는 인스턴스와 독립적으로 데이터 유지(영속).`
    교체: `- **인스턴스 스토어 vs EBS**: 인스턴스 스토어는 인스턴스 중지·최대 절전·종료·유형 변경 시 데이터 소실(임시), EBS는 인스턴스와 독립적으로 데이터 유지(영속).`
  - `:484` 현재: `5. **"인스턴스 스토어는 재부팅해도 데이터가 사라진다."** → 인스턴스 **재부팅**으로는 데이터가 유지됩니다. 데이터가 소실되는 시점은 인스턴스 **중지(stop)·종료(terminate)** 또는 하드웨어 장애입니다.`
    교체: `5. **"인스턴스 스토어는 재부팅해도 데이터가 사라진다."** → 인스턴스 **재부팅**으로는 데이터가 유지됩니다. 데이터가 소실되는 시점은 인스턴스 **중지(stop)·최대 절전(hibernate)·종료(terminate)·인스턴스 유형 변경** 또는 기반 디스크 장애입니다.`
  - `:527`(자가 점검, 검수자가 들지 않은 자리) 현재 문장 안의 `반면 인스턴스 스토어는 인스턴스 중지·종료 또는 하드웨어 장애 시 데이터가 소실되는 임시 스토리지입니다.` → `반면 인스턴스 스토어는 인스턴스 중지·최대 절전·종료·유형 변경 또는 기반 디스크 장애 시 데이터가 소실되는 임시 스토리지입니다.`
- 같은 주장의 다른 자리: `saa-t3-2-q6`의 출처 제목 「재부팅 보존, 중지·종료 소실 (공식)」(제목 요약이라 거짓은 아니다 — 문항 수정은 선택). `:257`·`:258` 원리 블록은 「중지하면 소실」의 이유를 설명하는 자리라 대상이 아니다.

### A-03 `saa-t3-3.md:184` — 채택
- 지적(`saa-t3-3 seg030` 항목 본문): 문서는 파티션 배치 그룹의 인스턴스 수를 「제한 없음」으로 적고 발화는 「계정 한도에 따른다」고 한다.
- 현재 문장: `| **최대 인스턴스 수** | 제한 없음(용량 의존) | AZ당 최대 7파티션, 인스턴스 수 제한 없음 | AZ당 최대 **7개** | 용량·지원 하드웨어 의존 |`
- 공식 근거: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html — "limited only by the limits of your account". 발화 쪽이 공식에 가깝다(이 항목의 R2는 문서를 고치면 사라진다).
- 교체 문장: `| **최대 인스턴스 수** | 제한 없음(용량 의존) | AZ당 최대 7파티션, 인스턴스 수는 계정 한도까지 | AZ당 최대 **7개** | 용량·지원 하드웨어 의존 |`
- 같은 주장의 다른 자리: `saa-t3-3-q12` `wrongExplanations["0"]`(「AZ당 최대 7파티션, 인스턴스 수 제한 없음은 파티션 배치 그룹의 특성입니다」).

### A-04 `saa-t3-4.md:121`·`:310` — 채택
- 지적: 비교표 두 곳은 Batch 실행 시간을 「무제한」으로 적는데 `:493`·`:509`는 Fargate 리소스 14일 한도를 적는다.
- 공식 근거: https://docs.aws.amazon.com/batch/latest/userguide/job_timeouts.html — "Jobs that run on Fargate resources can't expect to run for more than 14 days". `:493`·`:509`가 옳다.
- 현재 문장과 교체 문장:
  - `:121` 현재: `| **AWS Batch** | 작업 단위 상태 | 무제한 | 자동 Compute Env | 낮음 | 대규모 배치, 완료 후 종료 |`
    교체: `| **AWS Batch** | 작업 단위 상태 | 고정 상한 없음(Fargate 리소스 작업은 14일) | 자동 Compute Env | 낮음 | 대규모 배치, 완료 후 종료 |`
  - `:310` 현재: `| 실행 시간 제한 | 15분 | **무제한** |`
    교체: `| 실행 시간 제한 | 15분 | **고정 상한 없음**(Fargate 리소스 작업은 14일 한도) |` (Lambda 칸의 「15분」은 A-06의 대상이다)
- 같은 주장의 다른 자리: 0건(`:117`~`:119`·`:122`의 「무제한」은 EC2·ECS 행이라 대상이 아니다). 대본 `saa-t3-4 seg016`·`seg047`이 「무제한」을 발화한다.

### A-05 `saa-t3-4.md:479` — 채택
- 지적: 「상한(기본 15분)」의 「기본」이 타임아웃 기본값으로 읽힌다.
- 현재 문장: `   (원리: §4 본문 — Lambda 함수 타임아웃에는 상한(기본 15분)이 있어, 이를 초과하는 작업은 강제 종료된다.)`
- 공식 근거: https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html — "The default value for this setting is 3 seconds". 기본값은 3초이고 15분은 기본값이 아니다.
- 교체 문장: `   (원리: §4 본문 — Lambda 함수 타임아웃에는 상한이 있어(기본값은 3초), 이를 초과하는 작업은 강제 종료된다.)`
  - 상한 수치를 일부러 적지 않았다. A-06의 결론과 무관하게 참인 문장이다.
- 같은 주장의 다른 자리: 0건(`기본 15분` 전수 1건).

### A-06 `saa-t3-4.md:478` 외 SAA 전역 — 채택(범위 확장 · 별 배치와 사용자 판단 필요)
- 지적: 검수자 지적이 아니다. A-05를 확인하다 찾았다. 문서는 Lambda 타임아웃 상한을 「15분(900초)」으로 적는데 공식이 2026-11에 30분으로 올렸다.
- 현재 문장(`:478`): `1. **"Lambda로 15분 이상 작업을 처리한다."** → Lambda 함수 타임아웃의 상한은 15분(900초)입니다(Lambda Managed Instances의 비동기·이벤트 소스 매핑 호출만 최대 90분). 초과 시 강제 종료됩니다. 장시간 배치 작업은 AWS Batch, 장기 실행 컨테이너는 ECS/Fargate를 사용합니다.`
- 공식 근거:
  - https://docs.aws.amazon.com/lambda/latest/dg/configuration-timeout.html — "up to a maximum value of 1,800 seconds (30 minutes)"
  - https://docs.aws.amazon.com/lambda/latest/api/API_CreateFunction.html — "the maximum allowed value is 1,800 seconds"
  - https://docs.aws.amazon.com/lambda/latest/dg/gettingstarted-limits.html — "Function timeout 1,800 seconds (30 minutes)"
  - https://aws.amazon.com/about-aws/whats-new/2026/11/aws-lambda-30-minute-ondemand-event-functions/ — "from 15 minutes to 30 minutes"
  - ⚠️ 공식 내부 어긋남: https://aws.amazon.com/lambda/faqs/ 는 아직 "the per-invocation timeout remains 15 minutes"다. 개발자 안내서·API 참조·발표문이 더 구체적이고 최신이라 그쪽을 정본으로 본다. Managed Instances 비동기·ESM 90분은 그대로다.
- 교체 문장(`:478` 제안): `1. **"Lambda로 30분을 넘는 작업을 처리한다."** → Lambda 함수 타임아웃의 상한은 30분(1,800초)입니다(2026-11에 15분에서 상향. Lambda Managed Instances의 비동기·이벤트 소스 매핑 호출만 최대 90분). 초과 시 강제 종료됩니다. 장시간 배치 작업은 AWS Batch, 장기 실행 컨테이너는 ECS/Fargate를 사용합니다.`
  - 이 한 줄만 고치면 문서가 자기모순이 된다. 「15분」을 갈림길로 쓰는 시나리오·문항이 많아 **전역 배치로 한 번에** 다뤄야 하고, 시험 대비 문서에서 옛 수치를 어떻게 병기할지는 사용자 판단이다. 이 보고는 사실과 범위만 적는다.
- 같은 주장의 다른 자리(`15분|900초` 일치 60건 — **Lambda와 무관한 「15분」이 섞인 상한값**이라 배치 때 한 건씩 읽어야 한다): `saa-t2-1.md` 3 · `saa-t2-2.md` 15 · `saa-t2-5.md` 3 · `saa-t3-4.md` 13(`:310`·`:478`·`:493`·`:509` 포함) · `saa-t3-9.md` 1 · 문항 `saa-t2-2-q3` 4 · `saa-t2-2-q14` 2 · `saa-t3-4-q1` 1 · `saa-t3-4-q2` 6 · `saa-t3-4-q4` 3 · `saa-t3-4-q8` 6 · `saa-t3-4-q13` 1 · `saa-t4-2-q9` 2. 다른 자격증(CLF·SOA·DEA·MLA·AIF·SCS·AIP)과 `CLAUDE.md`의 「Lambda 상한은 900초」 기록(2026-10-28)도 같은 사실 위에 있다 — 이 판정 범위 밖이라 세지 않았다.

### A-07 `saa-t3-5.md:436` — 채택
- 지적: 암호화 전환을 스냅샷 절차로만 설명한다. `saa-t1-5`는 Blue/Green 경로를 함께 적도록 정정됐다.
- 현재 문장: `5. **"운영 중 비암호화 RDS DB를 클릭 한 번으로 암호화할 수 있다."** → 불가. 스냅샷 생성 → 암호화 복사 → 복원의 절차가 필요합니다. 암호화는 생성 시에 설정하는 것이 권장됩니다.`
- 공식 근거: https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_TargetResourceConfiguration.html — "The blue resource is unencrypted and you want to encrypt the green resource." 이전 판정: 2026-10-28 `saa-t1-5.md:157`·`:312`와 `saa-t1-5-q14`가 같은 정정을 받았다(뒤집지 않는다).
- 교체 문장: `5. **"운영 중 비암호화 RDS DB를 클릭 한 번으로 암호화할 수 있다."** → 불가. 그 자리에서(in-place) 전환할 수 없고, 대표 경로는 스냅샷 생성 → 암호화 복사 → 복원입니다(Blue/Green 배포에서 green 리소스에 `TargetKmsKeyId`를 지정하는 경로도 있습니다). 암호화는 생성 시에 설정하는 것이 권장됩니다.`
- 같은 주장의 다른 자리: `saa-t1-5.md:302`(표 「스냅샷 생성 → 암호화 복사 → 복원 (직접 활성화 불가)」 — 경로 하나만 적는다), `saa-t1-5.md:311`(「절차를 거쳐야 합니다」 — 바로 아래 `:312` 원리가 두 경로를 적는다). 문항은 0건(`saa-t1-5-q14`는 이미 「대표 경로」로 적는다). 출처 추가: `saa-t3-5.md` 참고자료에 위 URL.

### A-08 `saa-t3-5.md:116`·`:176` — 채택
- 지적: 「동기 복제」에 배포 유형 한정이 없다. `:186`만 DB 클러스터 배포를 「반동기」로 적는다.
- 공식 근거: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.MultiAZSingleStandby.html — "maintains a synchronous standby replica in a different Availability Zone"; https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/multi-az-db-clusters-concepts.html — "Multi-AZ DB cluster deployments use semisynchronous replication". 이전 판정: 2026-10-28·11-06이 「Multi-AZ라고만 쓰면 DB 클러스터 배포에서 거짓」으로 한정을 넣었다.
- 현재 문장과 교체 문장:
  - `:116` 현재: `- 다른 AZ에 **동기 복제(synchronous)** 스탠바이 인스턴스를 유지합니다.`
    교체: `- Multi-AZ DB 인스턴스 배포는 다른 AZ에 **동기 복제(synchronous)** 스탠바이 인스턴스를 유지합니다(DB 클러스터 배포는 반동기 복제).`
  - `:176` 현재: `| **복제 방식** | 동기(synchronous) | 비동기(asynchronous) |`
    교체: `| **복제 방식** | DB 인스턴스 배포는 동기(synchronous), DB 클러스터 배포는 반동기 | 비동기(asynchronous) |`
- 같은 주장의 다른 자리: `saa-t2-4-q4` `wrongExplanations["0"]`(「RDS Multi-AZ는 비동기 복제가 아닌 동기 복제를 사용합니다」 — 한정 없음. 같은 문항의 해설·다른 근거는 한정이 있다), `saa-t2-5-q11` 보기(「RDS Multi-AZ는 동기 복제(AZ 장애 대응)…」 — 해설은 한정이 있다), `saa-t3-5-q2` `wrongExplanations["2"]`(「동기 복제를 스탠바이에 적용하는 것은 Multi-AZ의 방식」). `saa-t2-4.md`·`saa-t2-5.md` 본문은 이미 「DB 인스턴스 배포」로 한정돼 있다.

### A-09 `saa-t3-6.md:389`·`:423` — 채택
- 지적: `:204`가 「last-writer-wins 한 줄만 외우면 틀립니다」라고 적는데 두 자리가 모드 한정 없이 남았다.
- 공식 근거: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/V2globaltables_HowItWorks.html — "the global table defaults to multi-Region eventual consistency", MRSC는 "A write operation fails with a ReplicatedWriteConflictException". `:193`·`:204`가 옳다.
- 현재 문장과 교체 문장:
  - `:389` 현재: `   (원리: §7 — Active-Active는 타임스탬프 기반 최후 작성자 우선으로 충돌을 처리하며 모든 리전에서 쓰기를 허용한다.)`
    교체: `   (원리: §7 — Active-Active는 모든 리전에서 쓰기를 허용하며, 기본 모드(MREC)에서는 타임스탬프 기반 최후 작성자 우선으로 충돌을 처리한다. MRSC에서는 충돌한 쓰기가 예외로 실패한다.)`
  - `:423` 현재 끝 문장: `충돌은 최후 작성자 우선(last-writer-wins)으로 자동 해결됩니다.`
    교체: `충돌은 기본 모드(MREC)에서 최후 작성자 우선(last-writer-wins)으로 자동 해결됩니다.` (줄의 앞부분은 그대로 둔다)
- 같은 주장의 다른 자리: 0건(`saa-t3-6-q9` 해설은 이미 「기본 모드인 … MREC에서」로 한정한다. `:206~209` 원리 블록은 제목이 「기본 충돌 해결 방식」이라 대상이 아니다).

### A-10 `saa-t3-6.md:168` — 채택
- 지적: 원리 블록이 온디맨드를 「스파이크 구간에서도 스로틀 없이」로 적는데 `:164`는 온디맨드만으로 부족하다고 적는다.
- 현재 문장: `> 온디맨드 모드는 사전 처리량 설정 없이 AWS가 실시간 트래픽에 따라 용량을 조정하므로, 예측하기 어려운 스파이크 구간에서도 스로틀 없이 요청을 처리할 수 있습니다.`
- 공식 근거: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/on-demand-capacity-mode.html — "instantly accommodates up to double the previous peak traffic", "throttling can occur if you exceed double your previous peak within 30 minutes". `:164`가 옳다.
- 교체 문장: `> 온디맨드 모드는 사전 처리량 설정 없이 AWS가 실시간 트래픽에 따라 용량을 조정하므로, 이전 최고치의 2배까지는 스파이크도 스로틀 없이 즉시 받습니다. 다만 30분 안에 이전 최고치의 2배를 넘으면 스로틀이 생길 수 있어, 그런 급증이 예상되면 사전 웜업이 필요합니다.`
- 같은 주장의 다른 자리: 문항 0건으로 본다(`saa-t3-6-q6` 지문의 「스파이크가 발생해도 스로틀 없이 처리해야 한다」는 요구 조건 서술이다 — 정답 판정에 영향이 있는지는 검수자 확인 사항으로 남긴다).

### A-11 `saa-t3-6.md:286`·`:287` — 채택
- 지적: §12 표가 「AOF 로그 지원」, Memcached 「없음」을 한정 없이 적는다. 함정 6(`:397`)만 「노드 기반」으로 한정한다.
- 공식 근거:
  - https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/ParameterGroups.Engine.html — Redis OSS 2.8.22 절 "The following parameters are no longer supported. appendonly appendfsync"
  - https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/backups.html — "supported only for caches running on Valkey, Redis OSS or Serverless Memcached"
  - https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/WhatIs.deployment.html — 서버리스 열 "Data is replicated asynchronously across multiple Availability Zones"
  - 이전 판정: `CLAUDE.md` 2026-10-28 기록과 `saa-t3-6-q13` 해설이 같은 사실을 이미 적는다.
- 현재 문장과 교체 문장:
  - `:286` 현재: `| **영속성** | 스냅샷(RDB) + AOF 로그 **지원** | **없음** (메모리 한정) |`
    교체: `| **영속성** | 스냅샷(RDB) 백업 **지원**(AOF는 Redis OSS 2.8.22 이후 미지원) | 노드 기반은 **없음** (메모리 한정) — 서버리스 Memcached는 스냅샷 백업 지원 |`
  - `:287` 현재: `| **복제·HA** | 복제 + **Multi-AZ 자동 Failover** 지원 | **없음** |`
    교체: `| **복제·HA** | 복제 + **Multi-AZ 자동 Failover** 지원 | 노드 기반은 **없음** — 서버리스 캐시는 여러 AZ에 복제 |`
- 같은 주장의 다른 자리: 0건(`AOF` 전수 2건 중 나머지 하나가 `saa-t3-6-q13`의 올바른 서술이다). 대본 `saa-t3-6 seg047`·`seg049`·`seg057`이 표를 그대로 읽는다. 출처 추가: `backups.html`·`ParameterGroups.Engine.html`이 참고자료에 없으면 넣는다.

### A-12 `saa-t3-7.md:43`·`:252` — 채택
- 지적: 한 문서 안에서 `GLB`와 `GWLB`가 갈린다.
- 공식 근거: https://aws.amazon.com/elasticloadbalancing/gateway-load-balancer/ — 페이지 제목 "Gateway Load Balancer (GWLB)"; https://docs.aws.amazon.com/vpc/latest/privatelink/gateway-load-balancer-endpoints.html — "Endpoint services that use NLBs and GWLBs". 두 페이지 모두 `GLB` 0건(대조군 `GWLB` 1건씩). 같은 레포 `saa-t2-3.md:528`도 `GWLB`를 쓴다.
- 현재 문장과 교체 문장:
  - `:43` 현재: `- [ ] **로드 밸런서 성능 관점** — ALB·NLB·GLB의 성능 특성과 선택 기준을 설명할 수 있다`
    교체: `- [ ] **로드 밸런서 성능 관점** — ALB·NLB·GWLB의 성능 특성과 선택 기준을 설명할 수 있다`
  - `:252` 현재: `| **GLB** (Gateway LB) | **L3** | 모든 IP 패킷·모든 포트 | 트래픽을 어플라이언스(방화벽·IDS 등)로 투명하게 전달 | 네트워크 어플라이언스 통합 |`
    교체: `| **GWLB** (Gateway LB) | **L3** | 모든 IP 패킷·모든 포트 | 트래픽을 어플라이언스(방화벽·IDS 등)로 투명하게 전달 | 네트워크 어플라이언스 통합 |`
- 같은 주장의 다른 자리: `saa-t3-7-q13`(보기 1곳 + `wrongExplanations["1"]` 1곳), `saa-t3-7-q15`(보기 1곳 + `wrongExplanations["1"]` 1곳) — 문항 4개소. ⚠️ 그중 `saa-t3-7-q13` `wrongExplanations["1"]`은 「GLB는 L3/L4에서」로 적는다 — 같은 문서 표와 `saa-t2-3.md:528`의 2026-10-19 정정은 **L3**이다(계층 표기도 함께 볼 자리).

### A-13 `saa-t3-8.md:132` — 채택
- 지적: 「원격 VPC의 보안 그룹을 TGW에서 참조할 수 없습니다」가 낡았다.
- 현재 문장: `- ⚠️ **원격 VPC의 보안 그룹을 TGW에서 참조할 수 없습니다.** VPC 피어링은 보안 그룹 참조를 지원하므로, "SG 참조로 소스를 제한하라"는 요구가 있으면 TGW 허브-스포크만으로는 충족되지 않습니다 — 이것이 피어링을 완전히 대체하지 못하는 대표적 이유입니다.`
- 공식 근거: https://docs.aws.amazon.com/vpc/latest/tgw/tgw-vpc-attachments.html — 「Security group referencing」 절 "will only work if it has been enabled for both a transit gateway and its VPC attachments", "You can cross-reference security groups in inbound rules only." 문서가 근거로 든 백서(참고자료 14번)가 옛 서술이다 — 더 구체적인 제품 문서를 정본으로 본다.
- 교체 문장: `- ⚠️ **TGW 경유 보안 그룹 참조는 따로 켜야 동작합니다.** 보안 그룹 참조 지원을 **트랜짓 게이트웨이와 VPC 어태치먼트 양쪽에서 활성화**해야 같은 TGW에 붙은 VPC 사이에서 상대 보안 그룹을 참조할 수 있고, **인바운드 규칙에서만** 가능합니다(아웃바운드 규칙은 미지원). "SG 참조로 소스를 제한하라"는 요구에 TGW 허브-스포크를 쓰려면 이 설정이 전제입니다.`
- 같은 주장의 다른 자리: `saa-t3-8.md:508`(참고자료 14번 제목 「⚠️ TGW에서 원격 VPC 보안 그룹 참조 불가」), `saa-t3-8.md:515`(보강 메모 「⚠️ 원격 VPC 보안 그룹 참조 불가」). 문항 0건. 출처 추가: 위 URL.

### A-14 `saa-t3-8.md:194` — 채택
- 지적: 「두 터널을 동시에 활성화하면 부하 분산도 가능합니다」가 같은 문서 `:177`의 ECMP 조건과 어긋난다.
- 현재 문장: `> 이 중복 구조가 VPN 연결의 기본 가용성을 높이는 메커니즘이며, 두 터널을 동시에 활성화하면 부하 분산도 가능합니다.`
- 공식 근거: https://docs.aws.amazon.com/vpn/latest/s2svpn/VPNTunnels.html — "It is important to configure both tunnels for redundancy." 부하 분산 서술은 이 페이지에 없다(`load` 일치 2건이 둘 다 다른 낱말). 이전 판정: 2026-11-07 SAA P3 §4-6이 「공식 VPN 문구는 고가용성까지, 터널을 묶는 ECMP는 TGW 종단 + 동적 라우팅」으로 문항을 고쳤고 `:175~177`을 정본으로 봤다(뒤집지 않는다).
- 교체 문장: `> 이 중복 구조가 VPN 연결의 기본 가용성을 높이는 메커니즘입니다. 여러 터널에 트래픽을 나눠 싣는 부하 분산은 Transit Gateway에 종단하고 동적 라우팅(BGP)을 쓰는 ECMP 구성에서만 가능합니다.`
- 같은 주장의 다른 자리: 0건(`부하 분산도|터널…부하 분산` 전수 1건). 대본 `saa-t3-8 seg032`가 그대로 발화한다.

### A-15 `saa-t3-8.md:251`·`:431` — 채택
- 지적: MACsec을 추가한 뒤에도 원리 문장 둘이 IPsec만 말한다(`:212`·`:430`은 두 선택지를 적는다).
- 공식 근거: https://docs.aws.amazon.com/directconnect/latest/UserGuide/encryption-in-transit.html — "You can use Direct Connect connections that support MACsec to encrypt your data". 같은 페이지가 Site-to-Site VPN 결합도 적는다. `:212`·`:430`이 옳다.
- 현재 문장과 교체 문장:
  - `:251` 현재: `> 암호화가 필요한 규정 환경에서는 DX 위에 IPsec VPN 터널을 얹는 패턴으로 물리 회선의 낮은 지연과 전송 암호화를 함께 확보할 수 있습니다.`
    교체: `> 암호화가 필요한 규정 환경에서는 DX 위에 IPsec VPN 터널을 얹는 패턴으로 물리 회선의 낮은 지연과 전송 암호화를 함께 확보하거나, MACsec을 지원하는 연결이라면 MACsec으로 암호화할 수 있습니다.`
  - `:431` 현재: `   (원리: §4 — 물리적 격리는 전송 계층 암호화가 아니며, 암호화가 필요하면 DX 위에 IPsec 터널을 얹어야 한다.)`
    교체: `   (원리: §4 — 물리적 격리는 전송 계층 암호화가 아니며, 암호화가 필요하면 DX 위에 IPsec 터널을 얹거나 MACsec을 써야 한다.)`
- 같은 주장의 다른 자리: 0건(`saa-t3-8-q7`은 「얹는 패턴으로 … 확보할 수 있습니다」라 배타 서술이 아니다).

### A-16 `saa-t3-9.md:310` — 채택
- 지적: 배치 대 스트리밍 표의 스트리밍 열이 지연 「밀리초~초」에 대표 서비스로 Firehose를 든다. 같은 문서 `:472`는 Firehose를 「수 초~수 분」으로 적는다.
- 현재 문장: `| 지연 | 분~시간 | 밀리초~초 |`
- 공식 근거: https://docs.aws.amazon.com/firehose/latest/dev/create-configure-backup.html — 버퍼 간격을 0초로 두면 "will not buffer data and will deliver data within a few seconds". 최소가 「몇 초」이고 버퍼 간격 범위는 0~900초다. `:472`가 옳다.
- 교체 문장: `| 지연 | 분~시간 | 밀리초~초 (Firehose는 버퍼 설정에 따라 수 초~수 분) |`
  - `:311`(대표 서비스 「Kinesis Data Streams, Firehose」)은 그대로 둔다. Firehose는 공식이 스트리밍 전송 서비스로 소개한다.
- 같은 주장의 다른 자리: 0건. 대본 `saa-t3-9 seg050`이 이 표를 읽는다. 검수자가 함께 적은 EFO 한도(`:105`·`:174`)는 서로 일치해 지적이 아니다.

### A-17 `saa-t4-2.md:50` — 채택
- 지적: 「도메인 4(20%)는 시험 비중 3위」.
- 현재 문장: `- 도메인 4(20%)는 시험 비중 3위입니다. "요구 조건을 충족하는 가장 저렴한 선택" 유형의 문제가 이 도메인에 집중됩니다.`
- 공식 근거: 문서 안의 근거로 판정(단순 오기). 레포 `flutter_app/assets/exam_guides/SAA-C03.json`의 `weightPct`가 30·26·24·20이고(공식 가이드와 바이트 대조된 파일이다) `saa-t4-1.md:59`·`saa-t4-5.md:36`이 「네 번째」·「4위」로 적는다.
- 교체 문장: `- 도메인 4(20%)는 시험 비중 4위입니다. "요구 조건을 충족하는 가장 저렴한 선택" 유형의 문제가 이 도메인에 집중됩니다.`
- 같은 주장의 다른 자리: 0건. 대본 `saa-t4-2 seg006`이 「3위」를 발화한다.

### A-18 `saa-t4-2.md:331`·`:333` — 채택
- 지적: 원리 블록이 Lambda와 Fargate를 묶어 「대기 상태에서 과금도 발생하지 않는다」고 적는다. 같은 문서 `:299`·`:310`과 어긋난다.
- 공식 근거: https://aws.amazon.com/fargate/pricing/ — "from the time you start to download your container image until the Amazon ECS Task or Amazon EKS Pod terminates". Fargate는 태스크가 떠 있는 동안 요청과 무관하게 과금된다. `:299`·`:310`이 옳다.
- 현재 문장과 교체 문장:
  - `:331` 현재: `> 🧠 원리: 왜 서버리스(Lambda·Fargate) 과금은 유휴 시 비용이 발생하지 않을까요?`
    교체: `> 🧠 원리: 왜 Lambda는 유휴 시 비용이 발생하지 않고, Fargate는 태스크가 떠 있는 동안 과금될까요?`
  - `:333` 현재: `> Lambda와 Fargate는 요청이 들어올 때만 컨테이너·실행 환경을 프로비저닝하고 완료되면 자원을 반환하므로, 대기 상태에서 점유하는 컴퓨팅이 없어 과금도 발생하지 않습니다.`
    교체: `> Lambda는 요청이 들어올 때만 실행 환경에서 코드를 돌리고 그 실행 시간만큼만 과금하므로, 요청이 없는 대기 상태에서는 과금이 발생하지 않습니다(프로비저닝 동시성은 예외). Fargate는 서버 관리는 없지만 컨테이너 이미지를 내려받기 시작한 때부터 태스크가 종료될 때까지 요청 유무와 무관하게 과금됩니다.`
- 같은 주장의 다른 자리: 0건(`saa-t4-2-q13` 해설은 Lambda만 말한다. `:309`도 Lambda 행이다). 대본 `saa-t4-2 seg060`이 이 원리를 읽는다.

### A-19 `saa-t4-1.md:252` — 채택
- 지적: 「Amazon Compute Optimizer」.
- 현재 문장: `| 과잉 프로비전된 볼륨 | Amazon Compute Optimizer가 rightsizing 권장 |`
- 공식 근거: https://docs.aws.amazon.com/compute-optimizer/latest/ug/what-is-compute-optimizer.html — 제목 "What is AWS Compute Optimizer?" (`AWS Compute Optimizer` 11건 · `Amazon Compute Optimizer` 0건).
- 교체 문장: `| 과잉 프로비전된 볼륨 | AWS Compute Optimizer가 rightsizing 권장 |`
- 같은 주장의 다른 자리: 0건(SAA md·문항 전수). 대본 `saa-t4-1 seg033`이 「Amazon Compute Optimizer」로 발화한다(승인된 라이브 음성).

### A-20 `saa-t4-1.md:73` — 채택
- 지적: 「크고 클수록」 오타.
- 현재 문장: `| **IOPS** | Input/Output Operations Per Second | 디스크가 초당 처리할 수 있는 읽기·쓰기 횟수 — 크고 클수록 빠르지만 비용도 증가 |`
- 공식 근거: 문서 안의 근거로 판정(단순 오기).
- 교체 문장: `| **IOPS** | Input/Output Operations Per Second | 디스크가 초당 처리할 수 있는 읽기·쓰기 횟수 — 클수록 빠르지만 비용도 증가 |`
- 같은 주장의 다른 자리: 0건. 발화 `seg009`는 이미 「클수록」이다.

### A-21 `saa-t4-4.md:148` — 채택
- 지적: `:142`는 「다수의 AWS 서비스」로 바꿨는데 원리 블록은 「200개 이상」을 유지한다.
- 현재 문장: `> Interface Endpoint(PrivateLink)는 VPC 내부에 ENI를 생성해 서비스마다 프라이빗 IP를 부여하는 방식으로, 200개 이상의 다양한 서비스에 적용 가능합니다. 대신 AZ별 시간 요금과 데이터 처리 요금이 발생합니다.`
- 공식 근거: https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html — 서비스 표만 싣고 개수를 적지 않는다. 이 페이지와 `aws.amazon.com/privatelink/`·`/privatelink/faqs/` 세 곳에서 `N services`·`over N` 꼴이 0건이다(추출 유효성: 세 페이지 본문 8,327~30,126자, FAQ에서 "five different types of VPC endpoints"는 읽힌다). 공식이 적지 않는 수치이므로 `:142`의 표현에 맞춘다.
- 교체 문장: `> Interface Endpoint(PrivateLink)는 VPC 내부에 ENI를 생성해 서비스마다 프라이빗 IP를 부여하는 방식으로, 다수의 AWS 서비스에 적용 가능합니다. 대신 AZ별 시간 요금과 데이터 처리 요금이 발생합니다.`
- 같은 주장의 다른 자리: `saa-t4-4-q6` 해설(「Interface Endpoint(PrivateLink, 200개 이상 서비스 지원)」). 대본 `saa-t4-4 seg029`·`seg031`이 「200개 이상」을 발화한다 — 문서를 고치면 R1이 된다.

### A-22 `saa-t3-2.md:575` — 채택(메모 한 구절)
- 지적: d3 `saa-t3-2` 요청 5번 — 정정 메모가 OpenZFS 「최대 2,000,000 IOPS」를 공식 미확인 `[의심]`으로 열어 둔다.
- 현재 문장(줄 안의 구절): `FSx for OpenZFS **디스크 IOPS 수치**(C-16 — 이 문서 §7의 "최대 2,000,000 IOPS"는 공식 미확인으로 열려 있는 별건 `[의심]` 항목이라 이번 배치에서 건드리지 않았습니다)`
- 공식 근거: https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/what-is-fsx.html — "delivers up to 2 million IOPS with latencies of hundreds of microseconds". 본문 `:383`·`:421`의 수치는 옳다(R-02). 낡은 것은 「미확인」이라는 메모다.
- 교체 문장(구절): `FSx for OpenZFS **디스크 IOPS 수치**(C-16 — 이 문서 §7의 "최대 2,000,000 IOPS"는 2026-11-22에 공식 소개 페이지로 확인했습니다. 디스크에서 읽는 데이터의 상한은 따로 400,000 IOPS입니다)`
  - 뒤 문장의 근거: 같은 페이지 "Up to 400,000 IOPS and 10 GBps of read/write throughput … for data accessed from disk".
- 같은 주장의 다른 자리: 0건.

---

## 기각

### R-01 `saa-t3-2.md:419`·`:520` — 기각
- 지적: `:366`이 성능을 스토리지 클래스별로 나누고 「수백만 IOPS」를 뺐는데 두 자리에 남아 있다.
- 현재 문장(`:419`): `| HPC·ML 초고성능 파일시스템 | **FSx for Lustre** | 수 TBps·수백만 IOPS·S3 통합 |`
- 공식 근거: https://docs.aws.amazon.com/fsx/latest/LustreGuide/what-is.html — "up to multiple TBps of throughput and up to millions of IOPS". 서비스 수준 요약으로 공식이 그대로 적는 문구다. `:366`은 스토리지 클래스별 세부이고 요약과 모순되지 않는다. `:575`가 쓰지 않았다고 적는 것은 「IOPS 한도」(구체 수치)이지 이 요약이 아니다.
- 같은 주장의 다른 자리: 해당 없음. 대본 `seg059`·`seg060`은 고칠 필요가 없다.

### R-02 `saa-t3-2.md:383`·`:421` — 기각
- 지적: FSx for OpenZFS 「최대 2,000,000 IOPS」가 공식 미확인일 수 있다.
- 현재 문장(`:383`): `- 최대 2,000,000 IOPS, 수백 마이크로초 지연시간`
- 공식 근거: https://docs.aws.amazon.com/fsx/latest/OpenZFSGuide/what-is-fsx.html — "delivers up to 2 million IOPS with latencies of hundreds of microseconds". 본문은 옳다. 메모만 A-22로 고친다. (참고: 제품 페이지 `aws.amazon.com/fsx/openzfs/`는 "over 1 million IOPs"로 적어 공식 안에서 표현이 갈린다 — 사용자 안내서를 정본으로 봤다.)
- 같은 주장의 다른 자리: 해당 없음. 대본 `seg056`·`seg059`는 고칠 필요가 없다.

### R-03 `saa-t3-3.md:276`·`:188` — 기각
- 지적: 「분산 배치 그룹 + 전용 인스턴스 → 불가」와 표의 「전용 호스트 | 불가」(네 전략 모두)를 공식으로 재확인해 달라.
- 현재 문장(`:276`): `- **분산 배치 그룹 + 전용 인스턴스** → 불가. 분산 배치 그룹은 전용 인스턴스를 지원하지 않습니다.`
- 공식 근거: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-strategies.html — "Spread placement groups are not supported for Dedicated Instances.", "A partition placement group with Dedicated Instances can have a maximum of two partitions."; https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html — "You can't launch Dedicated Hosts in placement groups." 세 서술(`:188`·`:225`·`:276`) 모두 공식과 일치하고 서로 대상이 달라 모순이 아니다.
- 같은 주장의 다른 자리: 해당 없음.

### R-04 `saa-t3-5.md`·`saa-t4-3.md` 전반 — 기각(명칭 「Aurora serverless」)
- 지적: 문서가 「Aurora Serverless v2」를 「Aurora serverless」로 통일했다. 의도된 개명 반영인지 확인해 달라(d3 `saa-t3-5` 요청 1번, d4 요청 3번).
- 현재 문장(예, `saa-t4-3.md:188`): `**Aurora serverless**`
- 공식 근거: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.html — 페이지 제목이 "Using Aurora serverless"이고 본문에 `Aurora serverless` 59건 · `Aurora Serverless v2` 0건(URL 슬러그에만 `v2`가 남았다). 문서의 표기가 현행 공식 표기다.
- 같은 주장의 다른 자리: 해당 없음. 대본의 「서버리스 브이투」·「Aurora Serverless v2」를 「오로라 서버리스」로 맞출지는 발화 쪽 결정이다(같은 기능이라 사실 충돌은 아니다).

### R-05 `saa-t3-4.md:232` — 기각
- 지적: 표는 「콜드 스타트 제거」, 발화는 「줄이거나 제거」다. 통일 여부.
- 현재 문장: `| **Provisioned Concurrency** | 미리 초기화된 실행 환경 유지 → **콜드 스타트 제거** |`
- 공식 근거: https://docs.aws.amazon.com/lambda/latest/dg/provisioned-concurrency.html — "These execution environments are ready to respond immediately", "useful for reducing cold start latencies". 미리 초기화된 환경이 받는 요청에는 초기화 지연이 없으므로 「제거」는 그 범위 안에서 틀린 서술이 아니다. 공식의 낱말은 「reducing」이고 프로비저닝한 수를 넘는 요청은 여전히 콜드 스타트를 겪는다는 한정은 붙일 수 있으나, 오류로 보지 않았다.
- 같은 주장의 다른 자리: 고치지 않으므로 대상이 없다. 참고로 같은 표현이 `saa-t2-2.md:127`·`:362`·`:397`, `saa-t3-4.md:467`·`:490`·`:523`, 문항 `saa-t2-2-q2`·`q15`·`saa-t3-4-q6`·`q14`에 있다 — 한정을 넣기로 한다면 이 전수가 범위다.

### R-06 `saa-t3-8.md:445` — 기각
- 지적: A-14와 함께 제기됐다 — 「고가용성을 위해 두 터널을 동시에 사용할 수 있습니다」.
- 현재 문장: `7. **"VPN은 터널이 하나다."** Site-to-Site VPN 연결에는 **항상 터널 2개**가 포함됩니다. 고가용성을 위해 두 터널을 동시에 사용할 수 있습니다.`
- 공식 근거: https://docs.aws.amazon.com/vpn/latest/s2svpn/VPNTunnels.html — "Traffic from the on-premises network to AWS uses both tunnels." 이 줄은 부하 분산을 말하지 않고 고가용성까지만 말해 공식과 일치한다(2026-11-07 판정이 인용한 FAQ 문구와도 같다).
- 같은 주장의 다른 자리: 해당 없음. 대본 `seg068`은 이 줄에 한해 고칠 필요가 없다.

---

## 판정하지 않은 요청(36건)

- d3 공통 1~4번(재합성 범위·코드 블록 등급·영문 잔존·R3 채택 범위) 4건.
- d3 문서별: `saa-t3-1` 1~4번(4번은 「문서 쪽 의심 없음」 보고) · `saa-t3-2` 4번(발화 보강) · `saa-t3-3` 1·2·3·5번 · `saa-t3-4` 4·5·6번 · `saa-t3-5` 2·3번 · `saa-t3-6` 4·5·6번 · `saa-t3-7` 2·3·4번 · `saa-t3-8` 4·5·6번 · `saa-t3-9` 1·2·3·4·6번 — 28건.
- d4 1번(재생성 대 패치)·2번(코드 블록)·5번(`saa-t4-1` 재합성 사유)·6번(공식 미확인 고지) 4건.
- d3 `saa-t3-8` 6번과 d4 6번의 CloudFront·DX 단가는 발화의 확장 추론에 대한 것이라 문서 지적으로 세지 않았다.

## 채택 건이 대본에 주는 영향(참고)

문서를 고치면 지금 N 또는 「문서와 일치」로 둔 발화가 R1이 되는 자리다. 판정은 컨트롤러 몫이고 여기서는 자리만 모았다.

| 채택 | 대본 세그먼트 |
|---|---|
| A-01 | `saa-t3-2` seg018 |
| A-02 | `saa-t3-2` seg034·seg035·seg062·seg068 |
| A-04 | `saa-t3-4` seg016·seg047 |
| A-07 | `saa-t3-5` seg060 |
| A-08 | `saa-t3-5` seg019·seg025 |
| A-09 | `saa-t3-6` seg061·seg036 |
| A-10 | `saa-t3-6` seg030 |
| A-11 | `saa-t3-6` seg047·seg049·seg057 |
| A-12 | `saa-t3-7` seg050 |
| A-14 | `saa-t3-8` seg032 |
| A-15 | `saa-t3-8` seg039 |
| A-16 | `saa-t3-9` seg050 |
| A-17 | `saa-t4-2` seg006 |
| A-18 | `saa-t4-2` seg060 |
| A-19 | `saa-t4-1` seg033 |
| A-21 | `saa-t4-4` seg029·seg031 |
| A-06 | Lambda 「15분」을 발화하는 전 세그먼트(세지 않았다) |
