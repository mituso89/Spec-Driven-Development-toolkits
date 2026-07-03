# Performance Checklist

## Before Optimizing

- [ ] A baseline measurement exists (specific numbers, not impressions)
- [ ] The bottleneck is identified from profiling data, not assumption
- [ ] The planned fix targets the measured bottleneck, not a hunch

## Frontend

- [ ] Core Web Vitals within "Good" thresholds (verify current thresholds at web.dev/vitals)
- [ ] Images have explicit dimensions, modern formats, and responsive sizes
- [ ] Below-the-fold images use `loading="lazy"` and `decoding="async"`
- [ ] The LCP image uses `fetchpriority="high"` and is not lazy-loaded
- [ ] Heavy or rarely-used features are code-split (dynamic import / route-level splitting)
- [ ] Bundle size within budget and reviewed on change
- [ ] No render-blocking CSS/JS in the critical path

## Backend

- [ ] No N+1 queries in data fetching paths (check query logs)
- [ ] List endpoints are paginated
- [ ] Hot queries are covered by indexes
- [ ] Frequently-read, rarely-changed data is cached with a TTL
- [ ] Static assets served with long-lived `Cache-Control` headers

## Measurement and Enforcement Commands

Example (Node) — adapt to the project's stack:

```bash
# Bundle size check
npx bundlesize --config bundlesize.config.json

# Lighthouse CI
npx lhci autorun

# RUM: Web Vitals library in code
# import { onLCP, onINP, onCLS } from 'web-vitals';
```

## After Optimizing

- [ ] Before and after measurements recorded
- [ ] A regression guard exists (CI budget check, monitoring, or test)
- [ ] Existing tests still pass (optimization didn't break behavior)

## Anti-Pattern Reference

For the full catalog of common anti-patterns and their fixes (N+1 queries, unbounded fetching, image optimization, unnecessary re-renders, bundle size, caching), see `references/optimization-patterns.md`.
