import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 은퇴한(리다이렉트하는) 공식 문서 URL이 콘텐츠에 남아 있지 않은지 보는 가드
/// (2026-10-29 SOA·DEA 출처 URL 전수 실측).
///
/// ## 왜 필요한가
///
/// 문항 구조 가드(`<cert>_questions_test`·`review.mjs`의 `questionFlags`)는
/// `sources`가 비어 있지 않고 `http(s)`로 시작하는지만 본다 — **URL이 실재하는지는
/// 어느 자동 가드도 보지 않는다.** 그래서 죽은 링크가 조용히 쌓였다:
/// SAA에서 `rds-reserved-instances.html`이 6문항의 깨진 링크였고(2026-10-28 발견),
/// MLA 도메인 3에서는 작성 URL 23건이 실제 오류였다.
///
/// 2026-10-29에 SOA 300 + DEA 256문항의 `sources` **고유 URL 561개를 전수 실측**해
/// 리다이렉트한 22개를 찾았다. 실측·분류·교체 근거는
/// `docs/saa-review/2026-10-29-soa-dea-source-url-audit.md`가 정본이다.
///
/// ## ⚠️ 측정 함정 — 상태 코드로는 안 잡힌다
///
/// `docs.aws.amazon.com`은 **없는 페이지에도 404를 주지 않고** 그 가이드의 인덱스로
/// 리다이렉트한다(대조군으로 확인: 일부러 틀린 슬러그도 `200`). 그래서 판정 신호는
/// 상태 코드가 아니라 **리다이렉트 발생 여부**다:
///
/// ```sh
/// curl -sS -o /dev/null -L --max-time 30 \
///   -w '%{http_code}|%{num_redirects}|%{url_effective}' "<url>"
/// ```
///
/// ## ⚠️ 전체 URL로 센다
///
/// 파일명만 보면 거짓 양성이 난다 — 교체 URL이 옛 URL의 부분 문자열인 경우가 있다
/// (`ebs/latest/userguide/ebs-optimized.html` → `AWSEC2/latest/UserGuide/ebs-optimized.html`,
/// CloudFormation `UserGuide/intrinsic-function-*` → `TemplateReference/intrinsic-function-*`).
///
/// ## 운영 — URL을 교체할 때 할 일
///
/// 실측에서 리다이렉트한 URL을 교체했다면 **옛 URL을 아래 목록에 한 줄 추가**한다.
/// 그러면 다음 문항·학습문서 작성에서 되살아나지 않는다. `.md`도 함께 본다 —
/// 문항 가드는 학습문서를 보지 않아서 2026-10-28에 `saa-t4-3.md`에 같은 깨진 링크가
/// 2곳 남았다.
void main() {
  /// 2026-10-29 실측에서 리다이렉트한 URL(=그 슬러그는 더 이상 정본이 아니다).
  const retiredUrls = <String>[
    // ── 인덱스로 리다이렉트 = 페이지 소멸 ───────────────────────────────
    'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Create_alarm_on_alarm.html',
    'https://docs.aws.amazon.com/ebs/latest/userguide/ebs-optimized.html',
    'https://docs.aws.amazon.com/autoscaling/ec2/userguide/consolidated-view-of-warm-up-settings.html',
    'https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/testing-disaster-recovery.html',
    'https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-service-event.html',
    'https://docs.aws.amazon.com/directconnect/latest/UserGuide/high_resiliency_selftest.html',
    'https://docs.aws.amazon.com/vpc/latest/userguide/vpc-troubleshooting.html',
    // ── 다른 페이지로 이름 변경 ─────────────────────────────────────────
    'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html',
    'https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-patch-group-tagging.html',
    'https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html',
    'https://docs.aws.amazon.com/autoscaling/ec2/userguide/as-add-elb-healthcheck.html',
    'https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-findinmap.html',
    'https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks.html',
    'https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference-importvalue.html',
    'https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-attribute-deletionpolicy.html',
    'https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-maintenance.html',
    'https://docs.aws.amazon.com/systems-manager/latest/userguide/execute-remote-commands.html',
    'https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-about-aws-runpatchbaseline.html',
    'https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html',
    'https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_access-advisor.html',
    'https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config-rules.html',
    'https://docs.aws.amazon.com/vpc/latest/peering/invalid-peering-configurations.html',
    // ── 2026-11-06 CLF·DVA·SAA 출처 URL 실측(전 콘텐츠 2단 검토 §P2-A) ──
    // 2026-10-29 감사는 SOA·DEA 만 쟀다 — 아래 12건은 CLF·DVA 를 처음 재서 찾았고,
    // 그중 Fargate 슬러그는 **SAA 7곳**에도 번져 있었다(보고서 범위가 하한이었다).
    'https://aws.amazon.com/compliance/data-center/controls/',
    'https://docs.aws.amazon.com/AmazonECS/latest/userguide/what-is-fargate.html',
    'https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-free-tier.html',
    'https://docs.aws.amazon.com/documentdb/latest/developerguide/what-is.html',
    'https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-retiring-applications/apg-7-rs.html',
    'https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-retiring-applications/apg-migration-strategies.html',
    'https://docs.aws.amazon.com/quicksight/latest/user/welcome.html',
    'https://docs.aws.amazon.com/snowball/latest/developer-guide/whatissnowball.html',
    'https://docs.aws.amazon.com/storagegateway/latest/userguide/WhatIsStorageGateway.html',
    'https://docs.aws.amazon.com/wellarchitected/latest/userguide/intro.html',
    'https://docs.aws.amazon.com/database-encryption-sdk/latest/devguide/DDB-encryption-context.html',
    'https://docs.aws.amazon.com/cli/latest/reference/aiops/index.html',
    // ── 2026-11-06 전 콘텐츠 2단 검토 §P2-SOA-5: SOA 학습문서 4편 ──────────
    // ⚠️ **문항은 처음부터 정본을 쓰고 있었다** — `.md` 만 낡은 채 남았다
    // (문항 가드는 학습문서를 보지 않는다. 2026-10-28 `saa-t4-3.md` 와 같은 자리).
    // ⚠️ `ec2-instance-recovery.html` 은 **슬러그 이름 차이**다 — 정본은 `recover`
    //    (끝의 `y` 없음)이고, 틀린 슬러그 대조군과 같은 신호(`200 r=1` → 인덱스)를
    //    주므로 「페이지 소멸」로 단정할 수 없다. 어느 쪽이든 지금 죽어 있다.
    'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recovery.html',
    'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSSnapshots.html',
    'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/snapshot-lifecycle.html',
    'https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-patch-patchgroups.html',
    // ⚠️ EBS 문서는 **양방향으로 움직였다** — 2026-10-29 감사가 `ebs/…/ebs-optimized`
    // → `AWSEC2/…/ebs-optimized` 로 바꾼 것은 지금도 맞고, 위 두 건은 **반대 방향**이다
    // (`AWSEC2` → `ebs`). 「EBS 문서는 전부 어느 한쪽으로 옮겨졌다」고 일반화하면 틀린다.
    // ── 같은 배치에서 실측한 인접 은퇴 슬러그(레포에 0건이지만 되살아나지 않게) ──
    // 사용자 정의 상태 확인 페이지의 옛 이름. 정본은 `set-up-a-custom-health-check.html`.
    'https://docs.aws.amazon.com/autoscaling/ec2/userguide/health-checks-custom.html',
    // Bedrock 모델 평가. 정본은 `evaluation.html`(2026-11-06 AIF 배치에서 실측).
    'https://docs.aws.amazon.com/bedrock/latest/userguide/model-evaluation.html',
    // ── 2026-11-06 2단 검토 §3-1(SAA): 이름 변경 3종 ────────────────────────
    // ⚠️ 셋 다 **도착지가 인덱스가 아니라 특정 페이지**다(대조군 `…_zz-bogus.html`
    // 은 인덱스로 간다) — 그래서 「소멸」이 아니라 「이름 변경」이다.
    'https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.ReadWriteCapacityMode.html',
    'https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_terms-and-concepts.html',
    // ⚠️⚠️ **이 건은 `saa_gaps_b11_test.dart` 가 정본을 금지하고 있었다** —
    // 2026-10-30 판정(「`declarative_policies` 는 죽은 슬러그」)이 재실측에서
    // 뒤집혀 가드를 먼저 고쳐야 했다. 가드는 판정을 굳히므로 판정이 틀리면
    // 가드도 틀린다(2026-11-06 AIF 배치의 교훈이 재현된 자리).
    'https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_declarative.html',
  ];

  /// 교체 후 들어간 정본 URL과 그것을 들고 있어야 하는 파일.
  /// "지웠다"만 보면 **출처를 통째로 삭제해도 통과**하므로 쌍으로 고정한다.
  const replacements = <String, List<String>>{
    'soa/soa-t1-1.questions.json': [
      'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-evaluation.html',
      'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html',
      'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-actions.html',
      'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Alarms.html',
    ],
    'soa/soa-t1-1.md': [
      'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Alarms.html',
      'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarm-evaluation.html',
      'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/alarms-and-missing-data.html',
      'https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Create_Composite_Alarm.html',
    ],
    'soa/soa-t1-3.questions.json': [
      'https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_eventbridge.html',
    ],
    'soa/soa-t1-4.questions.json': [
      'https://docs.aws.amazon.com/autoscaling/ec2/userguide/attach-load-balancer-asg.html',
    ],
    'soa/soa-t1-5.questions.json': [
      'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-optimized.html',
    ],
    // ── 2026-11-06 §P2-SOA-5 교체 정본(학습문서) ─────────────────────────
    'soa/soa-t1-4.md': [
      'https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-recover.html',
    ],
    'soa/soa-t2-3.md': [
      'https://docs.aws.amazon.com/ebs/latest/userguide/ebs-snapshots.html',
      'https://docs.aws.amazon.com/ebs/latest/userguide/snapshot-lifecycle.html',
    ],
    'soa/soa-t3-2.md': [
      'https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-patch-groups.html',
    ],
    // ── 2026-11-06 §3-1(SAA) 교체 정본 ──────────────────────────────────
    'saa/saa-t4-3.md': [
      'https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/capacity-mode.html',
    ],
    'saa/saa-t4-3.questions.json': [
      'https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/capacity-mode.html',
    ],
    'saa/saa-t1-1.md': [
      'https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html#id_roles_terms-and-concepts',
      'https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_declarative_policies.html',
    ],
    'soa/soa-t2-1.questions.json': [
      'https://docs.aws.amazon.com/autoscaling/ec2/userguide/ec2-auto-scaling-default-instance-warmup.html',
    ],
    'soa/soa-t2-4.questions.json': [
      'https://docs.aws.amazon.com/wellarchitected/latest/reliability-pillar/rel_planning_for_recovery_dr_tested.html',
    ],
    'soa/soa-t3-1.questions.json': [
      'https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/intrinsic-function-reference-findinmap.html',
      'https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/intrinsic-function-reference-importvalue.html',
      'https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-attribute-deletionpolicy.html',
      'https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stack-failure-options.html',
    ],
    'soa/soa-t3-1.md': [
      'https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-attribute-deletionpolicy.html',
    ],
    'soa/soa-t3-2.questions.json': [
      'https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-tag-a-patch-group.html',
      'https://docs.aws.amazon.com/systems-manager/latest/userguide/maintenance-windows.html',
    ],
    'soa/soa-t3-3.questions.json': [
      'https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-tag-a-patch-group.html',
      'https://docs.aws.amazon.com/systems-manager/latest/userguide/run-command.html',
      'https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager-aws-runpatchbaseline.html',
    ],
    'soa/soa-t3-4.questions.json': [
      'https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-log-api-call.html',
    ],
    'soa/soa-t4-1.questions.json': [
      'https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html',
      'https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_last-accessed.html',
    ],
    'soa/soa-t4-2.questions.json': [
      'https://docs.aws.amazon.com/config/latest/developerguide/evaluate-config_components.html',
    ],
    'soa/soa-t5-2.questions.json': [
      'https://docs.aws.amazon.com/vpc/latest/peering/vpc-peering-basics.html#vpc-peering-limitations',
      'https://docs.aws.amazon.com/wellarchitected/latest/framework/rel_planning_network_topology_ha_conn_private_networks.html',
    ],
    'soa/soa-t5-4.questions.json': [
      'https://docs.aws.amazon.com/vpc/latest/userguide/infrastructure-security.html',
    ],
    // ── 2026-11-06 CLF·DVA·SAA ──
    // ⚠️ Storage Gateway 는 **인용별로 갈랐다**: 통합 what-is 가 사라져 서비스 수준
    // 정본은 디렉터리 인덱스이고(200 r=0), Tape 인용은 tgw 가이드가 정본이다.
    'clf/t1-3.md': [
      'https://docs.aws.amazon.com/snowball/latest/developer-guide/whatisedge.html',
      'https://docs.aws.amazon.com/prescriptive-guidance/latest/large-migration-guide/migration-strategies.html',
    ],
    'clf/t1-3.questions.json': [
      'https://docs.aws.amazon.com/snowball/latest/developer-guide/whatisedge.html',
      'https://docs.aws.amazon.com/prescriptive-guidance/latest/large-migration-guide/migration-strategies.html',
    ],
    'clf/t1-2.questions.json': [
      'https://docs.aws.amazon.com/wellarchitected/latest/userguide/tool.html',
    ],
    'clf/t2-1.questions.json': [
      'https://aws.amazon.com/trust-center/data-center/our-controls/',
    ],
    'clf/t3-3.md': [
      'https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html',
    ],
    'clf/t3-3.questions.json': [
      'https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html',
    ],
    'clf/t3-4.questions.json': [
      'https://docs.aws.amazon.com/documentdb/latest/devguide/what-is.html',
    ],
    'clf/t3-6.md': [
      'https://docs.aws.amazon.com/storagegateway/',
    ],
    'clf/t3-6.questions.json': [
      'https://docs.aws.amazon.com/storagegateway/',
      'https://docs.aws.amazon.com/storagegateway/latest/tgw/WhatIsStorageGateway.html',
    ],
    'clf/t3-7.md': [
      'https://docs.aws.amazon.com/quick/latest/userguide/what-is.html',
    ],
    'clf/t3-7.questions.json': [
      'https://docs.aws.amazon.com/quick/latest/userguide/what-is.html',
    ],
    'clf/t4-1.questions.json': [
      'https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/free-tier.html',
      'https://aws.amazon.com/free/',
    ],
    'saa/saa-t2-2.md': [
      'https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html',
    ],
    'saa/saa-t2-2.questions.json': [
      'https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html',
    ],
    'saa/saa-t3-4.questions.json': [
      'https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html',
    ],
    'dva/dva-t2-2.md': [
      'https://docs.aws.amazon.com/database-encryption-sdk/latest/devguide/DDB-encrypted-and-signed.html',
    ],
    'dva/dva-t4-1.md': [
      'https://docs.aws.amazon.com/cli/latest/reference/aiops/',
    ],
  };

  // 레포 전 자격증을 본다 — 같은 URL이 다른 자격증 콘텐츠에 복사됐을 수 있다.
  final root = Directory('assets/content');
  final files = root
      .listSync()
      .whereType<Directory>()
      .expand((d) => d.listSync().whereType<File>())
      .where((f) => f.path.endsWith('.md') || f.path.endsWith('.questions.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  String rel(File f) => f.path.replaceAll('\\', '/').split('assets/content/').last;

  test('대조군: 콘텐츠 파일이 읽혔다', () {
    // 0건 통과가 "파일을 못 읽어서"일 수 있다 — 먼저 센다.
    expect(files.length, greaterThanOrEqualTo(150),
        reason: '파일 수가 급감했다면 이 가드의 검사 범위부터 다시 보라');
    final total = files.fold<int>(0, (a, f) => a + f.readAsStringSync().length);
    expect(total, greaterThan(1000000));
  });

  group('은퇴한 출처 URL이 콘텐츠에 남아 있지 않다', () {
    for (final url in retiredUrls) {
      test(url.replaceFirst('https://docs.aws.amazon.com/', ''), () {
        final hits = files
            .where((f) => f.readAsStringSync().contains(url))
            .map(rel)
            .toList();
        expect(hits, isEmpty,
            reason: '리다이렉트하는 URL이 남아 있다(2026-10-29 실측). '
                '정본은 docs/saa-review/2026-10-29-soa-dea-source-url-audit.md: $hits');
      });
    }
  });

  test('교체한 정본 URL이 해당 파일에 실재한다', () {
    final missing = <String>[];
    for (final entry in replacements.entries) {
      final f = File('assets/content/${entry.key}');
      expect(f.existsSync(), isTrue, reason: '${entry.key} 가 없다');
      final text = f.readAsStringSync();
      for (final url in entry.value) {
        if (!text.contains(url)) missing.add('${entry.key} ← $url');
      }
    }
    expect(missing, isEmpty,
        reason: '출처를 지우기만 하면 위 가드는 통과한다 — 정본으로 교체했는지 함께 본다:\n'
            '${missing.join('\n')}');
  });
}
