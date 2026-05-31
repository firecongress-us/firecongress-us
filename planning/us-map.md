# Idea: Interactive US Map

## The Concept

An interactive US map that lets visitors click a state and see all posts about politicians from that state. A geographic entry point into the content — more personal and intuitive than a chronological list as the post count grows.

## Why We're Waiting

Currently only 4 posts across a handful of states. The map would look sparse and feel incomplete. The feature earns its place once there's meaningful coverage across 10–15+ states. Build it then.

## Placement

- **Blog listing page** first — a natural alternative view to the existing party/chamber filters
- **Homepage** once the data justifies it (before the "Ready to use your vote?" CTA section)

## Behavior

- Click a state → navigates to a filtered blog listing showing only posts for that state
- States with posts: highlighted, clickable (colored by dominant party, or neutral)
- States without posts: grayed out, not clickable (or shows "no reports yet")

## Implementation Notes

- Use a static SVG map of the US — Astro renders it at build time with post data, no server needed
- The `state` field already exists on every post (2-letter abbreviation) — data model is ready
- At build time, compute which states have posts and pass that into the map component
- Clicking a state links to `/blog?state=XX` — the blog page already has filter infrastructure to extend
- Clean execution is key: highlighted states, grayed empties, no pin icons or clipart

## Files to Create/Modify (When Ready)

- `src/components/StateMap.astro` — new SVG map component
- `src/pages/blog/index.astro` — add map as alternative view, extend state filter to accept URL param
- `src/pages/index.astro` — add map section before CTA (homepage, later)

## Status

Parked until post count justifies it. Revisit when coverage spans 10–15+ states.
