# DEA-C01 gaps — 컨트롤러 확인분 (가이드·레포 JSON·전역)

> 컨트롤러(리서치 세션)가 직접 확인한 항목. 확인일 2026-10-17, 2026-10-19 재확인.

- G-0-01 [수정제안] 레포 `flutter_app/assets/exam_guides/DEA-C01.json`의 Skill 8건이 현행 공식 KO 가이드와 문구가 다르다(모두 서비스명 약칭 ↔ 전체명 차이, 의미 동일): 1.1.1(AWS DMS), 1.2.1(Amazon EKS·ECS), 1.3.4(SNS·SQS + "알림을 전송"), 1.4.6(AWS SAM), 1.4.8(AWS CDK), 2.4.3(AWS SCT·AWS DMS), 4.1.2(IAM), 4.3.2(AWS KMS). JSON은 전체명으로 풀어 쓴 문구, 공식 페이지는 약칭. 비교표는 `00-overview.md` §7.
  - 확인 시도: 공식 KO 가이드 도메인 1·2·4 페이지(`.md` 원문)를 프로그램으로 파싱해 JSON과 문자열 대조(2026-10-17 최초, 2026-10-19 재대조 동일). https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain1.html · …-domain2.html · …-domain4.html
  - 후속: 수정은 필수가 아니다(기능 영향 없음, 풀네임이 학습용으로 유용). 공식 문구에 맞출지 취합 세션이 결정. 맞춘다면 위 8건만 바꾸면 된다.

- G-0-02 [수정제안] JSON에 가이드 버전·게시일 필드가 없다. 현행 공식 가이드는 v1.1(2025-12-12)이며 v1.0과 구조가 다르다(Knowledge+Skill 통합). `guideVersion: "1.1"`, `guidePublished: "2025-12-12"` 같은 필드를 추가하면 다음 개정 때 비교가 쉽다. JSON의 `knowledge: []`는 v1.1 구조와 부합하므로 수정 불필요.
  - 확인 시도: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html (EN), …/ko_kr/…/dea-01-revisions.html (KO) — 개정 이력 표.
  - 후속: 취합 세션 결정. 추가 시 `00-overview.md` §2·§5의 개정 요약을 근거로 삼는다.

- G-0-03 [개명·종료] 가이드 "In-Scope AWS Services" 목록(EN·KO 동일)이 구명칭을 쓴다: "Amazon Kinesis Data Firehose"(공식 개명: Amazon Data Firehose, 2024-02-12), "Amazon MemoryDB for Redis"(Skill 2.1.3 문구는 "Amazon MemoryDB"; MemoryDB는 2024-10-08부터 Valkey 지원). 또 Skill 3.2.1은 "Amazon QuickSight"인데 같은 목록은 "Amazon Quick"이다 — 공식 문서: "Amazon Quick evolved from Amazon QuickSight", QuickSight는 Quick 안의 "Amazon Quick Sight" 기능으로 계속.
  - 근거: https://aws.amazon.com/blogs/compute/amazon-kinesis-firehose-data-transformation-with-aws-lambda/ ("Amazon Kinesis Data Firehose has been renamed to Amazon Data Firehose.") · https://docs.aws.amazon.com/cli/latest/reference/firehose/index.html · https://docs.aws.amazon.com/quick/latest/userguide/what-is.html · https://docs.aws.amazon.com/memorydb/latest/devguide/doc-history.html · 목록: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html
  - 확인 시도: 목록 페이지(EN·KO)·개명 공지 직접 읽음. 시험 문항이 어느 명칭을 쓰는지는 확인 불가(인증 페이지: 시험은 일부 서비스를 약칭으로 출제, 약칭 목록은 시험 Help 버튼에서만 제공).
  - 후속: 학습문서에는 "현행 명칭(구명칭/시험 표기)" 병기를 권장.

- G-0-04 [불확실] Skill 2.4.3 예시에 "AWS SCT"가 남아 있는데 v1.1 개정 이력은 AWS Schema Conversion Tool(AWS SCT)을 **범위 내 서비스 목록에서 제거**했다고 적는다(같은 개정에서 Cloud9·CodeCommit도 제거). 어느 쪽이 시험 출제 기준인지 공식 문서로 확정할 수 없다.
  - 근거: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-revisions.html (Services removed from the in-scope list) · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html (Skill 2.4.3)
  - 확인 시도: 두 페이지 직접 읽음(EN·KO 동일).
  - 후속: 문항에서 SCT를 정답으로 단정하지 말고 "SCT 또는 DMS Schema Conversion" 형태로 서술하거나 DMS Schema Conversion을 중심에 둘 것(2-4 노트 gaps 참조).

