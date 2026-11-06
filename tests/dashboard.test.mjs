import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const B = require('../dashboard/board.js');

test('listEntries keeps directory names and files, drops parents and queries', () => {
  const html = '<a href="VUNG-000011-example-ready/">x</a><a href="../">up</a><a href="?C=M">s</a>' +
               '<a href="ticket.json">t</a><a href="VUNG%2D000012-x/">y</a><a href="/abs">z</a>';
  assert.deepEqual(B.listEntries(html), ['VUNG-000011-example-ready/', 'ticket.json', 'VUNG-000012-x/']);
});

test('chipClass maps verdicts', () => {
  assert.equal(B.chipClass('PASS'), 'pass');
  assert.equal(B.chipClass('CHANGES'), 'changes');
  assert.equal(B.chipClass('pending'), 'pending');
  assert.equal(B.chipClass(undefined), 'pending');
});

test('groupByEpic puts children under their epic and the rest standalone', () => {
  const epics = [{ key: 'VUNG-10' }];
  const tickets = [{ key: 'VUNG-12', epic: 'VUNG-10' }, { key: 'VUNG-11', epic: 'VUNG-10' },
                   { key: 'VUNG-20', epic: null }, { key: 'VUNG-30', epic: 'VUNG-99' }];
  const g = B.groupByEpic(epics, tickets);
  assert.equal(g.length, 2);
  assert.equal(g[0].epic.key, 'VUNG-10');
  assert.deepEqual(g[0].tickets.map(t => t.key), ['VUNG-11', 'VUNG-12']);
  assert.equal(g[1].epic, null);
  assert.deepEqual(g[1].tickets.map(t => t.key), ['VUNG-20', 'VUNG-30']);
});

test('groupByEpic omits the standalone group when empty', () => {
  assert.equal(B.groupByEpic([{ key: 'VUNG-1' }], [{ key: 'VUNG-2', epic: 'VUNG-1' }]).length, 1);
});

test('LENSES lists the five lenses in order', () => {
  assert.deepEqual(B.LENSES.map(l => l[1]),
    ['security-tenancy', 'code-conventions', 'contract-integration', 'data-persistence', 'frontend-ui']);
});

test('stageLabel is human readable', () => {
  assert.equal(B.stageLabel('needs-human'), 'Needs human');
  assert.equal(B.stageLabel('ready-for-pr'), 'Ready for PR');
});
