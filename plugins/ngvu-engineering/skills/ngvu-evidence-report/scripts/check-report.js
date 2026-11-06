#!/usr/bin/env node
/*
 * Static check of a report page before publishing.
 *   node check-report.js <path-to-report.html>
 *
 * Catches the exact errors that ngvu-ticket-investigation/references/visual-style.md warns about:
 * errors that do not show in a light-theme screenshot.
 * Exits with code 1 on any error (ERROR); WARN does not block.
 */
const fs = require('fs');

const file = process.argv[2];
if (!file) { console.error('Usage: node check-report.js <report.html>'); process.exit(2); }
if (!fs.existsSync(file)) { console.error('File not found: ' + file); process.exit(2); }
const html = fs.readFileSync(file, 'utf8');

const errors = [], warns = [], oks = [];
const E = m => errors.push(m), W = m => warns.push(m), OK = m => oks.push(m);

/* ── 1. Tokens must be declared in ALL THREE blocks; a missing block breaks the theme ── */
function tokensIn(re) {
  const m = html.match(re);
  if (!m) return null;
  return new Set((m[1].match(/--[a-z0-9-]+(?=\s*:)/gi) || []).map(s => s.toLowerCase()));
}
const base = tokensIn(/:root\s*\{([\s\S]*?)\}/);
const mediaDark = tokensIn(/@media\s*\(prefers-color-scheme\s*:\s*dark\)\s*\{\s*:root:not\(\[data-theme="light"\]\)\s*\{([\s\S]*?)\}/);
const attrDark = tokensIn(/:root\[data-theme="dark"\]\s*\{([\s\S]*?)\}/);

if (!base) E('No `:root` block declaring tokens found.');
if (!mediaDark) E('Missing block `@media (prefers-color-scheme:dark) :root:not([data-theme="light"])`: users on the "system" theme will see wrong colours.');
if (!attrDark) E('Missing block `:root[data-theme="dark"]`: the theme toggle will have no effect.');

if (base && mediaDark && attrDark) {
  // themed token = token present in at least one dark block
  const themed = new Set([...mediaDark, ...attrDark]);
  const missingInMedia = [...themed].filter(t => !mediaDark.has(t));
  const missingInAttr = [...themed].filter(t => !attrDark.has(t));
  const notInBase = [...themed].filter(t => !base.has(t));

  if (missingInMedia.length) E('Token in `[data-theme="dark"]` but MISSING from the @media block: ' + missingInMedia.join(', '));
  if (missingInAttr.length) E('Token in @media dark but MISSING from `[data-theme="dark"]`: ' + missingInAttr.join(', '));
  if (notInBase.length) E('Token exists only in the dark blocks, NOT in `:root`: this is the classic "white text on a white page" bug: ' + notInBase.join(', '));
  if (!missingInMedia.length && !missingInAttr.length && !notInBase.length)
    OK('Tokens balanced across all 3 blocks (' + themed.size + ' themed tokens).');
}

/* ── 2. Tabs and panels must match ── */
const tabIds = [...html.matchAll(/role="tab"[^>]*aria-controls="([^"]+)"/g)].map(m => m[1]);
const tabIdsAlt = [...html.matchAll(/aria-controls="([^"]+)"[^>]*role="tab"/g)].map(m => m[1]);
const allTabTargets = [...new Set([...tabIds, ...tabIdsAlt])];
const panelIds = [...html.matchAll(/id="([^"]+)"[^>]*role="tabpanel"/g)].map(m => m[1]);

if (allTabTargets.length) {
  const orphanTabs = allTabTargets.filter(id => !panelIds.includes(id));
  const orphanPanels = panelIds.filter(id => !allTabTargets.includes(id));
  if (orphanTabs.length) E('Tab points to a panel that does not exist: ' + orphanTabs.join(', '));
  if (orphanPanels.length) W('Panel with no tab pointing to it (readers cannot open it): ' + orphanPanels.join(', '));
  if (!orphanTabs.length && !orphanPanels.length) OK('Tabs and panels match (' + allTabTargets.length + ' pairs).');

  // exactly one panel visible when the page opens
  const panelTags = [...html.matchAll(/<section[^>]*role="tabpanel"[^>]*>/g)].map(m => m[0]);
  const visible = panelTags.filter(t => !/\shidden(\s|>|=)/.test(t));
  if (visible.length === 0) E('Every panel is `hidden`: the page will open empty.');
  else if (visible.length > 1) E(visible.length + ' panels visible when the page opens; there must be exactly 1.');
  else OK('Exactly 1 panel visible when the page opens.');

  // Count only inside tags with role="tab". Counting the whole page would match the CSS selector
  // `.tab[aria-selected="true"]{...}` and report a false error.
  const tabTags = [...html.matchAll(/<[a-z]+[^>]*\brole="tab"[^>]*>/gi)].map(m => m[0]);
  const selected = tabTags.filter(t => /aria-selected="true"/.test(t)).length;
  if (selected !== 1) E('There must be exactly 1 tab with `aria-selected="true"` (found ' + selected + ' of ' + tabTags.length + ' tabs).');
  else OK('Exactly 1 tab selected by default.');
}

/* ── 3. Tab bar must wrap, not scroll sideways (a lesson paid for twice) ── */
const tabbarCss = (html.match(/\.tabbar\s*\{([^}]*)\}/) || [, ''])[1];
if (/overflow-x\s*:\s*auto|overflow\s*:\s*auto/.test(tabbarCss))
  E('`.tabbar` has overflow-x:auto: the last tabs will be hidden with no sign. Use flex-wrap on .tabbar-inner.');
