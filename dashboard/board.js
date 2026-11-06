// Pure helpers for the ngvu-factory dashboard; loaded by index.html and by node tests.
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.KFBoard = factory();
})(typeof self !== 'undefined' ? self : this, function () {
  const LENSES = [
    ['securityTenancy', 'security-tenancy'],
    ['codeConventions', 'code-conventions'],
    ['contractIntegration', 'contract-integration'],
    ['dataPersistence', 'data-persistence'],
    ['frontendUi', 'frontend-ui'],
  ];
  const STAGES = {
    intake: 'Intake', spec: 'Spec', build: 'Build', review: 'Review', approve: 'Approve',
    'needs-human': 'Needs human', 'ready-for-pr': 'Ready for PR',
    verified: 'Verified', closed: 'Closed',
  };

  function listEntries(html) {
    const out = [];
    const re = /href="([^"]+)"/g;
    let m;
    while ((m = re.exec(html)) !== null) {
      const h = decodeURIComponent(m[1]);
      if (h.startsWith('?') || h.startsWith('/') || h.startsWith('..') || h.includes('://')) continue;
      out.push(h);
    }
    return out;
  }

  function chipClass(v) {
    if (v === 'PASS') return 'pass';
    if (v === 'CHANGES') return 'changes';
    return 'pending';
  }

  function byKey(a, b) { return a.key < b.key ? -1 : a.key > b.key ? 1 : 0; }

  function groupByEpic(epics, tickets) {
    const known = new Set(epics.map(e => e.key));
    const groups = epics.map(e => ({ epic: e, tickets: tickets.filter(t => t.epic === e.key).sort(byKey) }));
    const rest = tickets.filter(t => !t.epic || !known.has(t.epic)).sort(byKey);
    if (rest.length) groups.push({ epic: null, tickets: rest });
    return groups;
  }

  function stageLabel(stage) { return STAGES[stage] || stage; }

  return { LENSES, listEntries, chipClass, groupByEpic, stageLabel };
});
