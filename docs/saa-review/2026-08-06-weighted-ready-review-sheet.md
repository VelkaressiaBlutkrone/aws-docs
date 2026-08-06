# SAA-C03 weighted-ready 검수 체크시트 — 2026-08-06

> 대상 batch: `saa-t1-1`, `saa-t1-4`, `saa-t2-5`.
> 전체 문항 원문과 선택지는 `flutter_app/build/saa_review/index.html`을 정본 뷰어로 본다.
> 이 문서는 사람이 놓치기 쉬운 advisory 문항과 Task 단위 pass 체크를 위한 작업표다.

## 공통 체크

- [ ] `node tool/saa_prescreen.mjs build` 결과 구조 플래그 0건 확인
- [ ] `node tool/saa_review.mjs build` 결과 HTML 뷰어 열람
- [ ] 각 문항에 `review-rubric.md` C1~C6 적용
- [ ] 사람 검수자가 통과 판정한 Task만 `node tool/saa_review.mjs flip <taskId>` 실행
- [ ] flip 후 자동 실행되는 `saa_questions_test` / `content_index_test` 통과 확인

## `saa-t1-1` IAM — 자격증명·권한·페더레이션

Pass-first 후보: `q1`, `q2`, `q3`, `q4`, `q5`, `q6`, `q7`, `q8`, `q9`, `q10`, `q11`, `q12`, `q14`, `q15`.

집중 확인:

- [ ] `saa-t1-1-q13`
  - Stem: IAM 역할을 수임할 때 STS가 발급하는 자격증명의 성격
  - 현재 정답: 임시 자격증명으로 기본 최대 1시간, 설정에 따라 최대 12시간 후 만료되며 재수임이 필요하다
  - 사람 확인: 정답과 12시간 상한은 타당. 오답근거의 "STS 글로벌/리전 종속 아님" 표현이 현행 STS 리전 엔드포인트 설명과 충돌하지 않는지 확인한다.
  - 출처: `https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html`

Task 판정:

- [ ] 전 15문항 pass
- [ ] 필요 수정 반영 후 재검수
- [ ] 사람 flip 대상 확정

## `saa-t1-4` 애플리케이션 보안 — Shield·WAF·Cognito·Secrets Manager

Pass-first 후보: `q1`, `q2`, `q3`, `q5`, `q6`, `q7`, `q8`, `q9`, `q11`, `q13`, `q14`, `q15`.

집중 확인:

- [ ] `saa-t1-4-q4`
  - Stem: AWS WAF 웹 ACL을 직접 연결할 수 없는 리소스
  - 현재 정답: Amazon RDS 데이터베이스 인스턴스
  - 사람 확인: 정답은 타당. 해설의 WAF 지원 리소스 목록에 Amplify가 빠진 최신성 문제를 수정할지 판단한다.
  - 출처: `https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html`

- [ ] `saa-t1-4-q10`
  - Stem: RDS 비밀번호를 코드에서 제거하고 90일마다 자동 교체
  - 현재 정답: AWS Secrets Manager
  - 사람 확인: 정답은 타당. RDS managed rotation은 Lambda 미사용 경로가 있으므로 "Lambda 기반 자동 교체" 단정을 완화할지 확인한다.
  - 출처: `https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html`

- [ ] `saa-t1-4-q12`
  - Stem: CloudFront + ALB + EC2 구성에서 WAF 연결 위치
  - 현재 정답: CloudFront 배포에 WAF 연결
  - 사람 확인: 정답은 타당. q4와 동일하게 WAF 지원 리소스 목록 최신성을 확인한다.
  - 출처:
    - `https://docs.aws.amazon.com/waf/latest/developerguide/what-is-aws-waf.html`
    - `https://docs.aws.amazon.com/waf/latest/developerguide/ddos-overview.html`

Task 판정:

- [ ] 전 15문항 pass
- [ ] 필요 수정 반영 후 재검수
- [ ] 사람 flip 대상 확정

## `saa-t2-5` DR 전략 — RTO·RPO·Pilot Light·Warm Standby·Active-Active

Pass-first 후보: `q1`, `q2`, `q3`, `q4`, `q5`, `q6`, `q7`, `q9`, `q10`, `q11`, `q12`, `q13`, `q14`, `q15`.

집중 확인:

- [ ] `saa-t2-5-q8`
  - Stem: Aurora 데이터베이스 교차 리전 복제로 RPO 최소화
  - 현재 정답: Aurora Global Database
  - 사람 확인: 정답과 "1초 미만 복제 지연, 1분 내 승격"은 백서 문구와 일치. 오답해설의 "같은 리전 내 Read Replica도 동기 복제가 아니다" 표현이 Aurora reader와 혼동되지 않게 수정할지 확인한다.
  - 출처: `https://docs.aws.amazon.com/whitepapers/latest/disaster-recovery-workloads-on-aws/disaster-recovery-options-in-the-cloud.html`

Task 판정:

- [ ] 전 15문항 pass
- [ ] 필요 수정 반영 후 재검수
- [ ] 사람 flip 대상 확정

## Flip 순서

```powershell
cd flutter_app
node tool/saa_review.mjs flip saa-t1-1
node tool/saa_review.mjs flip saa-t1-4
node tool/saa_review.mjs flip saa-t2-5
```

세 Task가 모두 flip되면 SAA-C03 readiness는 D1 30/19, D2 30/17, D3 45/16, D4 30/13으로 공개 조건을 충족한다.
