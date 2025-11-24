# Playwright Browser Debugging Design

**Date:** 2025-11-23
**Status:** Approved

## Overview

Add browser debugging capability to `skills/debugging/SKILL.md` using Playwright for headless browser testing and debugging. Captures screenshots, console logs, and HTML snapshots to help debug JavaScript errors, visual issues, and Hotwire/Turbo/Stimulus behavior problems.

## Key Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Installation method | `npx playwright` | Zero-config, always up-to-date, no project pollution |
| Artifacts captured | Screenshots + console logs + HTML | Covers visual issues and JS errors without excessive storage |
| Invocation style | Bash commands with inline Node scripts | Simple, transparent, no project scaffolding needed |
| Server management | Assume already running | Avoids complexity of lifecycle management |
| Artifact organization | Timestamped folders | Preserves history for comparison |

## Artifact Storage

```
tmp/
└── playwright/
    ├── 2025-11-23_143052/
    │   ├── screenshot.png
    │   ├── console.log
    │   └── page.html
    └── 2025-11-23_143215/
        ├── screenshot.png
        ├── console.log
        └── page.html
```

- Timestamp format: `YYYY-MM-DD_HHMMSS`
- Cleanup: User responsibility (`rm -rf tmp/playwright/*`)
- Already gitignored: `tmp/` is gitignored by default in Rails

## Playwright Commands

### One-time Setup

```bash
npx playwright install chromium
```

### Basic Capture (screenshot + console + HTML)

```bash
SESSION="tmp/playwright/$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$SESSION"
node -e "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const logs = [];
  page.on('console', msg => logs.push(msg.text()));
  await page.goto('http://localhost:3000/users');
  await page.screenshot({ path: '$SESSION/screenshot.png', fullPage: true });
  require('fs').writeFileSync('$SESSION/console.log', logs.join('\n'));
  require('fs').writeFileSync('$SESSION/page.html', await page.content());
  await browser.close();
})();
"
```

### Capture with Interactions

```bash
SESSION="tmp/playwright/$(date +%Y-%m-%d_%H%M%S)"
mkdir -p "$SESSION"
node -e "
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  const logs = [];
  page.on('console', msg => logs.push(msg.text()));
  await page.goto('http://localhost:3000/login');
  await page.fill('input[name=\"email\"]', 'test@example.com');
  await page.fill('input[name=\"password\"]', 'password');
  await page.click('button[type=\"submit\"]');
  await page.waitForURL('**/dashboard');
  await page.screenshot({ path: '$SESSION/screenshot.png', fullPage: true });
  require('fs').writeFileSync('$SESSION/console.log', logs.join('\n'));
  require('fs').writeFileSync('$SESSION/page.html', await page.content());
  await browser.close();
})();
"
```

## Workflows

### Workflow A: System Test Failure Debugging

1. Agent identifies failing test and URL/route being tested
2. Runs Playwright script against that route
3. Captures screenshot, console logs, HTML
4. Analyzes artifacts for JavaScript errors, missing elements, visual issues
5. Reports findings with artifact paths for human review

### Workflow B: Ad-hoc Browser Debugging

1. Agent asks for or infers URL from developer description
2. Optionally performs interactions (click, fill, wait)
3. Captures artifacts at relevant points
4. Analyzes console errors, DOM state, visual output
5. Reports findings and suggests fixes

## Skill Changes

### Add `<phase-browser-debugging>` section

New section with 3 tools:
- `browser-capture` — Basic capture for a URL
- `browser-interact` — Capture with form fills, clicks, waits
- `browser-install` — One-time Playwright setup

### Update `<verification-checklist>`

Add:
- ✅ JavaScript console errors checked (if UI issue)
- ✅ Screenshots reviewed for visual regressions

### Update `<related-skills>`

Add: `rails-ai:hotwire` (Turbo/Stimulus debugging)

### Update `<resources>`

Add:
- [Playwright Documentation](https://playwright.dev/docs/intro)
- [Playwright CLI Reference](https://playwright.dev/docs/test-cli)

## Out of Scope

- Video recording (storage overhead)
- Network HAR files (can add later if needed)
- Server lifecycle management
- Ruby gem wrappers
- Permanent project scaffolding

## Implementation

Single file change: `skills/debugging/SKILL.md`

No test changes needed (content update, not structure change).
