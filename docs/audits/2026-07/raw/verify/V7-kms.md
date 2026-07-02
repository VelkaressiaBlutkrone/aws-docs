# 2단 반박 검증 — V7 KMS·암호화·ACM — 2026-07

검증자 결론: 6항목 모두 오탐 반박 실패 → 문서 오류 실재(CONFIRMED). 아래 근거는 모두 AWS 공식 문서 원문 인용으로 확정.

## 조회 출처 (URL 목록)
- https://docs.aws.amazon.com/kms/latest/developerguide/overview.html
- https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-overview.html
- https://docs.aws.amazon.com/kms/latest/developerguide/key-policy-default.html
- https://docs.aws.amazon.com/acm/latest/userguide/import-certificate.html
- https://docs.aws.amazon.com/acm/latest/userguide/import-certificate-prerequisites.html
- https://docs.aws.amazon.com/acm/latest/userguide/managed-renewal.html

## 판정

| ID | 판정 | 근거(3줄 이내) |
|---|---|---|
| DOC-SAA-010 + DOC-SOA-305 (KMS 접근 "둘 다 필수/교집합" 단정) | CONFIRMED | 공식: 키정책이 IAM 역할/사용자를 Principal로 **직접** 허용하면("Allow use of the key" 예시 ExampleKeyUserRole) 그 grant만으로 접근 성립 — 별도 IAM 정책 불요. IAM 정책 추가가 필요한 것은 `:root`(account principal) 형태일 때뿐("allows the account to use IAM policies to *delegate*"). 따라서 "항상 둘 다 Allow 교집합"이라는 무조건적 단정은 부정확. 발견자 지적 타당(같은 계정 직접 허용 시 키정책 단독 충분). |
| DOC-SAA-011 (saa-t1-5 "암호화된 상태로 KMS를 절대 벗어나지 않습니다") | CONFIRMED | 공식 원문: "They never leave AWS KMS **unencrypted**" / "They never leave the service **unencrypted**". 의미는 "평문(암호화 안 된 상태)으로는 안 나감"이지 "암호화된 상태로 안 나감"이 아님 — 문서가 방향을 정반대로 번역(키는 암호화된 형태로는 나갈 수 있음). 발견자 지적 정확. |
| DOC-SAA-012 (saa-t1-5 AWS 관리형 키를 "(AWS 소유)"로 표기) | CONFIRMED | AWS managed key와 AWS owned key는 별개 분류. 같은 문서 표(line 96-100)조차 "AWS 관리형 키"와 "AWS 소유 키"를 별도 행으로 구분함. 그런데 관리형 키 행의 키정책 열에 "불가 (AWS 소유)"라 적어 두 분류를 혼동시킴 — AWS 관리형 키는 사용자 계정 내 리소스(콘솔서 조회 가능)로 AWS 소유 키와 다름. 발견자 지적 타당. |
| DOC-SAA-013 (FIPS Level 3 → CloudHSM 결정 규칙, 동시에 KMS를 FIPS 140-3 L3 기재) | CONFIRMED | 공식 overview: KMS 키는 "**FIPS 140-3 Security Level 3** validated HSM"로 보호(CSRC 인증서 #4884 링크). KMS도 FIPS 140-3 L3이므로 "FIPS Level 3 감사" 키워드만으로 CloudHSM을 변별하는 결정 규칙(line 170)은 성립 안 함 — 문서 내부 표(line 163)도 KMS를 FIPS 140-3 L3으로 기재해 규칙과 모순. 발견자 지적 정확. |
| DOC-SOA-306 (soa-t4-3 가져온 인증서 갱신 불가 사유 = "개인 키가 ACM 외부에 있어서") | CONFIRMED | 공식 import 전제조건: "you must provide both the certificate and **its private key**" — import 시 개인 키를 ACM에 업로드함(전제 오류). 실사유는 "ACM does not provide managed renewal for imported certificates. To renew... obtain a new certificate from your certificate issuer" — ACM이 제3자 CA 인증서를 재발급/재검증할 수 없어서임. 발견자 지적 정확. |
| DOC-SOA-307 (soa-t4-3 "만료 전 자동 갱신(DNS/이메일 검증 유효 시)") | CONFIRMED | 공식 managed-renewal: "ACM will either renew your certificates **automatically (if you are using DNS validation)**, or it will **send you email notices** when expiration is approaching." 완전 무개입 자동 갱신은 DNS 검증 한정, 이메일 검증은 소유자가 갱신 시 대응 필요. DNS·이메일을 동등하게 자동 갱신으로 묶은 서술은 부정확. 발견자 지적 정확. |
