# FireCongress.us

Non-partisan civic accountability reporting. Documenting members of Congress — from both parties — who demonstrate conflicts of interest, corporate capture, or failure to represent their constituents. Every report is sourced. The site maintains a strict 50/50 Democrat/Republican balance.

---

## How the System Works

There are two machines involved:

**Raspberry Pi 5 (gateway-host, /home/jinx)** — runs the agents on a cron schedule. Generates content, opens GitHub PRs, posts fact-check comments.

**Vercel** — hosts the static site. Automatically rebuilds and deploys whenever a commit is pushed to the `master` branch of this repo.

The human (you) sits in the middle: review the PR, make any edits, merge. Merging triggers a deploy.

```
Pi cron
  → content agent runs (Claude Code CLI)
    → researches a member of Congress
    → writes a blog post + social copy
    → opens a GitHub PR on a draft/ branch
  → fact-check agent runs 2 hours later
    → fetches each source URL
    → verifies specific claims
    → posts a structured ✅/⚠️/❌ report as a PR comment

You
  → review the PR in GitHub (or VS Code with GitHub PR extension)
  → read the fact-check comment
  → make any edits directly to the draft branch
  → merge the PR

Vercel
  → detects push to master
  → builds the Astro site
  → deploys to firecongress.us
```

---

## Repository Structure

```
firecongress-us/
├── src/
│   ├── content/
│   │   └── blog/               # Published blog posts (Markdown)
│   ├── pages/
│   │   ├── index.astro         # Homepage
│   │   ├── blog/
│   │   │   ├── index.astro     # Blog listing page
│   │   │   └── [...slug].astro # Individual post pages
│   │   ├── about.astro
│   │   └── take-action.astro
│   ├── components/
│   │   ├── TenureBar.astro     # Incumbency Watch bar chart
│   │   ├── PostCard.astro
│   │   ├── Header.astro
│   │   └── Footer.astro
│   ├── layouts/
│   │   └── Base.astro
│   ├── styles/
│   │   └── global.css          # Tailwind v4 theme + imports
│   └── content.config.ts       # Astro content collection schema
├── content-agent/
│   ├── agent-prompt.md         # The content research agent's full instructions
│   ├── factcheck-prompt.md     # The fact-check agent's full instructions
│   ├── run-agent.sh            # Shell wrapper that invokes the content agent
│   ├── run-factcheck.sh        # Shell wrapper that invokes the fact-check agent
│   ├── state.json              # Agent state: party balance, covered members, run dates
│   ├── congress-tenure.json    # Top 50 longest-serving members (refreshed each run)
│   └── drafts/                 # Social media copy generated alongside each post
├── .claude/
│   └── settings.json           # Pre-approves tools so agents run without prompts
├── astro.config.mjs
├── package.json
└── README.md
```

---

## The Content Agent

**File:** `content-agent/agent-prompt.md`
**Runner:** `content-agent/run-agent.sh`
**Schedule:** Monday and Thursday at 9am CDT (2pm UTC)

Each run the agent:
1. Reads `content-agent/state.json` to see which party is next and who's already been covered
2. Picks a currently-serving member of Congress from that party with documented donor conflicts or ethics issues — prioritizing people currently in the news
3. Researches them using OpenSecrets, ProPublica, VoteSmart, and news sources
4. Writes a 600–1000 word blog post to `src/content/blog/YYYY-MM-DD-firstname-lastname-state.md`
5. Writes social copy (Twitter/X thread, Bluesky, Facebook, Instagram) to `content-agent/drafts/`
6. Refreshes the top-50 incumbent tenure data in `content-agent/congress-tenure.json`
7. Updates `content-agent/state.json` (flips party, adds name to covered list, increments counts)
8. Creates a `draft/YYYY-MM-DD-firstname-lastname` branch, commits all files, pushes, and opens a PR

Every specific dollar figure, vote, or date in the post must be traceable to a URL the agent actually fetched. Unverifiable claims are omitted and flagged in the PR body.

---

## The Fact-Check Agent

**File:** `content-agent/factcheck-prompt.md`
**Runner:** `content-agent/run-factcheck.sh`
**Schedule:** Monday and Thursday at 11am CDT (4pm UTC) — runs 2 hours after the content agent

Each run the agent:
1. Finds the most recently opened `draft/` PR
2. Reads the blog post from the draft branch
3. Fetches every source URL listed in the frontmatter and records whether each loaded successfully
4. Cross-references each specific claim (dollar amounts, vote dates, percentages) against the fetched sources
5. Uses web search to independently verify any claim it can't confirm from the provided sources
6. Posts a structured comment to the PR with a source table (✅/⚠️/❌) and claim-by-claim verification
7. Ends with an overall recommendation: Ready to merge / Merge with caution / Needs revision

The fact-check agent never edits files, creates commits, or touches branches — it only posts a comment.

---

## Blog Post Format

Posts are Markdown files in `src/content/blog/` with this frontmatter:

