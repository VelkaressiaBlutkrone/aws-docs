import 'dart:async';

import 'package:flutter/material.dart' hide Text;

import '../app_errors.dart';
import '../data/cloud/auth_user.dart';
import '../data/cloud/feedback_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/text.dart';

/// 유형별 한국어 라벨. `question`·`content` 가 검수 흐름으로 들어오는 입구다.
const _kindLabels = <FeedbackKind, String>{
  FeedbackKind.question: '문항 오류',
  FeedbackKind.content: '학습문서 오류',
  FeedbackKind.bug: '동작 이상',
  FeedbackKind.idea: '기능 제안',
  FeedbackKind.other: '그 밖',
};

/// 의견 보내기 — 유형·본문 + 내가 보낸 의견 목록.
///
/// ⚠️ 로그인이 필요하다(설계 §5-2). 비로그인에게는 폼 대신 안내와 로그인 버튼을
/// 보인다 — 빈 화면이나 비활성 버튼을 두지 않는다.
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({
    super.key,
    this.service,
    this.initialKind,
    this.initialContext,
  });

  /// 전송·조회. null 이면(전역 주입 전 · Firebase 미설정) 안내만 보인다.
  final FeedbackService? service;

  /// 신고 진입점이 넘기는 초기 유형·대상(라우트 `extra` 의 [FeedbackLaunch]).
  final FeedbackKind? initialKind;
  final FeedbackContext? initialContext;

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _body = TextEditingController();
  late FeedbackKind _kind = widget.initialKind ?? FeedbackKind.bug;
  bool _sending = false;
  bool _signingIn = false;
  bool _signInFailed = false;
  bool _mineLoaded = false;
  FeedbackSendResult? _result;
  List<Map<String, dynamic>> _mine = const [];
  StreamSubscription<AuthUser?>? _authSub;

  @override
  void initState() {
    super.initState();
    // 본문이 비면 전송 버튼이 비활성이므로 입력마다 리빌드가 필요하다.
    _body.addListener(_onBodyChanged);
    final svc = widget.service;
    if (svc != null) {
      // 로그인 직후 폼으로 바뀌어야 한다.
      _authSub = svc.authChanges().listen((_) {
        if (!mounted) return;
        setState(() {});
        _loadMine();
      });
      _loadMine();
    }
  }

  void _onBodyChanged() => setState(() {});

  @override
  void dispose() {
    _authSub?.cancel();
    _body.removeListener(_onBodyChanged);
    _body.dispose();
    super.dispose();
  }

  /// 로그인 — 실패를 **화면에** 올린다(서비스가 예외를 잡아 false 를 준다).
  /// 취소는 실패가 아니라 true 이므로 문구가 뜨지 않는다(A4 판정).
  Future<void> _signIn(FeedbackService svc) async {
    if (_signingIn) return;
    setState(() {
      _signingIn = true;
      _signInFailed = false;
    });
    final ok = await svc.signIn();
    if (!mounted) return;
    setState(() {
      _signingIn = false;
      _signInFailed = !ok;
    });
  }

  Widget? _signInErrorBox(AppColors c) {
    if (!_signInFailed) return null;
    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: Text('로그인하지 못했습니다. 잠시 뒤 다시 시도해 주세요.',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontVariations: Wght.w700,
              color: c.warningText)),
    );
  }

  Future<void> _loadMine() async {
    final svc = widget.service;
    if (svc == null) return;
    final list = await svc.mine();
    if (!mounted) return;
    setState(() {
      _mine = list;
      _mineLoaded = true;
    });
  }

  /// ⚠️ `_sending` 가 중복 전송을 막는다 — 같은 의견이 두 문서로 들어오면
  /// 운영자가 중복을 읽는다. 버튼 비활성과 **두 겹**으로 둔다.
  ///
  /// ⚠️⚠️ **`finally` 로 반드시 되돌린다.** 이것이 없으면 `send` 가 던질 때
  /// `_sending` 이 true 로 남아 버튼이 「보내는 중입니다…」로 **영구히 잠기고**
  /// 사용자는 원인도 못 본다(`onPressed` 가 동기라 호출부가 Future 를 버린다).
  /// 2026-11-21 리뷰가 Critical 로 잡은 자리다 — `send` 는 내부에서 넓게 잡지만
  /// 그 `try` **앞** 구간(시각·컨텍스트 직렬화·문서 조립·id 생성)과 아래
  /// `_loadMine()` 은 보호되지 않는다.
  Future<void> _send() async {
    final svc = widget.service;
    if (svc == null || _sending) return;
    setState(() {
      _sending = true;
      _result = null;
    });
    var result = FeedbackSendResult.failed;
    try {
      result = await svc.send(
        kind: _kind,
        body: _body.text,
        context: widget.initialContext,
      );
      // 큐 적립도 성공이다(설계 §7-2) — 본문을 비우고 목록을 갱신한다.
      if (result == FeedbackSendResult.sent ||
          result == FeedbackSendResult.queued) {
        _body.clear();
        await _loadMine();
      }
    } catch (e, st) {
      appLog('피드백 전송 실패: $e\n$st'); // 조용히 삼키지 않는다
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
          _result = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: const AppHeader.document(title: '의견 보내기'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.lg)
            .copyWith(bottom: scrollBottomInset(context, gap: Gap.lg)),
        child: _body0(context),
      ),
    );
  }

  Widget _body0(BuildContext context) {
    final c = context.c;
    final svc = widget.service;
    if (svc == null) {
      return _notice(c, '의견 보내기는 지금 사용할 수 없습니다.',
          '클라우드 설정이 준비되면 쓸 수 있습니다.');
    }
    if (!svc.isSignedIn) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _notice(c, '의견을 보내려면 Google 로그인이 필요합니다.',
              '보낸 의견을 다시 볼 수 있고, 계정을 지우면 함께 지워집니다.'),
          const SizedBox(height: Gap.lg),
          FilledButton(
            onPressed: _signingIn ? null : () => unawaited(_signIn(svc)),
            child: Text(_signingIn ? '로그인하고 있습니다…' : 'Google로 로그인'),
          ),
          // ⚠️ 로그인 실패가 화면에 닿아야 한다 — `onPressed` 는 동기라 호출부가
          // Future 를 버리고, 그러면 사용자는 버튼이 고장난 줄 안다(A4 선례).
          ?_signInErrorBox(c),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KindPicker(
          selected: _kind,
          onSelected: (k) => setState(() => _kind = k),
        ),
        const SizedBox(height: Gap.lg),
        ?_hint(c),
        TextField(
          controller: _body,
          maxLines: 6,
          minLines: 4,
          maxLength: kFeedbackBodyMax,
          style: TextStyle(fontSize: 15, height: 1.6, color: c.text),
          decoration: InputDecoration(
            hintText: '무엇이 어떻게 잘못됐는지 적어 주세요.',
            // ⚠️ hint 는 사용자가 읽는 안내 텍스트라 가장 연한 토큰을 쓰지 않는다
            // (`theme_contrast_test` 가 그 토큰을 비활성·장식에만 허용한다).
            hintStyle: TextStyle(color: c.textMuted),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: Gap.md),
        FilledButton(
          onPressed:
              _sending || _body.text.trim().isEmpty ? null : () => unawaited(_send()),
          child: Text(_sending ? '보내는 중입니다…' : '보내기'),
        ),
        ?_resultBox(c),
        const SizedBox(height: Gap.xl2),
        Text('내가 보낸 의견',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: c.text,
                fontWeight: FontWeight.w700,
                fontVariations: Wght.w700)),
        const SizedBox(height: Gap.md),
        if (_mineLoaded && _mine.isEmpty)
          Text('아직 보낸 의견이 없습니다',
              style: TextStyle(fontSize: 14, color: c.textMuted)),
        for (final m in _mine) _SentCard(doc: m),
      ],
    );
  }

  /// 유형·컨텍스트에 따른 안내. 이번 범위에 학습문서 진입점이 없으므로
  /// 그 유형은 폼 문구가 메운다(설계 §7-2).
  Widget? _hint(AppColors c) {
    final qid = widget.initialContext?.questionId;
    final lines = <String>[
      if (qid != null) '대상 문항: $qid',
      if (qid != null) '어느 보기인지 내용을 그대로 적어 주시면 더 빠릅니다.',
      if (_kind == FeedbackKind.content) '어느 학습 문서인지 함께 적어 주세요.',
    ];
    if (lines.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final l in lines)
            Text(l, style: TextStyle(fontSize: 13, color: c.textMuted)),
        ],
      ),
    );
  }

  Widget? _resultBox(AppColors c) {
    final r = _result;
    if (r == null) return null;
    // ⚠️⚠️ 보조 문구(「네트워크가 잠시 불안정…다시 시도하면」)는 **`failed` 에만**
    // 붙인다. `notSignedIn` 은 Review Focus 3 이 지정한 실제 도달 상태이고 그때
    // 재시도 조언은 **거짓**이다(다시 시도해도 영원히 안 된다). `invalid` 도
    // 길이·빈 본문 문제라 네트워크와 무관하다 — 2026-11-21 리뷰 지적.
    final transient = r == FeedbackSendResult.failed;
    final bad = transient ||
        r == FeedbackSendResult.invalid ||
        r == FeedbackSendResult.notSignedIn;
    final message = switch (r) {
      FeedbackSendResult.sent => '의견을 보냈습니다.',
      FeedbackSendResult.queued => '의견을 저장했습니다 — 네트워크가 연결되면 올라갑니다.',
      FeedbackSendResult.notSignedIn => '의견을 보내려면 Google 로그인이 필요합니다.',
      FeedbackSendResult.invalid || FeedbackSendResult.failed =>
        '의견을 보내지 못했습니다.',
    };
    final hint = switch (r) {
      FeedbackSendResult.failed =>
        '네트워크가 잠시 불안정했을 수 있습니다. 다시 시도하면 대부분 해결됩니다.',
      FeedbackSendResult.invalid =>
        '본문을 1자 이상 $kFeedbackBodyMax자 이하로 적어 주세요.',
      FeedbackSendResult.notSignedIn =>
        '다른 기기나 탭에서 로그아웃됐을 수 있습니다. 다시 로그인하면 보낼 수 있습니다.',
      FeedbackSendResult.sent || FeedbackSendResult.queued => null,
    };
    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // warningText/surface2 는 theme_contrast_test 가 AA 로 단정하는 쌍이다.
          Text(message,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontVariations: Wght.w700,
                  color: bad ? c.warningText : c.accentStrong)),
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(top: Gap.xs),
              child: Text(hint,
                  style: TextStyle(fontSize: 13, color: c.textMuted)),
            ),
        ],
      ),
    );
  }

  Widget _notice(AppColors c, String title, String description) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.lg),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontVariations: Wght.w700,
                    color: c.text)),
            const SizedBox(height: Gap.xs),
            Text(description,
                style: TextStyle(fontSize: 13, color: c.textMuted)),
          ],
        ),
      );
}

