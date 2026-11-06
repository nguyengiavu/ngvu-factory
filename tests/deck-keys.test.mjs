// Keyboard behaviour of the dark-cyan slide deck (deck-theme-v1): menu hotkeys and Up/Down selection inside the menu.
// Runs the deck's own <script> in a minimal fake DOM. DECK=<path> tests another deck (e.g. the template).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';

const deckPath = process.env.DECK || fileURLToPath(new URL('../presentation/index.html', import.meta.url));

function classList() {
  const s = new Set();
  return {
    add: c => s.add(c), remove: c => s.delete(c), contains: c => s.has(c),
    toggle: (c, on) => { const v = on === undefined ? !s.has(c) : on; v ? s.add(c) : s.delete(c); return v; },
  };
}

function el(extra = {}) {
  return { classList: classList(), style: {}, dataset: {}, textContent: '', focus() {}, scrollIntoView() {}, ...extra };
}

function loadDeck() {
  const html = readFileSync(deckPath, 'utf8');
  const titles = [...html.matchAll(/<section class="slide[^"]*" data-title="([^"]*)"/g)].map(m => m[1]);
  // The tests move up to index 4; pad short decks (the template has two slides) with fake slides.
  while (titles.length < 5) titles.push('Extra ' + (titles.length + 1));
  const script =[...html.matchAll(/<script>([\s\S]*?)<\/script>/g)].map(m => m[1]).join('\n');
  const slides = titles.map(t => el({ dataset: { title: t } }));
  let tocButtons = [];
  const toc = el({ querySelectorAll: () => tocButtons });
  // defineProperty, not an object-literal setter: spreading in el() would drop the setter.
  Object.defineProperty(toc, 'innerHTML', {
    set(v) {
      tocButtons = [...v.matchAll(/<button[^>]*data-jump="(\d+)"[^>]*>/g)].map(m => {
        const b = el({ dataset: { jump: m[1] } });
        b.focus = () => { doc.activeElement = b; };
        return b;
      });
    },
  });
  const nodes = { '#toc': toc, '.bar': el(), '#counter': el(), '#next': el(), '#prev': el(), '#tocBtn': el() };
  const doc = {
    activeElement: null,
    querySelectorAll: sel => (sel === '.slide' ? slides : []),
    querySelector: sel => nodes[sel] || el(),
    getElementById: id => nodes['#' + id] || el(),
    addEventListener: (type, fn) => { if (type === 'keydown') win.onkeydown = fn; },
  };
  const loc = { hash: '' };
  const win = { onkeydown: null, onhashchange: null };
  const ctx = {
    document: doc, window: win, location: loc,
    history: { replaceState: (a, b, h) => { loc.hash = h; } },
    console,
  };
  vm.createContext(ctx);
  vm.runInContext(script, ctx);
  const key = (k, mods = {}) => {
    const e = { key: k, preventDefault() { this.prevented = true; }, ctrlKey: false, altKey: false, metaKey: false, ...mods };
    win.onkeydown(e);
    return e;
  };
  const active = () => slides.findIndex(s => s.classList.contains('active'));
  const tocOpen = () => toc.classList.contains('open');
  const selected = () => tocButtons.findIndex(b => b.classList.contains('sel'));
  return { key, active, tocOpen, selected, slides, nodes };
}

test('arrow keys move between slides while the menu is closed', () => {
  const d = loadDeck();
  assert.equal(d.active(), 0);
  d.key('ArrowRight'); assert.equal(d.active(), 1);
  d.key('ArrowLeft'); assert.equal(d.active(), 0);
});

test('M opens the menu with the current slide selected; T does too', () => {
  const d = loadDeck();
  d.key('ArrowRight'); d.key('ArrowRight');
  d.key('m');
  assert.ok(d.tocOpen(), 'menu open after M');
  assert.equal(d.selected(), 2, 'current slide is selected');
  d.key('Escape'); assert.ok(!d.tocOpen(), 'Esc closes');
  d.key('T'); assert.ok(d.tocOpen(), 'menu open after T');
});

test('Up/Down move the selection inside the open menu without changing the slide', () => {
  const d = loadDeck();
  d.key('M');
  d.key('ArrowDown'); d.key('ArrowDown');
  assert.equal(d.selected(), 2);
  assert.equal(d.active(), 0, 'slide unchanged while choosing');
  d.key('ArrowUp');
  assert.equal(d.selected(), 1);
  d.key('ArrowUp'); d.key('ArrowUp');
  assert.equal(d.selected(), 0, 'stops at the first entry');
  d.key('End'); assert.equal(d.selected(), d.slides.length - 1, 'End selects the last entry');
  d.key('ArrowDown'); assert.equal(d.selected(), d.slides.length - 1, 'stops at the last entry');
});

test('Enter opens the selected slide and closes the menu', () => {
  const d = loadDeck();
  d.key('m'); d.key('ArrowDown'); d.key('ArrowDown'); d.key('ArrowDown');
  const e = d.key('Enter');
  assert.equal(d.active(), 3);
  assert.ok(!d.tocOpen());
  assert.ok(e.prevented, 'Enter does not also click the focused button');
});

test('menu keys are ignored with Ctrl/Alt/Meta so browser shortcuts still work', () => {
  const d = loadDeck();
  d.key('m', { ctrlKey: true });
  assert.ok(!d.tocOpen());
});

test('the menu button advertises its hotkey', () => {
  const html = readFileSync(deckPath, 'utf8');
  assert.match(html, /id="tocBtn"[^>]*>Menu \(M\)</);
});
