"""Throwaway slide-first pilot: Alias vs CNAME. Slides first, narration written per reveal step. No repo writes."""
import base64, hashlib, json, pathlib, subprocess, wave
HERE = pathlib.Path(__file__).parent; CACHE = HERE / 'slide_cache'; CACHE.mkdir(exist_ok=True)
RATE = 24000; GAP = .38; SLIDE_GAP = .75; LEAD = .12

SLIDES = [
 '''<div class="kick">Route 53 · Alias vs CNAME</div><h2>루트 도메인을 ALB로 연결하려면?</h2>
 <div class="flow"><b class="node r" data-k="1">example.com</b><i class="r" data-k="1">→</i><b class="node acc r" data-k="1">ALB</b></div>
 <div class="pair r" data-k="2"><span class="chip">CNAME?</span><span class="chip">Alias?</span></div>''',
 '''<div class="kick">두 레코드의 역할</div><h2>무엇을 가리키는가</h2><div class="cards">
 <section class="card r" data-k="0"><h3>CNAME</h3><div class="mini"><b>이름</b><i>→</i><b>임의의 도메인</b></div></section>
 <section class="card r" data-k="1"><h3>Alias</h3><p>Route 53 전용 확장</p><div class="mini"><b>이름</b><i>→</i><b class="acc">AWS 리소스</b></div></section></div>''',
 '''<div class="kick">네 가지 기준</div><h2>Alias vs CNAME</h2><table><thead><tr><th></th><th>Alias</th><th>CNAME</th></tr></thead><tbody>
 <tr class="r" data-k="0"><th>대상</th><td>AWS 리소스</td><td>임의의 도메인</td></tr>
 <tr class="r" data-k="1"><th>Zone Apex</th><td class="ok">가능</td><td class="no">불가</td></tr>
 <tr class="r" data-k="2"><th>쿼리 비용</th><td class="ok">무료</td><td>일반 과금</td></tr>
 <tr class="r" data-k="3"><th>IP 변경</th><td class="ok">자동 반영</td><td>직접 관리</td></tr></tbody></table>''',
 '''<div class="kick">원리</div><h2>왜 루트 도메인에 CNAME을 못 쓸까?</h2><div class="zone"><div class="zh">example.com (Zone Apex)</div>
 <div class="recs"><span class="rec r" data-k="0">NS</span><span class="rec r" data-k="0">SOA</span><span class="rec bad r" data-k="2">CNAME ✕</span></div></div>
 <p class="rule r" data-k="1">CNAME이 있는 이름에는 다른 레코드가 공존할 수 없다</p><p class="warn r" data-k="2">표준 위반 → 해석기가 정상 동작하지 않을 수 있음</p>''',
 '''<div class="kick">해결</div><h2>Alias는 어떻게 피할까?</h2><div class="flow"><b class="node">example.com</b><i>→</i><b class="node r" data-k="0">A / AAAA로 동작</b><i class="r" data-k="1">→</i><b class="node acc r" data-k="1">AWS 리소스</b></div>
 <p class="rule r" data-k="1">리소스의 현재 IP를 자동으로 따라간다</p><p class="good r" data-k="2">IP가 바뀌는 ALB·CloudFront에도 안전하게 연결</p>''',
 '''<div class="kick">확인 문제</div><h2>example.com을 CloudFront 배포로 연결한다. 어떤 레코드?</h2><div class="opts"><div class="opt">CNAME</div><div class="opt ans">Alias</div></div>
 <p class="good r" data-k="1">루트 도메인 + AWS 리소스</p><p class="take r" data-k="2">루트 도메인 → AWS 리소스 = Alias</p>''',
]
STEPS = [
 (0,0,'이번 시간에는 라우트 피프티스리의 단골 출제 주제, 에일리어스와 씨네임을 구분해 보겠습니다.'),
 (0,1,'상황부터 보시죠. 회사의 루트 도메인인 이그잼플 닷컴을 에이엘비로 연결해야 합니다.'),
 (0,2,'이때 씨네임을 쓸까요, 에일리어스를 쓸까요? 이 선택이 오늘의 핵심입니다.'),
 (1,0,'먼저 씨네임입니다. 씨네임은 어떤 이름을 임의의 다른 도메인으로 가리킵니다.'),
 (1,1,'에일리어스는 라우트 피프티스리 전용 확장입니다. 에이엘비나 클라우드프론트 같은 에이더블유에스 리소스를 가리킵니다.'),
 (2,0,'이제 네 가지 기준으로 비교해 보겠습니다. 첫째, 대상입니다. 에일리어스는 에이더블유에스 리소스, 씨네임은 임의의 도메인입니다.'),
 (2,1,'둘째, 존 에이펙스, 즉 루트 도메인입니다. 에일리어스는 쓸 수 있고, 씨네임은 쓸 수 없습니다. 이 줄이 오늘의 핵심입니다.'),
 (2,2,'셋째, 쿼리 비용입니다. 에일리어스 쿼리는 무료이고, 씨네임은 일반 과금입니다.'),
 (2,3,'넷째, 아이피 변경입니다. 에이더블유에스 리소스의 아이피가 바뀌면 에일리어스는 자동으로 반영하고, 씨네임은 직접 관리해야 합니다.'),
 (3,0,'그렇다면 왜 루트 도메인에는 씨네임을 못 쓸까요? 루트 도메인은 디엔에스 영역 자체의 엔에스와 에스오에이 레코드를 반드시 가지고 있습니다.'),
 (3,1,'그런데 디엔에스 규칙은, 씨네임이 있는 이름에 다른 레코드가 함께 있을 수 없다고 정합니다.'),
 (3,2,'그래서 여기에 씨네임을 넣으면 표준 위반이 되고, 해석기가 정상적으로 동작하지 않을 수 있습니다.'),
 (4,0,'에일리어스는 이 제약을 이렇게 피합니다. 실제 레코드 유형은 에이 또는 쿼드에이로 동작합니다.'),
 (4,1,'그리고 연결한 에이더블유에스 리소스의 현재 아이피를 자동으로 따라갑니다.'),
 (4,2,'덕분에 아이피가 바뀌는 에이엘비나 클라우드프론트에도 루트 도메인을 안전하게 연결할 수 있습니다.'),
 (5,0,'그럼 문제로 확인해 보겠습니다. 이그잼플 닷컴을 클라우드프론트 배포로 연결해야 합니다. 씨네임일까요, 에일리어스일까요? 잠깐 생각해 보세요.'),
 (5,1,'정답은 에일리어스입니다. 루트 도메인이고, 대상이 에이더블유에스 리소스이기 때문입니다.'),
 (5,2,'기억하실 문장은 하나입니다. 루트 도메인을 에이더블유에스 리소스로 연결하면, 답은 에일리어스입니다.'),
]
chars = sum(len(t) for *_, t in STEPS); assert chars < 3000, chars
def synth(text):
    p = CACHE / (hashlib.sha256(text.encode()).hexdigest()[:16] + '.pcm')
    if not p.exists():
        import boto3
        r = boto3.client('polly', region_name='ap-northeast-2').synthesize_speech(Text=text, OutputFormat='pcm', SampleRate='16000', VoiceId='Seoyeon', Engine='neural', LanguageCode='ko-KR')
        p.write_bytes(r['AudioStream'].read())
    return p.read_bytes()
