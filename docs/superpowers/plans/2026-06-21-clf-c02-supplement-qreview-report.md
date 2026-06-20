# CLF-C02 보강 문항 검수 보고서

대상: `D:\workspace\clf-c02-supplement-qdrafts_for_review.json`  
기준일: 2026-06-21 KST  
범위: 신규 q16+ 초안 21문항, 관련 보강 본문, 기존 q1-q15 중복 여부, AWS 공식 출처 대조

## 결론

전체 사실관계는 대체로 정확합니다. 다만 바로 `verified:true`로 전환하기에는 기존 15문항과 정답 포인트가 겹치는 초안 5개가 있습니다.

- 구조 검사: 통과. 21문항, id 중복 없음, 보기 4개, 정답 인덱스, 오답 해설 키, `sources`, `section` 형식 정상.
- 실제 문항 파일 상태: q16+는 모두 `verified:false` 유지.
- 초안 추출 파일과 실제 q16+ 문항 파일: `stem/options/correct/explanation/section` 일치.
- 공식 출처 사실성: 핵심 정답 논리는 모두 공식 문서와 부합.
- 승인 권고: 16문항 승인 가능, 5문항 보류/수정 권고.

## 승인 권고 목록

아래 문항은 사실성, 본문 범위, 오답 매력도, CLF 난이도 기준에서 `verified:true` 전환 가능하다고 봅니다.

| 문항 | 정답 | 판정 | 메모 |
|---|---|---|---|
| `clf-t3-1-q17` | AWS CDK | 승인 가능 | 프로그래밍 언어로 IaC 정의, CloudFormation 합성/배포 논리 명확 |
| `clf-t3-1-q18` | AWS Systems Manager | 승인 가능 | SSH 없이 접속, Run Command, Patch, Parameter Store 단서 적절 |
| `clf-t3-1-q19` | CodePipeline + CodeBuild + CodeDeploy | 승인 가능 | 릴리스 흐름 조율, 빌드, 배포 역할 배치 정확 |
| `clf-t3-1-q20` | AWS CodeCommit | 승인 가능 | 관리형 Git 저장소와 Build/Deploy 경계 명확 |
| `clf-t2-3-q16` | Cognito User Pool + Identity Pool | 승인 가능 | 인증 토큰과 임시 AWS 자격증명 분리 단서 좋음 |
| `clf-t2-3-q17` | AD Connector | 승인 가능 | 기존 온프레미스 AD 프록시 요구와 Managed AD/Simple AD 구분 명확 |
| `clf-t2-3-q18` | Cognito User Pool | 승인 가능 | 고객 앱 로그인과 workforce Identity Center 대비가 정확 |
| `clf-t3-7-q17` | Textract | 승인 가능 | 문서 양식/표 추출 단서가 Rekognition/Kendra와 구분됨 |
| `clf-t3-7-q19` | Personalize | 승인 가능 | 추천 관리형 서비스 논리 정확, Forecast는 레거시 오답으로만 사용 |
| `clf-t2-2-q16` | ACM | 승인 가능 | TLS 인증서 관리와 KMS/CloudHSM 경계 명확 |
| `clf-t2-2-q17` | CloudHSM | 승인 가능 | 전용 HSM, PKCS#11, 고객 직접 제어 단서 정확 |
| `clf-t2-2-q18` | us-east-1 | 승인 가능, 난이도 주의 | 공식 사실 정확. CLF에서 다소 세부이지만 CloudFront ACM 빈출이라 수용 가능 |
| `clf-t3-3-q16` | ECR | 승인 가능 | 이미지 저장소와 ECS 실행 역할 구분 명확 |
| `clf-t3-8-q16` | Amazon MQ | 승인 가능 | RabbitMQ/ActiveMQ 호환 이전과 SQS/SNS/EventBridge 구분 명확 |
| `clf-t3-5-q16` | VPC Flow Logs | 승인 가능 | 트래픽 로깅/관측 단서 정확 |
| `clf-t3-5-q17` | AWS PrivateLink | 승인 가능, 표현 주의 | q15의 VPC Endpoint와 가까우므로 "특정 서비스/SaaS 사설 연결 기술" 단서를 유지해야 함 |

## 보류/수정 권고

아래 5개는 사실은 맞지만 기존 15문항과 소재 또는 정답 포인트가 충돌합니다. 중복 회피 기준 때문에 `verified:true` 전환 전 수정하거나 대체하는 편이 좋습니다.

