// users/{uid} 아래는 그 uid 본인만 읽고 쓸 수 있어야 한다(동기 v2 설계 §8).
// 실행: npm test (Firestore 에뮬레이터 필요 — firebase emulators:exec이 띄운다)
import { test, before, after } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import { deleteDoc, doc, getDoc, setDoc } from 'firebase/firestore';

let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'awc-docs-cf67d',
    firestore: {
      rules: readFileSync(
        new URL('../../firestore.rules', import.meta.url),
        'utf8',
      ),
    },
  });
});

after(async () => {
  await env?.cleanup();
});

test('본인 문서는 읽고 쓸 수 있다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(setDoc(doc(db, 'users/u1/attempts/a1'), { correct: 1 }));
  await assertSucceeds(getDoc(doc(db, 'users/u1/attempts/a1')));
});

test('타인 uid 문서는 읽을 수 없다', async () => {
  const db = env.authenticatedContext('u2').firestore();
  await assertFails(getDoc(doc(db, 'users/u1/attempts/a1')));
});

test('비로그인은 읽을 수 없다', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/u1/attempts/a1')));
});

// 계정 삭제(A7)가 이 권한에 의존한다 — 규칙은 read/write 만 적고 delete 를 따로
// 적지 않으므로(write 에 포함) **삭제가 실제로 허용되는지**를 못박아 둔다.
// ⚠️ 위 테스트들이 공유하는 `attempts/a1` 은 건드리지 않는다(별 문서 id 를 쓴다).
test('본인 문서는 삭제할 수 있다 — 계정 삭제가 이 권한에 의존한다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(setDoc(doc(db, 'users/u1/viewed/del1'), { v: 1 }));
  await assertSucceeds(deleteDoc(doc(db, 'users/u1/viewed/del1')));
});

// ⚠️ 계정 삭제는 **본인 uid 아래만** 지운다. 타인 경로 삭제가 열려 있으면 한 계정의
// 삭제가 남의 데이터를 지울 수 있다.
test('타인 uid 문서는 삭제할 수 없다', async () => {
  const db = env.authenticatedContext('u2').firestore();
  await assertFails(deleteDoc(doc(db, 'users/u1/attempts/a1')));
});

// D2 — 피드백은 `users/{uid}/feedback/{id}` 에 들어간다. **규칙을 바꾸지 않았다**:
// 아래 셋은 「지금 동작이 의도한 것임」을 못박는 회귀 가드다. 이 쓰기가 기존 규칙으로
// 되기 때문에 그 기능이 사용자의 콘솔 배포(사람 몫)를 부르지 않는다.
test('본인 feedback 문서는 쓰고 읽을 수 있다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(
    setDoc(doc(db, 'users/u1/feedback/f1'), { kind: 'bug', body: 'x' }),
  );
  // 「내가 보낸 의견」 목록이 이 읽기 권한에 기댄다.
  await assertSucceeds(getDoc(doc(db, 'users/u1/feedback/f1')));
});

test('타인 uid 의 feedback 문서는 쓸 수 없다', async () => {
  const db = env.authenticatedContext('u2').firestore();
  await assertFails(
    setDoc(doc(db, 'users/u1/feedback/f2'), { kind: 'bug', body: 'x' }),
  );
});

test('비로그인은 feedback 을 쓸 수 없다', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(
    setDoc(doc(db, 'users/u1/feedback/f3'), { kind: 'bug', body: 'x' }),
  );
});

// 계정 삭제가 피드백까지 지운다(`kUserOwnedCollections`) — 그 삭제가 규칙으로
// 허용되는지 못박는다.
test('본인 feedback 문서는 삭제할 수 있다', async () => {
  const db = env.authenticatedContext('u1').firestore();
  await assertSucceeds(
    setDoc(doc(db, 'users/u1/feedback/del1'), { kind: 'bug', body: 'x' }),
  );
  await assertSucceeds(deleteDoc(doc(db, 'users/u1/feedback/del1')));
});