SR = 16000; pcm = bytearray(); cues = []; prev = None
for i, (s, k, text) in enumerate(STEPS):
    pause = 0 if i == 0 else (SLIDE_GAP if s != prev else GAP)
    if i == 16: pause = 3.0   # 문제를 생각할 시간
    pcm += b'\0\0' * int(SR * pause)
    t = len(pcm) / 2 / SR
    pcm += synth(text); prev = s
    cues.append({'t': round(t + LEAD, 3), 's': s, 'k': k, 'text': text, 'end': round(len(pcm) / 2 / SR, 3)})
pcm += b'\0\0' * int(SR * .8)
wav = HERE / 'slide_first.wav'
with wave.open(str(wav), 'wb') as w: w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(bytes(pcm))
mp3 = HERE / 'slide_first.mp3'
subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-i', str(wav), '-af', 'loudnorm=I=-16:TP=-1.5:LRA=11', '-ar', '24000', '-ac', '1', '-b:a', '64k', str(mp3)], check=True)
dur = float(subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', str(mp3)], capture_output=True, text=True).stdout)
page = r'''<!doctype html><html lang="ko"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>슬라이드 전용 강의 시험</title><style>
:root{color-scheme:light dark;--b:#FBFAF8;--s:#fff;--s2:#F3F1EC;--t:#1B2430;--m:#5b6673;--l:#e4e1da;--a:#0E8175;--aw:#E2F2EF;--w:#956319;--ww:#F8EFDD;--x:#B3261E}@media(prefers-color-scheme:dark){:root{--b:#14181F;--s:#1c222b;--s2:#242b35;--t:#e8ecf1;--m:#a4adb8;--l:#303844;--a:#3fb8a9;--aw:#17322f;--w:#D9A441;--ww:#2A2113;--x:#f2978f}}
*{box-sizing:border-box}body{margin:0;background:var(--b);color:var(--t);font:16px/1.55 Pretendard,"Malgun Gothic",system-ui,sans-serif;word-break:keep-all}main{max-width:980px;margin:auto;padding:16px}
#stage{aspect-ratio:16/9;min-height:400px;width:100%;background:var(--s);border:1px solid var(--l);border-radius:10px;padding:clamp(20px,4vw,44px);overflow:auto;transition:opacity .18s ease}#stage.sw{opacity:0}.kick{color:var(--a);font-size:14px;font-weight:800}h2{font-size:clamp(24px,3.4vw,34px);line-height:1.3;margin:6px 0 clamp(16px,3vw,30px)}
.r{opacity:0;transform:translateY(5px);transition:opacity .22s ease,transform .22s ease,background .22s,box-shadow .22s}.r.show{opacity:1;transform:none}.now{box-shadow:0 0 0 2px var(--a);border-radius:7px}tr.now{box-shadow:none;background:var(--aw)}
.flow{display:flex;align-items:center;gap:12px;flex-wrap:wrap;margin:10px 0 20px}.flow>i{font-style:normal;color:var(--m);font-size:24px}.node{background:var(--s2);border:1px solid var(--l);border-radius:8px;padding:12px 18px;font-size:clamp(17px,2.2vw,22px)}.acc{color:var(--a)}.pair{display:flex;gap:10px}.chip{background:var(--s2);border-radius:99px;padding:7px 16px;font-weight:700}
.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:14px}.card{background:var(--s2);border-radius:9px;padding:18px}.card h3{margin:0 0 4px;font-size:22px}.card p{margin:0;color:var(--m);font-size:14px}.mini{display:flex;gap:8px;align-items:center;flex-wrap:wrap;margin-top:12px;font-size:18px}.mini i{font-style:normal;color:var(--m)}
table{width:100%;border-collapse:collapse;font-size:clamp(15px,2vw,20px)}th,td{padding:clamp(7px,1.2vw,12px);border-bottom:1px solid var(--l);text-align:left}thead th{color:var(--m);font-size:14px}tbody th{font-weight:700}.ok{color:var(--a);font-weight:700}.no{color:var(--x);font-weight:700}
.zone{border:1px solid var(--l);background:var(--s2);border-radius:9px;padding:16px}.zh{font-weight:800;margin-bottom:10px}.recs{display:flex;gap:9px;flex-wrap:wrap}.rec{background:var(--s);border:1px solid var(--l);border-radius:7px;padding:8px 16px;font-weight:700;font-family:Consolas,monospace}.bad{color:var(--x);border-color:var(--x)}.rule{font-size:clamp(17px,2.2vw,21px);font-weight:700;margin:16px 0 5px}.warn{color:var(--w);font-weight:700;margin:0}.good{color:var(--a);font-weight:700;margin:6px 0;font-size:18px}
.opts{display:flex;gap:12px;flex-wrap:wrap;margin-bottom:14px}.opt{min-width:150px;text-align:center;border:1px solid var(--l);background:var(--s2);border-radius:8px;padding:14px 18px;font-size:20px;font-weight:700}.opt.hit{background:var(--a);border-color:var(--a);color:#fff}.take{font-size:clamp(19px,2.6vw,25px);font-weight:800;margin:10px 0 0}
#seek{width:100%;margin:12px 0 4px;accent-color:var(--a)}.ctl{display:flex;align-items:center;gap:8px;flex-wrap:wrap}button{min-height:44px;min-width:44px;padding:0 14px;border-radius:8px;border:1px solid var(--l);background:var(--s);color:inherit;font:inherit;cursor:pointer}button.main{background:var(--a);border-color:var(--a);color:#fff;font-weight:700}button.sel{background:var(--a);border-color:var(--a);color:#fff}#time{color:var(--m);font-variant-numeric:tabular-nums;margin-left:auto}.ask{display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-top:14px;padding-top:12px;border-top:1px solid var(--l)}@media(max-width:640px){#stage{aspect-ratio:auto;min-height:470px}}@media(prefers-reduced-motion:reduce){*{transition:none!important}}
</style><main><div id="stage"></div><input id="seek" type="range" min="0" step=".01" aria-label="강의 위치"><div class="ctl"><button id="prev" aria-label="이전 슬라이드">이전</button><button id="play" class="main">재생</button><button id="next" aria-label="다음 슬라이드">다음</button><span id="time"></span></div><div class="ask"><span>끝까지 들어 보니 인강처럼 느껴지나요?</span><button id="yes">그렇다</button><button id="no">아니다</button></div></main>
<script>const SLIDES=__SLIDES__,C=__CUES__,au=new Audio('data:audio/mpeg;base64,__AUDIO__');window.VERDICT=null;window.MAXT=0;const st=document.getElementById('stage'),sk=document.getElementById('seek'),pl=document.getElementById('play'),tm=document.getElementById('time');let slide=-1,key=-1;
const fmt=x=>`${Math.floor(x/60)}:${String(Math.floor(x%60)).padStart(2,'0')}`;const at=t=>{let i=0;for(let j=0;j<C.length;j++)if(C[j].t<=t)i=j;return i};
function apply(s,k){st.querySelectorAll('[data-k]').forEach(e=>{const n=+e.dataset.k;e.classList.toggle('show',n<=k);e.classList.toggle('now',n===k)});if(s===5){const a=st.querySelector('.ans');if(a)a.classList.toggle('hit',k>=1)}}
function show(s,k){if(s!==slide){const first=slide<0;slide=s;const go=()=>{st.innerHTML=SLIDES[s];st.scrollTop=0;apply(s,k);st.classList.remove('sw')};if(first||matchMedia('(prefers-reduced-motion: reduce)').matches)go();else{st.classList.add('sw');setTimeout(go,150)}}else apply(s,k);key=k}
function tick(){const t=au.currentTime,c=C[at(t)];if(c.s!==slide||c.k!==key)show(c.s,c.k);if(document.activeElement!==sk)sk.value=t;tm.textContent=`슬라이드 ${c.s+1}/${SLIDES.length} · ${fmt(t)} / ${fmt(au.duration||0)}`;window.MAXT=Math.max(window.MAXT,t)}
au.onloadedmetadata=()=>{sk.max=au.duration;tick()};setInterval(tick,40);pl.onclick=()=>au.paused?au.play():au.pause();au.onplay=()=>pl.textContent='일시정지';au.onpause=()=>pl.textContent='재생';au.onended=()=>pl.textContent='다시 재생';sk.oninput=()=>au.currentTime=+sk.value;
const jump=d=>{const cur=C[at(au.currentTime)].s,tg=Math.max(0,Math.min(SLIDES.length-1,cur+d));au.currentTime=C.find(c=>c.s===tg).t};document.getElementById('prev').onclick=()=>jump(-1);document.getElementById('next').onclick=()=>jump(1);addEventListener('keydown',e=>{if(e.target.tagName==='BUTTON'&&e.key===' ')return;if(e.key===' '){e.preventDefault();pl.click()}if(e.key==='ArrowRight')jump(1);if(e.key==='ArrowLeft')jump(-1)});
const y=document.getElementById('yes'),n=document.getElementById('no');y.onclick=()=>{VERDICT=true;y.classList.add('sel');n.classList.remove('sel')};n.onclick=()=>{VERDICT=false;n.classList.add('sel');y.classList.remove('sel')};show(0,0)</script></html>'''
out = HERE / 'p0-slide-first.html'
out.write_text(page.replace('__SLIDES__', json.dumps(SLIDES, ensure_ascii=False).replace('</', '<\\/')).replace('__CUES__', json.dumps(cues, ensure_ascii=False)).replace('__AUDIO__', base64.b64encode(mp3.read_bytes()).decode()), encoding='utf-8')
print('ok chars', chars, 'usd', round(chars * 16 / 1e6, 4), 'dur', round(dur, 2), 'pcmDur', round(len(pcm) / 2 / SR, 2), 'steps', len(cues), 'size', out.stat().st_size)
