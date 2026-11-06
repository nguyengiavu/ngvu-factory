# Design system for the presentation page

Applies to `diagrams/presentation.html` and, when it exists, its English translation `diagrams/presentation.en.html`
(same CSS, script, coordinates; only the text differs; translation rules in SKILL.md Step 7). It follows a technical sequence
diagram in "flight recorder" style: one colour per system, dashed lifelines, single-colour arrows
by *meaning* (black=request, colour=response, red=error), monospace labels, root-cause/findings
callout blocks with a coloured border. The page keeps that colour language exactly and adds a
real "web app" frame: app-bar + tabs, each tab a separate "slide".

**Do not change this design direction on your own.** If the user criticises the presentation, read
the reference file they point to (if any) again before editing; do not guess what "nicer" means.

---

## 1. Palette: categorical (identity) separate from semantic (meaning)

This is the most important design decision, and the easiest to get wrong in a hurry:

| Kind | Used for | Example |
|---|---|---|
| **Categorical** | "WHICH system/repo is this": fixed for one repo across every table/diagram/badge on the WHOLE page | `--repo-store` (blue) is always `example_core`, never changes with context |
| **Semantic** | "What does this result MEAN": allowed / warning / blocked | `--ok` (green), `--warn` (orange), `--block` (red) |

The two channels **must not be mixed**. An arrow coloured red in a sequence diagram
means "the result is BLOCKED" (semantic), **not** "this is a request of the red repo"
(categorical), even though `example_payment` is also assigned red as its categorical colour. It is fine
if the two hex values are the same (they are in the example below: both `--repo-pay` and `--block` are
red), as long as the contexts do not overlap (repo identity badges in tables/legends,
semantic colours only on arrows/pills that show a result).

### Example tokens (4 repos + customer)

```css
--accent / --accent-ink / --accent-soft     /* app chrome: nav, focus, links; NOT the same as any repo */
--ok / --ok-soft         /* green  — allowed / success */
--warn / --warn-soft     /* orange — warning / medium */
--block / --block-soft   /* red    — blocked / error / high risk */

--repo-store / --repo-store-soft   /* blue   — example_core, source of truth */
--repo-pay   / --repo-pay-soft     /* red    — example_payment, cross-team */
--repo-comp  / --repo-comp-soft    /* green  — example_ui_lib, shared UI components */
--repo-web   / --repo-web-soft     /* teal   — example_web, UI */
--repo-ext   / --repo-ext-soft     /* orange — a payment provider, third party */
--repo-actor / --repo-actor-soft   /* grey   — customer (not a system) */
```

Each `fg`/`fg-soft` pair is an Open-Color-style pair (dark text on a light background of the same hue) that
already meets AA contrast; no need to check contrast each time you use it.

### Assigning a new categorical colour for another ticket

Another ticket will touch other repos. Process:

1. List the repos/systems touched (usually 2–5).
2. Give each repo **one** hue pair of its own; prefer reusing an existing meaning when it fits
   (for example: a repo owned by an outside team / on the critical path → consider red, as the example
   uses red for `example_payment`/another team; red there has a deliberate double meaning:
   identity and a hint of "schedule risk").
3. Define `--repo-<name>` / `--repo-<name>-soft` in **all 3 token blocks** (`:root`,
   the `@media dark` guard, `:root[data-theme="dark"]`); missing one block breaks the theme.
4. Write the dark values by "raising the lightness, darkening the background" (see the lookup table
   below); do not invent them, a small error loses contrast.
5. Add the CSS class `.seq .lane-<name> .lane-box{...}` following the existing 3-line pattern (see the
   CSS block `HAND-DRAWN SEQUENCE DIAGRAMS` in the template file).
6. Add `.repobadge.r-<name>{...}` if you need an HTML badge (table, legend) outside the SVG.

### Light → dark lookup table used (reference when adding a new hue)

| Light fg | Dark fg | Light soft-bg | Dark soft-bg |
|---|---|---|---|
| `#1971c2` blue | `#7cc4fa` | `#e7f5ff` | `#0f2338` |
| `#c92a2a` red | `#ffa8a8` | `#ffe3e3` | `#331515` |
| `#2b8a3e` green | `#7ee2a8` | `#d3f9d8` | `#0f2b1a` |
| `#0c8599` teal | `#66d9e8` | `#c5f6fa` | `#0a2a2e` |
| `#d9480f` orange | `#ffb366` | `#ffe8cc` | `#33210c` |
| `#3b5bdb` indigo (accent) | `#8fa2f5` | `#edf0ff` | `#1a2242` |

General rule: dark fg ≈ light fg mixed strongly with white (raise lightness, keep hue); dark soft-bg
≈ near black, lightly tinted with that hue (do not use a neutral grey for soft-bg, it loses the sense of
"the same hue" across the 2 themes).