const tabbarInnerCss = (html.match(/\.tabbar-inner\s*\{([^}]*)\}/) || [, ''])[1];
if (tabbarInnerCss && !/flex-wrap\s*:\s*wrap/.test(tabbarInnerCss))
  E('`.tabbar-inner` is missing `flex-wrap:wrap`.');
else if (tabbarInnerCss) OK('Tab bar wraps correctly (flex-wrap, no sideways scroll).');
if (/\.tab\s*\{[^}]*margin-bottom\s*:\s*-1px/.test(html))
  E('`.tab` has margin-bottom:-1px: when the tab bar wraps, the underline of the top row overlaps the next row.');

/* ── 4. Panels must be hidden with the hidden attribute, not display:none ── */
if (/role="tabpanel"[^>]*style="[^"]*display\s*:\s*none/.test(html))
  E('Panel hidden with inline `display:none`: use the `hidden` attribute.');

/* ── 5. Duplicate SVG marker ids across diagrams ── */
const markerIds = [...html.matchAll(/<marker[^>]+id="([^"]+)"/g)].map(m => m[1]);
const dupMarkers = markerIds.filter((id, i) => markerIds.indexOf(id) !== i);
if (dupMarkers.length) E('Duplicate `<marker>` id in the page: ' + [...new Set(dupMarkers)].join(', ') + '. url(#id) will point to the wrong diagram.');
else if (markerIds.length) OK('SVG marker ids are unique (' + markerIds.length + ').');

/* ── 6. Hard-coded hex outside the token blocks ── */
const tokenBlocks = (html.match(/:root[^{]*\{[\s\S]*?\}/g) || []).join('') +
                    (html.match(/@media[^{]*\{[\s\S]*?\}\s*\}/g) || []).join('');
const allHex = [...html.matchAll(/#[0-9a-f]{3,8}\b/gi)].map(m => m[0]);
const tokenHex = new Set([...tokenBlocks.matchAll(/#[0-9a-f]{3,8}\b/gi)].map(m => m[0].toLowerCase()));
const strayHex = [...new Set(allHex.map(h => h.toLowerCase()).filter(h => !tokenHex.has(h)))];
if (strayHex.length) W('Hex not declared in a token block (' + strayHex.length + '): ' + strayHex.slice(0, 8).join(', ') +
  '. Colours must go through `var(--token)` to follow the theme.');
else OK('All colours go through tokens.');

/* ── 7. Unfilled placeholders ── */
const ph = [...new Set((html.match(/__[^_<>]{2,160}?__/g) || []))];
if (ph.length) W(ph.length + ' unfilled placeholders left (for example: ' + ph.slice(0, 4).join(' · ') + '). Do not publish while any remain.');
else OK('No placeholders left.');

/* ── 8. Required quality blocks ── */
if (!/class="verdict/.test(html)) W('Missing verdict banner: the conclusion must be at the top.');
if (!/class="stats"|class="stat"/.test(html)) W('Missing stat tiles on the overview tab.');
if (!/loglink/.test(html)) W('No evidence link that can be opened.');
if (!/Limits|not proven/i.test(html)) W('No "what is not proven" section found. Do not drop this section.');

/* ── 9. Sensitive data ── */
const uuids = [...new Set(html.match(/\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\b/gi) || [])]
  .filter(u => !/^0{8}-0{4}-0{4}-0{4}-0{12}$/i.test(u));
if (uuids.length) E(uuids.length + ' full UUIDs in the page (real tenant id?). Replace with TENANT_REDACTED, a label ("tenant A") or a fake id before publishing.');
if (/\b(authorization\s*:\s*\S|bearer\s+[a-z0-9._-]{16,}|password\s*[:=]|api[_-]?key\s*[:=])/i.test(html))
  E('Found a string that looks like a token or password: remove it before publishing.');
if (!uuids.length) OK('No full UUIDs exposed.');

/* ── report ── */
const pad = s => s.replace(/\n/g, '\n     ');
console.log('\nChecking: ' + file + '\n');
oks.forEach(m => console.log('  OK    ' + pad(m)));
warns.forEach(m => console.log('  WARN  ' + pad(m)));
errors.forEach(m => console.log('  ERROR ' + pad(m)));
console.log('\n  ' + oks.length + ' passed · ' + warns.length + ' warnings · ' + errors.length + ' errors\n');
process.exit(errors.length ? 1 : 0);
