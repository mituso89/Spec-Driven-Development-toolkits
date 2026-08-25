# Project Knowledge

> Facts & pointers for SDD phases. An INDEX, not a copy — link out and keep it
> from rotting. Rules live in `constitution.md`; this is what is *true* about the project.

## Stack profile
<framework · language + strictness · package manager · test runner · data layer — one paragraph>

## Verification gate
<The single "prove it works" command and what passing means — e.g.
`npm run verify` (lint + tests + live smoke) exits 0. This is the project's
"eyes": implement names it in the GO summary and runs it before claiming done.
If none exists yet, say so — a fake gate is worse than none.>

## Map (pointers — do not duplicate)
- Architecture: <ARCHITECTURE.md §x / docs link>
- Key modules: <path — responsibility>   (file or file:line pointers)
- Source-of-truth files: <…>

## Structural grounding
- Source: <`.sdd/repo-map.md` (generated) | serena | codegraph>
- The repo map is auto-generated (`m-sdd-knowledge/repo-map.sh`) — files + key
  symbols, regenerated from source. Read it to learn what exists before adding
  code. Never edit it; never treat it as truth over the running code.

## Domain glossary
- <term> — <meaning>   (terms specify/clarify must know; written inline — they live nowhere else)

## External knowledge
- <lib / API> — <doc URL>   ·   "run context7 query-docs for <lib>"
- <RFC / product doc links>

## Decisions (cross-feature)
- <date> — <decision> — <why>   (so specify doesn't relitigate settled choices)
