# Idea: State-Level Coverage Expansion

## The Concept

Extend FireCongress.us to cover state legislators, not just federal. Each state gets its own section at `firecongress.us/<state>` (e.g. `/ca`, `/tx`). Same model: sourced accountability reporting, 50/50 D/R balance, agent-generated drafts, human review before publish.

## Feasibility

### What Works
- Same agent architecture — same prompt structure, PR workflow, fact-check agent
- **FollowTheMoney.org** (National Institute on Money in Politics) is the state-level equivalent of OpenSecrets — covers campaign finance for all 50 states
- **LegiScan.com** has voting records for all 50 state legislatures
- The `state` field already exists on every post — URL routing in Astro is straightforward

### Where It Gets Harder
- Data quality is uneven by state. CA, TX, NY, FL, IL, PA, OH, GA have rich records and active investigative journalism. Smaller/rural states have much thinner coverage, fewer investigative pieces, and less transparent ethics reporting — the agent will struggle to find well-sourced material
- Local newspapers are largely hollowed out — the "news sources" leg of research is much weaker at state level than federal
- The 50/50 D/R balance rule gets complicated in single-party-dominant states (e.g. MA, WY) — equal coverage means covering minor figures on the minority side
- This is 50x the volume of content to generate and review — a genuinely larger editorial operation

## Recommended Path

Don't launch all 50 states at once. Start with 8–10 high-data states, prove the model, then expand:

**Phase 1 states:** CA, TX, NY, FL, IL, PA, OH, GA

These have strong campaign finance records, active state-level investigative journalism, and competitive two-party politics — best conditions for the agent to produce quality sourced content.

## Technical Approach

### URL Structure
`firecongress.us/[state]/` — dynamic Astro route (`src/pages/[state]/index.astro`)

Each state page shows posts filtered to that state, with the same post card layout as the blog listing. The existing `state` field on posts drives filtering with no schema changes needed.

### Agent Changes
- Add a `state_agent/state.json` tracking covered state legislators per state
- The research prompt is nearly identical to the federal one — swap OpenSecrets for FollowTheMoney.org, swap ProPublica Congress for LegiScan, keep the same structure and quality rules
- Posts saved to `src/content/blog/` with existing schema — state chamber names can be noted in the title

### Site Changes
- `src/pages/[state]/index.astro` — state landing page with filtered posts
- Navigation or homepage map links to populated state pages
- The US map feature (see `us-map.md`) becomes much more compelling here — clicking a state on the map goes to its state page, which makes the map genuinely useful

## Status

Parked. Federal coverage comes first. Revisit when:
- Federal post count is substantial (30+ posts)
- The US map feature is built and working
- There's appetite for the significantly larger review workload