| 문항 | 기존 충돌 | 판정 | 권고 |
|---|---|---|---|
| `clf-t3-1-q16` Elastic Beanstalk | `clf-t3-1-q8`도 Elastic Beanstalk, "코드 업로드 후 용량/로드밸런싱/오토스케일링/상태 모니터링" | 보류 | q16을 제거하거나 Beanstalk가 아닌 새 배포 도구 주제로 교체 |
| `clf-t3-7-q16` Rekognition | `clf-t3-7-q8`도 이미지/영상 객체/장면/부적절 콘텐츠 분석 | 보류 | 중복. 다른 응용 AI 서비스나 더 좁은 비교형 문항으로 교체 |
| `clf-t3-7-q18` Comprehend | `clf-t3-7-q10`도 텍스트 감정/엔터티/NLP | 보류 | "Textract 후 추출된 텍스트를 Comprehend로 분석" 같은 파이프라인 구분형으로 강하게 재작성하거나 교체 |
| `clf-t3-3-q17` AWS Batch | `clf-t3-3-q9`도 수천 개 배치 작업, 자동 프로비저닝, 큐/스케줄링 | 보류 | q17 제거 또는 Batch가 아닌 새 보강 주제로 교체 |
| `clf-t3-8-q17` WorkSpaces Applications | `clf-t3-8-q8`이 같은 서비스의 옛 이름인 Amazon AppStream 2.0 | 보류 | q8을 WorkSpaces Applications(이전 AppStream 2.0)로 갱신하고 q17을 제거하거나, q17을 "명칭 변경 확인" 전용으로 둘지 정책 결정 필요 |

## 경고 지점 검수

### `clf-t2-2-q18` CloudFront용 ACM 인증서 리전

판정: 통과.

- 공식 ACM 문서는 ACM 인증서가 리전 리소스이며, CloudFront에 사용할 인증서는 US East (N. Virginia) 리전에 요청/가져와야 한다고 설명합니다.
- 보강 본문에도 근거가 있습니다: `flutter_app/assets/content/clf/t2-2.md`의 `certificates-hsm` 섹션, 요약, 착각 포인트에 `us-east-1`이 반복 반영되어 있습니다.
- 난이도는 CLF 상한에 가까운 세부 사실이지만, CloudFront와 ACM 조합에서 자주 묻는 운영 지식이라 승인 가능으로 봅니다.

### `clf-t3-8-q17` WorkSpaces Applications 명칭

판정: 사실은 맞지만 source 보강 권장.

- AWS 공식 문서 제목은 현재 `Amazon WorkSpaces Applications`입니다.
- AWS 제품 페이지는 `Amazon WorkSpaces applications (formerly AppStream 2.0)`라고 명시하고, `https://aws.amazon.com/appstream2/`도 WorkSpaces Applications 페이지로 리다이렉트됩니다.
- 현재 JSON source는 docs URL만 있으므로, "구 AppStream 2.0" 문구를 정답 논리에 남길 경우 `https://aws.amazon.com/workspaces/applications/`를 추가 source로 넣는 것이 더 단단합니다.
- 기존 `clf-t3-8-q8`의 정답이 `Amazon AppStream 2.0`이라, q17을 승인하려면 q8과 용어 정책을 먼저 정리해야 합니다.

### `clf-t2-3-q18` IAM Identity Center URL 범위

판정: 통과.

- `flutter_app/assets/content/clf/t2-3.md` frontmatter `sources`에 Amazon Cognito, AWS Directory Service, IAM Identity Center URL이 모두 포함되어 있습니다.
- 본문 `app-directory-identity` 섹션도 Cognito는 고객/앱 사용자, IAM Identity Center는 workforce 사용자 접근 관리로 구분합니다.

## 공식 출처 대조 요약

| 주제 | 공식 출처 대조 | 판정 |
|---|---|---|
| Elastic Beanstalk | 소스 번들 업로드 후 EC2, 로드 밸런싱, 헬스 모니터링, 동적 확장 환경 구성 | 사실 OK, 중복 보류 |
| AWS CDK | 익숙한 언어로 인프라 정의, CloudFormation 템플릿으로 합성/배포 | OK |
| Systems Manager | AWS/온프레미스/멀티클라우드 노드 중앙 운영, SSH 없이 접속, 명령 실행, 패치, Parameter Store | OK |
| CodePipeline/Build/Deploy | 릴리스 단계 자동화, 빌드/테스트 산출물, EC2/온프레미스/Lambda/ECS 배포 자동화 | OK |
| CodeCommit | AWS 호스팅 관리형 소스 제어, 프라이빗 Git 저장소 | OK |
| Cognito | User Pool은 인증/JWT, Identity Pool은 임시 AWS credentials | OK |
| AD Connector | 기존 온프레미스 Microsoft AD에 인증 요청을 전달하는 프록시 | OK |
| Rekognition | 이미지/비디오 분석, 객체/텍스트/unsafe content/얼굴 | 사실 OK, 중복 보류 |
| Textract | 문서 텍스트, 양식, 표 추출 | OK |
| Comprehend | 텍스트 문서의 엔터티, 핵심 문구, 언어, 감정 등 NLP 인사이트 | 사실 OK, 중복 보류 |
| Personalize | 사용자 데이터 기반 추천, 세그먼트, 다음 행동 추천 | OK |
| Forecast | 신규 고객에게 제공되지 않음, 기존 고객은 사용 가능 | OK, 오답으로만 쓰는 방향 적절 |
| ACM | SSL/TLS X.509 인증서 생성, 저장, 갱신, 가져오기 관리 | OK |
| CloudHSM | 단일 테넌트 HSM, FIPS, 키/알고리즘 직접 제어, PKCS#11 등 호환 | OK |
| ECR | Docker/OCI 이미지 저장/관리, IAM 권한, 스캔, lifecycle policy | OK |
| AWS Batch | 대규모 배치 워크로드 자동 프로비저닝/스케줄/실행 | 사실 OK, 중복 보류 |
| Amazon MQ | ActiveMQ Classic/RabbitMQ용 관리형 메시지 브로커, 코드 재작성 부담 감소 | OK |
| WorkSpaces Applications | 애플리케이션 스트리밍, formerly AppStream 2.0 | 사실 OK, 중복/소스 보강 필요 |
| VPC Flow Logs | ENI IP 트래픽 캡처, CloudWatch Logs/S3/Data Firehose 게시 | OK |
| PrivateLink | IGW/NAT/public IP/DX/VPN 없이 VPC를 서비스/리소스에 사설 연결 | OK |