---

## 2. Type

`IBM Plex Sans` (body) / `IBM Plex Serif` (headings `h1`/`h2.sec`/large figures) /
`IBM Plex Mono` (everything technical: arrow labels in SVG, field/API names, tab labels
like `01`, repo badges). Three separate roles; do not use sans where mono belongs
(for example function names, REST paths), because mono is the visual signal "this is technical, exact
to the character".

---

## 3. "Web app" layout: app-bar + tabs, one "slide" per tab

The user asked explicitly: *"more professional... like a web page, tabs, slides... more separated"*.
The structure answers exactly those 3 points:

- **App-bar** sticky at the top of the page: ticket key, title, status chips (epic %, number of repos).
- **Tab bar** sticky right below the app-bar: 8 standard tabs (see the comment at the top of `templates/diagrams/presentation.html`), accent underline when
  active, navigable with the arrow keys (ARIA tabs pattern).
- **Each tab = one panel** (`role="tabpanel"`, hidden with the `hidden` attribute, **not** a hand-written
  `display:none`, matching the rule "toggle visibility with `el.hidden`"). The first panel
  (Overview) **is always rich enough to stand alone**: it is what appears when
  the page is captured as a thumbnail or a link is shared, before anyone clicks a tab.

**Why tabs, not one long scroll:** an 8-part report in one continuous scroll reads like a document;
split into tabs it reads like a tool/dashboard, in the spirit of "scanned and operated,
not read top-to-bottom" that artifact-design recommends for this kind of content, and as the user
explicitly asked.

**Theme toggle (required).** Following the host's theme is right, but when presenting
the user needs to switch it **actively**, and needs to *see* that the page supports two themes. The template
already has a sun/moon button in the app-bar:

- read the current theme from `data-theme` (if the host has set it) or `prefers-color-scheme`;
- click → set the opposite `data-theme` + save it in `localStorage` (wrapped in try/catch; it must still work
  when the browser blocks storage);
- **hand-drawn SVG changes colour at once** because every colour is a `var(--token)`;
- **Mermaid does not**: it bakes colours into the SVG at render time. So `renderPanelDiagrams(panel, force)`
  stores the original source in `data-src` **before** the first render, and when the theme changes it calls
  `initMermaid()` again + re-renders the open panel with `force = true`. Without the `data-src` step it
  cannot rebuild, because `textContent` has already been replaced by the SVG.

**The tab bar must WRAP, never scroll horizontally.** `.tabbar-inner` uses `flex-wrap:wrap`, and
`.tabbar` has **no** `overflow-x:auto`.

This lesson was paid for twice. At first the tab bar scrolled horizontally; as the number of tabs grew, the last tabs
were hidden **with no visible sign** that more tabs followed. The first "fix" shortened
the labels to fit 1440px; wrong at the root, because:

- **An Artifact renders in a panel narrower than the browser window** (measured ~1000px). Measuring at 1440px and
  concluding "it fits the screen" measures the wrong place.
- Shortening labels only pushes the breaking point a little further; it does not remove the bug.

With `flex-wrap`, measured: 560px → 3 rows · 885px → 2 rows · 1085px → 2 rows · 1385px → 1 row.
**Every tab is always visible at every width**, there is no breaking point left. So there is also no hard
limit on the number of tabs, but keep ~8–9, because too many tabs is a sign the content needs grouping.

Along with that: remove `margin-bottom:-1px` on `.tab`. That trick only works when the tab bar has one row; when it wraps,
it makes the underline of the upper row overlap the lower row.

**Mermaid is lazy-loaded:** the library is only fetched + rendered when the user clicks the first tab
that contains a Mermaid diagram; the Overview panel needs no Mermaid, so the page opens
without loading any library. This also avoids a real bug: rendering Mermaid while the
panel is `hidden` (`display:none`) can give the wrong size, because Mermaid's bounding-box
measurement needs real layout.

---

## 4. Hand-drawn sequence diagrams: when to use them instead of Mermaid

**Use Mermaid** for: flowcharts (epic architecture, decision tree), gantt, state machines:
things Mermaid's auto-layout handles well, where hand-coding is wasted effort.

**Draw SVG yourself** for: sequence diagrams that must follow the page's visual language (lanes by
categorical colour, arrows by semantic colour); Mermaid's default sequence diagram
cannot do this, because it colours by actor in a generic way and cannot tell
"request" from "blocked result" by colour.

### Coordinate rules (used for all 3 SVGs of the example)

