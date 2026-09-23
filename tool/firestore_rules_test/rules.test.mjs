// users/{uid} 아래는 그 uid 본인만 읽고 쓸 수 있어야 한다(동기 v2 설계 §8).
// 실행: npm test (Firestore 에뮬레이터 필요 — firebase emulators:exec이 띄운다)
import { test, before, after } from 'node:test';
import { readFileSync } from 'node:fs';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

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
