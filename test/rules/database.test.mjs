import { before, after, beforeEach, test } from 'node:test';
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { ref, set, get, update, query, orderByChild, equalTo, runTransaction } from 'firebase/database';

let env;
before(async () => {
  env = await initializeTestEnvironment({projectId: 'demo-sampts', database: {
    host: '127.0.0.1', port: 9000, rules: readFileSync('database.rules.json', 'utf8'),
  }});
});
after(async () => { await env?.cleanup(); });
beforeEach(async () => {
  await env.clearDatabase();
  await env.withSecurityRulesDisabled(async ctx => {
    await set(ref(ctx.database()), {
      users: {s1: {name: 'Student', email: 's1@example.com', role: 'student'},
        a1: {name: 'Advisor', email: 'a1@example.com', role: 'advisor'}},
      students: {s1: {userId: 's1', studentNumber: '123', advisorId: 'a1'}},
      meetings: {m1: {studentId: 's1', advisorId: 'a1', scheduledAt: 1800000000000,
        durationMinutes: 30, status: 'pending', notes: ''}},
    });
  });
});
const db = uid => env.authenticatedContext(uid).database();
test('Anonymous users cannot access profiles', async () => {
  await assertFails(get(ref(env.unauthenticatedContext().database(), 'users/s1')));
});
test('A new user can create a student profile but cannot self-assign advisor', async () => {
  const profile = ref(db('s2'), 'users/s2');
  await assertSucceeds(runTransaction(profile, value => value ?? {name: 'New', email: 'new@example.com', role: 'student'}));
  await assertFails(update(profile, {role: 'advisor'}));
  await assertSucceeds(update(profile, {name: 'Updated'}));
});
test('Students cannot change their advisor assignment', async () => {
  await assertFails(update(ref(db('s1'), 'students/s1'), {advisorId: 'a2'}));
});
test('Meeting participants can read, unrelated users cannot', async () => {
  await assertSucceeds(get(ref(db('s1'), 'meetings/m1')));
  await assertSucceeds(get(ref(db('a1'), 'meetings/m1')));
  await assertFails(get(ref(db('s2'), 'meetings/m1')));
  await assertFails(get(ref(db('s1'), 'meetings')));
  await assertSucceeds(get(query(ref(db('s1'), 'meetings'), orderByChild('studentId'), equalTo('s1'))));
});
test('Only the assigned advisor can approve a meeting', async () => {
  await assertFails(update(ref(db('s1'), 'meetings/m1'), {status: 'approved'}));
  await assertSucceeds(update(ref(db('a1'), 'meetings/m1'), {status: 'approved'}));
  await assertFails(update(ref(db('s1'), 'meetings/m1'), {studentId: 's2'}));
});
test('Students request meetings only with their assigned advisor', async () => {
  const meeting = {studentId: 's1', advisorId: 'a1', scheduledAt: 1800000000000,
    durationMinutes: 30, status: 'pending', notes: ''};
  await assertSucceeds(set(ref(db('s1'), 'meetings/m2'), meeting));
  await assertFails(set(ref(db('s1'), 'meetings/m3'), {...meeting, advisorId: 'a2'}));
});
test('Record transactions create once and update an uncached meeting', async () => {
  const database = db('s1');
  const target = ref(database, 'meetings/m2');
  const record = {studentId: 's1', advisorId: 'a1', scheduledAt: 1800000000000,
    durationMinutes: 30, status: 'pending', notes: 'First'};
  const created = await assertSucceeds(runTransaction(target, value => value === null ? record : undefined,
    {applyLocally: false}));
  if (!created.committed) throw new Error('Creation did not commit');
  const duplicate = await runTransaction(target, value => value === null ? {...record, notes: 'Overwrite'} : undefined,
    {applyLocally: false});
  if (duplicate.committed) throw new Error('Duplicate creation overwrote a record');
  const cold = ref(db('s1'), 'meetings/m1');
  const updated = await assertSucceeds(runTransaction(cold, value => value === null ? null : {...value, notes: 'Changed'},
    {applyLocally: false}));
  if (updated.snapshot.val().notes !== 'Changed') throw new Error('Cold transaction did not update');
});
test('Project milestone changes require the assigned advisor', async () => {
  const project = {studentId: 's1', advisorId: 'a1', title: 'SAMPTS', description: '', status: 'proposed'};
  await assertSucceeds(set(ref(db('s1'), 'projects/p1'), project));
  await assertFails(update(ref(db('s1'), 'projects/p1'), {status: 'completed'}));
  await assertSucceeds(update(ref(db('a1'), 'projects/p1'), {status: 'completed'}));
  await assertFails(get(ref(db('s2'), 'projects/p1')));
});
