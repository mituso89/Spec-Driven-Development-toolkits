# Example - one complete decision thread

Everything here is a placeholder: ticket `PROJ-123`, the earlier ticket `PROJ-98`, PR 45, the commit hash, and the owners `@earlier-dev` and `@product-owner`.
Config used: `ticketRefFormat` = `PROJ-{id}`, `ticketLinkTemplate` = `https://tracker.example.com/browse/PROJ-{id}`.

The ticket asks for a filter panel on the Orders list.
The Customers list already has one.

## Post package

### Subject

```text
[PROJ-123] Shared filter panel
```

### Body

> [PROJ-123](https://tracker.example.com/browse/PROJ-123) · Shared filter panel
>
> 2 questions · for @earlier-dev (built the current panel in [PR 45](https://git.example.com/acme/web/pull/45) for [PROJ-98](https://tracker.example.com/browse/PROJ-98)) and @product-owner (created [PROJ-123](https://tracker.example.com/browse/PROJ-123))
>
> ---
>
> Q1 · **Should the filter panel move into a shared module that both lists import?** (for earlier-dev)
>
> Situation: the Orders list needs the same filter panel the Customers list got in [PR 45](https://git.example.com/acme/web/pull/45) for [PROJ-98](https://tracker.example.com/browse/PROJ-98).
> Today the panel lives inside the Customers list and reads Customers state directly ([CustomersFilterPanel.tsx at 3f2a9c1](https://git.example.com/acme/web/blob/3f2a9c1/src/customers/CustomersFilterPanel.tsx)).
> Only the filter fields differ between the two lists.
>
> a) Move it to a shared module with the filter fields passed in. Example: Customers and Orders both import one panel; a date picker fix lands in both lists at once.
> b) Copy it into the Orders list. Example: Orders gets its own panel; the same date picker fix has to be made twice.
> c) Keep it in Customers and import it from there. Example: Orders depends on Customers code; a Customers refactor can break the Orders filters.
>
> Recommendation: a - one panel, one place to fix, and the field list is already the only difference.
> Blocks the build: yes
> Default if no answer: none - the build waits
>
> Q2 · **Should a filter saved on the Customers list also show up on the Orders list?** (for product-owner)
>
> Situation: Customers users can save a filter, for example "My open customers".
> [PROJ-123](https://tracker.example.com/browse/PROJ-123) does not say whether saved filters are per list or shared.
>
> a) Per list. Example: "My open customers" appears only on Customers; Orders starts with no saved filters.
> b) Shared across lists. Example: "Created this week" saved on Customers also appears on Orders.
>
> Recommendation: a - the two lists filter on different fields, so most saved filters would not apply.
> Blocks the build: no
> Default if no answer: a - per list
>
> ---
>
> Reply in one line per question:
> `Q1: a - because ...`
> `Q2: b - because ...`

### Mention list

| Owner identity (from Phase 1) | Questions | Evidence |
|---|---|---|
| `earlier-dev@example.com` (PR 45 author) | Q1 | [PR 45](https://git.example.com/acme/web/pull/45) |
| `product-owner@example.com` (ticket creator) | Q2 | [PROJ-123](https://tracker.example.com/browse/PROJ-123) |

The project's `delivery.post` step turns these identities into its chat tool's mentions and returns the thread link.

## A reply

```text
Q1: a - agree, put it in a shared module and keep the Customers behaviour unchanged
```

Q1 is answered by its owner.
Q2 has no reply yet, so it stays open and the build uses its default (a).

## Log entries (`specs/<feature-id>/decisions.md`)

```markdown
## D-001 - Shared filter panel module
- Ticket: [PROJ-123](https://tracker.example.com/browse/PROJ-123)
- Kind: engineering
- Owner: earlier-dev - authored [PR 45](https://git.example.com/acme/web/pull/45) that built the Customers panel for [PROJ-98](https://tracker.example.com/browse/PROJ-98)
- Status: answered
- Blocks build: yes
- Default if no answer: none - the build waits
- Question: Should the filter panel move into a shared module that both lists import?
- Asked: 2026-11-10 in [thread](<thread url from delivery.post>)
- Answer: a - agree, put it in a shared module and keep the Customers behaviour unchanged
- Answered by: earlier-dev
- Answered on: 2026-11-10
- Changes what must be built: no
- Links: [PR 45](https://git.example.com/acme/web/pull/45), [CustomersFilterPanel.tsx at 3f2a9c1](https://git.example.com/acme/web/blob/3f2a9c1/src/customers/CustomersFilterPanel.tsx), [PROJ-98](https://tracker.example.com/browse/PROJ-98)

## D-002 - Saved filters per list or shared
- Ticket: [PROJ-123](https://tracker.example.com/browse/PROJ-123)
- Kind: product
- Owner: product-owner - created [PROJ-123](https://tracker.example.com/browse/PROJ-123)
- Status: open
- Blocks build: no
- Default if no answer: a - per list
- Question: Should a filter saved on the Customers list also show up on the Orders list?
- Asked: 2026-11-10 in [thread](<thread url from delivery.post>)
- Answer: -
- Answered by: -
- Answered on: -
- Changes what must be built: -
- Links: [PROJ-123](https://tracker.example.com/browse/PROJ-123)
```

## Decision record handed to `delivery.writeBack` for D-001

```markdown
**Decision D-001** for [PROJ-123](https://tracker.example.com/browse/PROJ-123): Shared filter panel module
Question: Should the filter panel move into a shared module that both lists import?
Answer: a - move it to a shared module with the filter fields passed in; keep the Customers behaviour unchanged.
Answered by: earlier-dev, 2026-11-10, in the [decision thread](<thread url from delivery.post>).
Links: [PR 45](https://git.example.com/acme/web/pull/45), [PROJ-98](https://tracker.example.com/browse/PROJ-98)
```

D-001 does not change what must be built, so no acceptance-criteria line is passed.
If Q2 were later answered `b`, the record for D-002 would also carry:

```markdown
Acceptance criterion to add: A filter saved on the Customers list also appears in the saved filters on the Orders list. (D-002, 2026-11-11)
```

The project step decides where these land on the ticket (a comment, a decisions section, the acceptance criteria field) and converts the links to its tracker's format.