/// 유형 선택 — Material 칩의 기본 탭 영역이 48dp 다(`MaterialTapTargetSize.padded`).
class _KindPicker extends StatelessWidget {
  const _KindPicker({required this.selected, required this.onSelected});
  final FeedbackKind selected;
  final ValueChanged<FeedbackKind> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Wrap(
      spacing: Gap.sm,
      runSpacing: Gap.sm,
      children: [
        for (final k in FeedbackKind.values)
          ChoiceChip(
            label: Text(_kindLabels[k]!),
            selected: selected == k,
            onSelected: (_) => onSelected(k),
            backgroundColor: c.surface,
            selectedColor: c.accentWeak,
            side: BorderSide(color: selected == k ? c.accent : c.border),
            labelStyle: TextStyle(
                fontSize: 14,
                color: c.text,
                fontWeight: FontWeight.w600,
                fontVariations: Wght.w600),
          ),
      ],
    );
  }
}

/// 보낸 의견 한 건 — 유형과 본문.
class _SentCard extends StatelessWidget {
  const _SentCard({required this.doc});
  final Map<String, dynamic> doc;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    final kindName = (doc['kind'] ?? '').toString();
    final kind = FeedbackKind.values
        .where((k) => k.name == kindName)
        .firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Gap.md),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kind == null ? '의견' : _kindLabels[kind]!,
                style: TextStyle(fontSize: 12, color: c.textMuted)),
            const SizedBox(height: Gap.xs),
            Text((doc['body'] ?? '').toString(),
                style: TextStyle(fontSize: 14, height: 1.6, color: c.text)),
          ],
        ),
      ),
    );
  }
}