```
Lane header:  x = cx - 95, y = 26, width = 190, height = 54, rx = 8
              name at (cx, 49), subtitle at (cx, 65)
cx spacing:   >= 230  (room for 2 boxes side by side + a gap for arrows/labels)
Lifeline:     x = cx, y1 = 84 (right below the box), y2 = y of last row + 32
Row pitch:    a steady 44px; first row at y=108, next +44, +44, ...
Arrow label:  8px ABOVE the line, x = min(srcCx, dstCx) + 8
Note "over":  rect 300–360 wide, centred on that lane's cx, 30 high, corner radius 6
```

Aligning to the 44px grid is why the hand drawing looks "intentional" instead of messy, following
the "Align to a grid" principle of `artifact-diagramming`.

### Arrow colour rules: by MEANING, not by source/target lane

```
class="arrow-req"      black, solid   → a call/request
class="arrow-neutral"  grey,  dashed  → returned data, no verdict yet
class="arrow-ok"       green, dashed  → result ALLOWED / success
class="arrow-block"    red,   dashed  → result BLOCKED / error
```

Each kind has its own arrowhead marker (`.arrow-*-head`); the marker rotates with the drawing direction
(`orient="auto"`), so it works for both left→right and right→left.

### Merging two outcomes into ONE diagram (band)

When a request has several outcomes (allowed / blocked), two separate diagrams make the reader join them
in their head. One figure is much easier to explain; this was direct user feedback
when presenting to the PO.

How: the shared steps are drawn on a white background, then each outcome branch sits in a **band**:
a strip with a semantic background colour, a dashed border, and a label that states the branch's **condition**:

```html
<g class="band band-block"><rect x="14" y="304" width="924" height="148" rx="10"/>
  <text class="band-label" x="28" y="322">BRANCH A — registeredAt &lt; deactivatedAt ⇒ BLOCKED</text></g>
<g class="band band-ok">…</g>
```

- Declare the band **before** the lifelines and lane boxes in document order; SVG draws in order, so a band declared
  later covers the lifelines.
- The band label states the **condition**, not a generic branch name. "BRANCH A" alone says nothing;
  "BRANCH A — registeredAt < deactivatedAt" is something a PO understands on reading.
- Number the steps **per branch** (branch A: 5,6 · branch B: 6,7 …). The same number in two branches is
  normal in an alt block; the band label sets the context. Say so in the figcaption.
- Band height = number of rows inside × 44 + ~40 for the label and margins.

### Technical trap when copying several SVGs into one page

**`<marker>` ids must be unique across the whole page**, not only within one `<svg>`. When
the page has N sequence diagrams, each declares its own `<defs>`; give each diagram a different suffix
(`arrowReqA`, `arrowReqB`, …). Mixed ids make `url(#id)` of
one diagram point by accident to a marker of another diagram (the DOM shares one id namespace
for the whole HTML document, even when the SVGs sit in different panels).

### A lane that groups several repos (when one box = several repos running in 1 process)

If two repos compile into one runtime (like the `example_web` UI using the library
`example_ui_lib`), do not draw them as two sequential network calls; that misreads the
architecture. Use the class `.lane-multi` (accent border, not coloured by any repo's hue) and put 2
small coloured-dot badges inside (`.badge-web-dot`/`.badge-comp-dot`, see the example in
`diagrams/presentation.html`, Figure 1), so each repo's identity is still stated without inventing a network hop
that does not exist.

---

## 5. Checks before publishing (taken from real work)

- [ ] Open the local file with `mcp__Claude_Browser__navigate` on `file:///...`, then use
      `javascript_tool` to read `getComputedStyle`; **do not only trust screenshots**.
      A file outside the project folder is treated by the pane as a "static snapshot": screenshots do not
      update correctly with interaction (click/scroll) even when the DOM has really changed. A JS check is always
      more reliable than a screenshot for this kind of file.
- [ ] Count `svg.seq` and `pre.mermaid` against the expected number; check `body.scrollWidth <=
      document.documentElement.clientWidth` (no horizontal overflow).
- [ ] Set `document.documentElement.setAttribute('data-theme','dark')`, then read
      `getComputedStyle` of a categorical element again (for example `.lane-store .lane-box`) to
      confirm it switched to the dark value and did not stay at the light value.
- [ ] Only when `reportLanguage` is not `en`, the en version (`presentation.en.html`): same number of tabs, `svg.seq`,
      `pre.mermaid` as `presentation.html`; no accented letters left in the text the reader sees: check with
      `/[\u00C0-\u024F\u1E00-\u1EFF]/` on `document.body.innerText` (ignore quotes of original data, if any);
      click `#themeToggle` and see the labels `Light`/`Dark`; SVG arrow labels do not run past a lifeline (`getBBox()` of each `text.lbl`).
- [ ] Publish with `Artifact` (the real way to view it online); do not insist on getting a screenshot of
      the local file; it is not worth another login round for the user
      just so you can look at it yourself.