- G-0-05 [불확실] 가이드 PDF 렌더(EN `https://docs.aws.amazon.com/pdfs/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.pdf`, KO `https://docs.aws.amazon.com/ko_kr/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.pdf`)의 HTTP Last-Modified가 각각 2026-10-16, 2026-10-15이다. 개정 이력(v1.1 = 2025-12-12)과 별개로 문서 빌드가 갱신된 것인지, 내용 변경인지 확인하지 못했다. 이 환경에는 PDF 텍스트 추출 도구가 없어 PDF 본문은 읽지 못했다.
  - 확인 시도: curl HEAD로 응답 헤더 확인. HTML 가이드(정본) 도메인 1~4 페이지는 2026-10-19에 라이브 대조해 노트 17개의 Skill 표와 문자 단위로 동일함을 확인.
  - 후속: HTML이 정본이므로 영향 없음으로 판단(추정). 필요하면 사람이 PDF 첫 쪽의 버전 표기를 확인.

- G-0-06 [확인필요] 구 시험 가이드 PDF가 아직 서빙된다: `https://d1.awsstatic.com/training-and-certification/docs-data-engineer-associate/AWS-Certified-Data-Engineer-Associate_Exam-Guide.pdf` (HTTP 200, Last-Modified 2025-02-14, 약 163 KB, PDF 메타 19쪽·생성일 2023-10-31). v1.1(2025-12-12)보다 이전 파일이라 v1.1 신규 Skill을 담을 수 없다. 인증 페이지는 이 PDF가 아닌 HTML 가이드를 링크한다. 본문은 파싱하지 못했다(도구 없음) → v1.0이라는 것은 날짜로 추정한 것이다.
  - 확인 시도: curl HEAD, WebFetch(PDF 본문 추출 실패, 메타데이터만).
  - 후속: DEA 학습문서의 출처로 이 PDF를 쓰지 말 것(레포 CLF 매핑 문서는 PDF를 출처로 썼으나 DEA는 HTML 가이드가 정본).

- G-0-07 [불확실] 범위 내 서비스 목록의 Storage 항목에 "Amazon S3 Tables"가 두 번 나온다(EN·KO 동일: S3, S3 Tables, S3 Glacier, S3 Tables). 오탈자로 추정되나 확인 불가.
  - 근거: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html
  - 후속: 영향 없음(S3 Tables는 Skill 2.1.7 관련 신규 범위 내 서비스).

- G-0-08 [확인필요] 시험 화면 Help 버튼의 "약칭↔전체명 목록"은 공개 페이지에 없다. 시험이 어떤 약칭을 쓰는지 공식 근거로 확인할 수 없다(영문판에 먼저 적용, 타 언어는 순차 적용).
  - 근거: https://aws.amazon.com/certification/certified-data-engineer-associate/ ("This exam uses short names of some AWS services.")
  - 후속: 한국어판에서 어느 표기가 쓰이는지는 응시자 경험으로만 확인 가능(사람 작업).

- G-0-09 [정보] Task 단위 출제 비중은 가이드에 없다(도메인 비중만: 34/26/22/18). 도메인 비중을 Task 수로 나눈 값은 공식 값이 아니다.
  - 근거: https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01.html

- G-0-10 [확인필요] 범위 내 서비스 목록에 없지만 Skill이 직접 요구하는 서비스가 있다: Skill 4.1.7(SageMaker Unified Studio 도메인·프로젝트), 2.2.6/2.4.4/4.5.6(Amazon SageMaker Catalog) — 목록에는 "Amazon SageMaker AI"만 있다. 반대로 목록에 없는 AWS Clean Rooms·IAM Identity Center·Amazon Kinesis Video Streams·Amazon Timestream 등은 Skill에 직접 등장하지 않는다(단 다른 서비스 문서에서 언급될 수 있음). 우선순위는 Skill 문구 > 서비스 목록으로 두었다.
  - 근거: 가이드 domain2·domain4 페이지와 in-scope 페이지(위 URL).
  - 후속: 취합 세션이 문서 범위를 정할 때 Skill 문구 기준을 유지.
  - 근거 URL 보강(컨트롤러, 2026-10-19 열람·인용문 원문 확인): https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain2.html · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/data-engineer-associate-01-domain4.html · https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html

- G-0-11 [해결됨] 2-1 노트 gaps G-2.1-22("In-Scope AWS Services 페이지 URL 미확보")는 컨트롤러가 해결했다. URL = https://docs.aws.amazon.com/aws-certification/latest/data-engineer-associate-01/dea-01-in-scope-services.html (KO: …/ko_kr/…). 확인 결과 DocumentDB·Neptune·Keyspaces·MemoryDB for Redis 모두 Database 카테고리에 포함, Redshift도 Database 카테고리에 있다. 전체 목록은 `00-overview.md` §6.