## 오답 매력도

대부분 같은 도메인의 그럴듯한 서비스로 잘 구성되어 있습니다.

- 좋은 편: `q18 Systems Manager vs CodePipeline`, `q19 Pipeline/Build/Deploy 역할 매핑`, `q16 Cognito User/Identity Pool`, `q17 AD Connector`, `q16 ECR vs ECS`, `q16 MQ vs SQS/SNS/EventBridge`, `q16 Flow Logs vs PrivateLink`.
- 다소 쉬운 편: 일부 문항은 Route 53, ACM, IoT Core처럼 도메인이 멀리 떨어진 오답이 섞여 있어 정답이 빨리 보입니다. CLF 입문 난이도에서는 허용 가능하지만, 검증 문항 밀도를 높이는 목적이라면 같은 도메인 distractor 비율을 조금 더 올릴 수 있습니다.
- 주의: `t3-5 q17`은 `VPC Endpoint`와 `PrivateLink`가 가까운 개념입니다. 기존 q15와 함께 노출될 때 학습자가 "둘 다 인터넷 없이 서비스 접근"으로 이해할 수 있으므로, q17에서는 SaaS/파트너/엔드포인트 서비스와 `PrivateLink` 기술 단서를 유지해야 합니다.

## 자동/로컬 검증 기록

- `D:\workspace\clf-c02-supplement-qdrafts_for_review.json` 직접 구조 검사: 통과.
- 실제 `flutter_app/assets/content/clf/*.questions.json` q16+와 초안 추출 파일 대조: 통과.
- 실제 q16+ `verified` 상태 확인: 모두 `false`.
- `flutter test test/clf_supplement_questions_test.dart`: 120초, 300초 두 번 모두 타임아웃. 종료 후 남은 Flutter/Dart 프로세스 없음. Dart 테스트 결과는 미확보입니다.

## 대조한 주요 공식 URL

- AWS Certificate Manager: https://docs.aws.amazon.com/acm/latest/userguide/acm-overview.html
- Amazon WorkSpaces Applications docs: https://docs.aws.amazon.com/appstream2/latest/developerguide/what-is-appstream.html
- Amazon WorkSpaces Applications product page: https://aws.amazon.com/workspaces/applications/
- Amazon Cognito: https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html
- AWS IAM Identity Center: https://docs.aws.amazon.com/singlesignon/latest/userguide/what-is.html
- AWS Directory Service: https://docs.aws.amazon.com/directoryservice/latest/admin-guide/what_is.html
- AWS Elastic Beanstalk: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/Welcome.html
- AWS Systems Manager: https://docs.aws.amazon.com/systems-manager/latest/userguide/what-is-systems-manager.html
- AWS CodePipeline: https://docs.aws.amazon.com/codepipeline/latest/userguide/welcome.html
- AWS CodeBuild: https://docs.aws.amazon.com/codebuild/latest/userguide/welcome.html
- AWS CodeDeploy: https://docs.aws.amazon.com/codedeploy/latest/userguide/welcome.html
- AWS CodeCommit: https://docs.aws.amazon.com/codecommit/latest/userguide/welcome.html
- Amazon Rekognition: https://docs.aws.amazon.com/rekognition/latest/dg/what-is.html
- Amazon Textract: https://docs.aws.amazon.com/textract/latest/dg/what-is.html
- Amazon Comprehend: https://docs.aws.amazon.com/comprehend/latest/dg/what-is.html
- Amazon Personalize: https://docs.aws.amazon.com/personalize/latest/dg/what-is-personalize.html
- Amazon Forecast: https://docs.aws.amazon.com/forecast/latest/dg/what-is-forecast.html
- AWS CloudHSM: https://docs.aws.amazon.com/cloudhsm/latest/userguide/introduction.html
- Amazon ECR: https://docs.aws.amazon.com/AmazonECR/latest/userguide/what-is-ecr.html
- AWS Batch: https://docs.aws.amazon.com/batch/latest/userguide/what-is-batch.html
- Amazon MQ: https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/welcome.html
- VPC Flow Logs: https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html
- AWS PrivateLink: https://docs.aws.amazon.com/vpc/latest/privatelink/what-is-privatelink.html
