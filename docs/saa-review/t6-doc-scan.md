# T6 — SAA-C03 학습문서 정확성 스캔 (종합)

> 잠금 플랜 [2026-06-20-saa-rereview-plan](../superpowers/plans/2026-06-20-saa-rereview-plan.md) §5 T6.
> 검수일 2026-06-20. 대조: docs.aws.amazon.com 공식(2025~2026 갱신 반영).
> **스캔(플래그)만** — 실제 수정·flip은 사람(검수 브랜치 `saa-review*`). 플래그는 advisory, 사람 최종 판정 대상.
> 방법: D1=컨트롤러 직독 / D2·D3·D4=read-only 서브에이전트. 상세는 도메인별 파일 참조.

## 종합 결과 (24문서)
| 도메인 | 문서 | 플래그 | 하드오류 | 상세 |
|---|---|---|---|---|
| D1 보안 | 5 | 0 | 0 | (본 문서 아래) |
| D2 복원력 | 5 | 5 | 2 | (본 문서 아래) |
| D3 고성능 | 9 | 6 | 0 | [t6-d3.md](t6-d3.md) |
| D4 비용 | 5 | 3 | 1 | [t6-d4.md](t6-d4.md) |

문서 품질 전반 매우 높음(2026-06-12 고도화 검수본). 하드 오류는 소수이며 대부분 **최근 AWS 한도 상향에 따른 구식 수치**.

## ★ 우선 수정 (고confidence — 사람 승인 후 `saa-review` 브랜치에서)
1. **Aurora 최대 스토리지 128TiB → 256TiB** (conf 9) — `saa-t3-5`(§7 스토리지·§8 비교표) **및** `saa-t4-3`(§3). 2025-07 AWS 상향(이전 128의 2배). 두 문서 모두 128을 주 수치로 둠 → 256 주 수치로 교체.
2. **Direct Connect 표 마크다운 깨짐** (conf 6, 렌더 결함) — `saa-t4-4` §6 line 186 행이 `-`로 시작 → `|`로 교정(내용 $0.02 vs $0.09는 정확).
3. **Deep Archive 복원 옵션 누락** (conf 7) — `saa-t3-1` "12시간 이내"만 → "Standard 12h·Bulk 48h" 병기.
4. **SQS FIFO TPS 파티션 단위 미명시** (conf 8) — `saa-t2-1` "300/3,000 TPS"를 큐 절대상한처럼 서술 → "파티션당, 고처리량 모드는 파티션 추가로 확장".
5. **Step Functions Express "100,000 실행/초" 출처불명** (conf 7) — `saa-t2-1` → 실제 StartExecution 한도(리전별, 최대 ~6,000/s)로 교체 또는 수치 제거.
6. **DynamoDB TTL "48시간 이내"** (conf 6) — `saa-t3-6` → "보통 며칠 이내(best-effort)" + 삭제 전 조회 노출 가능 한 줄.

## 모호/판단 필요 (사람이 결정 — 사실은 대체로 정확, 시험정렬·완화 차원)
- `saa-t2-3` NLB 교차영역 부하분산 "기본 비활성" 단정 → 생성방식별 상이(핵심은 NLB 활성 시 AZ간 전송요금, ALB 무료).
- `saa-t2-4` RDS Multi-AZ 페일오버 "1~2분" → 공식 "60~120초, 조건 따라 상이".
- `saa-t2-5` Aurora Global "장애 시 1분 내 승격" → 공식 명시 수치 없음("낮은 RTO").
- `saa-t4-3` §4 DynamoDB 용량모드 전환 24h 규칙 방향성 불명확(온디맨드 전환 24h/1회 vs 복귀 유연).
- `saa-t3-1` 버킷정책 20KB(정확·참고), `saa-t3-5` Magnetic 비권장(정확) — 변경 불필요.

---

## D1 (보안) — 핵심 오류 없음 (컨트롤러 직독)
saa-t1-1(IAM)·t1-2(다중계정)·t1-3(VPC)·t1-4(앱보안)·t1-5(데이터보안) 5개 정독. 글로벌 IAM·정책평가(명시Deny우선)·STS 1~12h·SCP 관리계정 예외/멤버루트 적용·OU 5단계·서비스연결역할 SCP예외·Control Tower 가드레일 3종·NAT GW 100Gbps·SG/NACL·Gateway vs Interface Endpoint·피어링 비전이·WAF 보호대상·Shield L3/4 vs L7+SRT·Cognito User/Identity Pool 분리·Secrets Manager 65,536B·KMS 봉투암호화/키정책/FIPS 140-3 L3·CloudFront ACM us-east-1·Macie vs Inspector·Backup Vault Lock(Compliance/쿨다운) — **전부 공식과 일치**.

## D2 (복원력) — 플래그 5 (하드오류 2, 모호 3) [서브에이전트]
- [오류 conf8] `saa-t2-1` FIFO "300/3,000 TPS"를 큐 절대상한처럼 서술 → 실제 **파티션당**, 고처리량 모드 파티션 추가 확장. (출처: SQS high-throughput-fifo)
- [오류 conf7] `saa-t2-1` Step Functions Express "100,000 실행/초" 출처불명 → StartExecution 리전별 한도(최대 ~6,000/s). (출처: SF service-quotas)
- [모호 conf7] `saa-t2-3` NLB 교차영역 기본값 단정.
- [모호 conf6] `saa-t2-4` RDS Multi-AZ 페일오버 "1~2분" → 공식 60~120초.
- [모호 conf7] `saa-t2-5` Aurora "1분 내 승격" → 공식 명시 수치 없음.
- (정확 확인: t2-2 전체, DR 4전략·Pilot Light/Warm Standby·Aurora 복제 1초미만·Lambda 재시도 2회 등)
