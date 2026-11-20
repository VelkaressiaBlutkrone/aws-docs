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