```yaml
---
title: "Rep./Sen. Full Name (D/R-ST): [specific documented issue]"
date: YYYY-MM-DD
party: D   # or R
state: ST  # 2-letter abbreviation
chamber: House  # or Senate
tags: [tag1, tag2, tag3]
sources:
  - url: https://...
    label: OpenSecrets — [Name] campaign finance profile
  - url: https://...
    label: [Source] — [description]
summary: "One sentence, under 200 characters."
---
```

`party`, `state`, and `chamber` drive the site's accountability balance meter and filtering.

---

## Agent State

`content-agent/state.json` tracks the agent's running state:

```json
{
  "next_party": "R",
  "covered": ["Cory Mills", "Henry Cuellar", "Tommy Tuberville", "Richard Neal"],
  "last_run": "2026-05-28",
  "total_dem": 2,
  "total_rep": 2
}
```

The agent alternates parties every run to maintain the 50/50 balance. `covered` prevents the same person from being profiled twice.

---

## Incumbency Watch

`content-agent/congress-tenure.json` stores the top 50 longest-serving current members of Congress. The content agent refreshes this data on every run. The site renders it as a horizontal bar chart on the homepage and blog listing page — bars colored blue (D) or red (R), sorted by years in office.

`years` is computed at build time from the `since` field so the chart stays accurate on every Vercel deploy without requiring a file change.

---

## Stack

- **[Astro 6](https://astro.build)** — static site generator with Content Layer API (glob loader)
- **[Tailwind CSS v4](https://tailwindcss.com)** — uses `@theme {}` in CSS, no `tailwind.config.js`
- **[Vercel](https://vercel.com)** — hosting, auto-deploys on push to `master`
- **[Claude Code CLI](https://claude.ai/code)** — headless agent runner (`claude --print < prompt.md`)
- **[GitHub CLI](https://cli.github.com)** — PR creation and fact-check comments (`gh pr create`, `gh pr comment`)

---

## Commands

| Command           | Action                                     |
| :---------------- | :----------------------------------------- |
| `npm install`     | Install dependencies                       |
| `npm run dev`     | Start local dev server at localhost:4321   |
| `npm run build`   | Build production site to ./dist/           |
| `npm run preview` | Preview the production build locally       |

---

## Rebuild Guide

Everything below is what you'd need to reconstruct this system from scratch — for example if you're setting up a new Pi or migrating to a new machine.

### Prerequisites

Install these on the Pi:

```bash
# Node.js (v18+)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# GitHub CLI
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
   | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
   | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update && sudo apt install gh -y

# Claude Code CLI
npm install -g @anthropic-ai/claude-code
```

### Authentication

```bash
# GitHub — authenticate and authorize
gh auth login
# Choose: GitHub.com → HTTPS → authenticate via browser

# Claude Code — log in with your Anthropic account
claude
# Follow the login prompts the first time
```

### Clone the Repo

```bash
cd /home/jinx
git clone https://github.com/jinx-jinxman/firecongress-us.git
cd firecongress-us
npm install
```

### Git Config

```bash
git config user.name "Jinx"
git config user.email "jinxjinxman4@gmail.com"
```

### Make Scripts Executable

```bash
chmod +x /home/jinx/firecongress-us/content-agent/run-agent.sh
chmod +x /home/jinx/firecongress-us/content-agent/run-factcheck.sh
```

### Set Up the Log Directory

```bash
mkdir -p /home/jinx/firecongress-content/logs
```

### Set Up Cron Jobs

```bash
(crontab -l 2>/dev/null; echo "0 14 * * 1,4 /home/jinx/firecongress-us/content-agent/run-agent.sh") | crontab -
(crontab -l 2>/dev/null; echo "0 16 * * 1,4 /home/jinx/firecongress-us/content-agent/run-factcheck.sh") | crontab -
```

This schedules:
- Content agent: **Monday and Thursday at 9am CDT** (2pm UTC)
- Fact-check agent: **Monday and Thursday at 11am CDT** (4pm UTC)

Verify with `crontab -l`.

### Vercel

The Vercel project is connected to the `jinx-jinxman/firecongress-us` GitHub repo. It automatically deploys when commits land on `master`. No configuration needed on a new Pi — Vercel is cloud-side and independent of the Pi.

If setting up Vercel from scratch:
1. Go to vercel.com, import the GitHub repo
2. Framework preset: Astro
3. Production branch: `master`
4. No environment variables needed

### Test the Agents

Run manually to confirm everything works:

```bash
# Content agent
/home/jinx/firecongress-us/content-agent/run-agent.sh

# Tail the log
tail -f /home/jinx/firecongress-content/logs/*.log

# Fact-check agent (run after content agent creates a PR)
/home/jinx/firecongress-us/content-agent/run-factcheck.sh
tail -f /home/jinx/firecongress-content/logs/factcheck-*.log
```

---

## Review Workflow

1. Content agent opens a PR on a `draft/YYYY-MM-DD-name` branch
2. Fact-check agent posts a comment with source verification and claim analysis
3. Open the PR in VS Code using the **GitHub Pull Requests** extension (with **Remote - SSH** to connect to the Pi)
4. Read the fact-check comment in the PR sidebar, edit the `.md` file directly if needed
5. Merge the PR — Vercel deploys automatically within ~1 minute

Contact: support@firecongress.us
