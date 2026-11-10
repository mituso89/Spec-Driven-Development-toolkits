# Example - one complete Outreach decision post

Ticket [AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973) needs a filter panel that another list already has.
The question is whether to share it as a package.

Everything except the ticket number is illustrative.
People are shown as role placeholders (`Product Owner`, `Earlier Dev`); the real post uses the names from `config.people`.
The related ticket [AB#2897001](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897001), PR 1931 and the commit hash stand in for whatever the evidence search finds.

## Subject

```text
[AB#2897973] Shared filter panel package
```

## Rendered body (what the channel sees)

> [AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973) · Shared filter panel package
>
> 2 questions · for @Earlier Dev (built the current panel in [PR 1931](https://github.com/elay-io/outreach-front/pull/1931) for [AB#2897001](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897001)) and @Product Owner (created [AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973))
>
> ---
>
> Q1 · **Should the filter panel move into a shared package that both lists import?** (for Earlier Dev)
>
> Situation: the Sequences list needs the same filter panel the Contacts list got in [PR 1931](https://github.com/elay-io/outreach-front/pull/1931) for [AB#2897001](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897001).
> Today the panel lives inside the Contacts list and reads Contacts state directly ([ContactsFilterPanel.tsx at 3f2a9c1](https://github.com/elay-io/outreach-front/blob/3f2a9c1/src/contacts/ContactsFilterPanel.tsx)).
> Only the filter fields differ between the two lists.
>
> a) Move it to a shared package with the filter fields passed in. Example: Contacts and Sequences both import one panel; a date picker fix lands in both lists at once.
> b) Copy it into the Sequences list. Example: Sequences gets its own panel; the same date picker fix has to be made twice.
> c) Keep it in Contacts and import it from there. Example: Sequences depends on Contacts code; a Contacts refactor can break the Sequences filters.
>
> Recommendation: a - one panel, one place to fix, and the field list is already the only difference.
> Blocks the build: yes
> Default if no answer: none - the build waits
>
> Q2 · **Should a filter saved on the Contacts list also show up on the Sequences list?** (for Product Owner)
>
> Situation: Contacts users can save a filter, for example "My open contacts".
> [AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973) does not say whether saved filters are per list or shared.
>
> a) Per list. Example: "My open contacts" appears only on Contacts; Sequences starts with no saved filters.
> b) Shared across lists. Example: "Created this week" saved on Contacts also appears on Sequences.
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

## HTML body (what is sent)

```html
<p><a href="https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973">AB#2897973</a> · Shared filter panel package</p>
<p>2 questions · for <at id="0">Earlier Dev</at> (built the current panel in <a href="https://github.com/elay-io/outreach-front/pull/1931">PR 1931</a> for <a href="https://dev.azure.com/access-devops/Elay/_workitems/edit/2897001">AB#2897001</a>) and <at id="1">Product Owner</at> (created <a href="https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973">AB#2897973</a>)</p>
<hr>
<p>Q1 · <b>Should the filter panel move into a shared package that both lists import?</b> (for Earlier Dev)</p>
<p>Situation: the Sequences list needs the same filter panel the Contacts list got in <a href="https://github.com/elay-io/outreach-front/pull/1931">PR 1931</a> for <a href="https://dev.azure.com/access-devops/Elay/_workitems/edit/2897001">AB#2897001</a>.
Today the panel lives inside the Contacts list and reads Contacts state directly (<a href="https://github.com/elay-io/outreach-front/blob/3f2a9c1/src/contacts/ContactsFilterPanel.tsx">ContactsFilterPanel.tsx at 3f2a9c1</a>).
Only the filter fields differ between the two lists.</p>
<p>a) Move it to a shared package with the filter fields passed in. Example: Contacts and Sequences both import one panel; a date picker fix lands in both lists at once.<br>
b) Copy it into the Sequences list. Example: Sequences gets its own panel; the same date picker fix has to be made twice.<br>
c) Keep it in Contacts and import it from there. Example: Sequences depends on Contacts code; a Contacts refactor can break the Sequences filters.</p>
<p>Recommendation: a - one panel, one place to fix, and the field list is already the only difference.<br>
Blocks the build: <b>yes</b><br>
Default if no answer: none - the build waits</p>
<p>Q2 · <b>Should a filter saved on the Contacts list also show up on the Sequences list?</b> (for Product Owner)</p>
<p>Situation: Contacts users can save a filter, for example "My open contacts".
<a href="https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973">AB#2897973</a> does not say whether saved filters are per list or shared.</p>
<p>a) Per list. Example: "My open contacts" appears only on Contacts; Sequences starts with no saved filters.<br>
b) Shared across lists. Example: "Created this week" saved on Contacts also appears on Sequences.</p>
<p>Recommendation: a - the two lists filter on different fields, so most saved filters would not apply.<br>
Blocks the build: <b>no</b><br>
Default if no answer: a - per list</p>
<hr>
<p>Reply in one line per question:<br>
<code>Q1: a - because ...</code><br>
<code>Q2: b - because ...</code></p>
```

## Graph payload

`POST https://graph.microsoft.com/v1.0/teams/{teamId}/channels/{channelId}/messages`, ids from `config.json`:

```json
{
  "subject": "[AB#2897973] Shared filter panel package",
  "body": { "contentType": "html", "content": "<the HTML body above>" },
  "mentions": [
    { "id": 0, "mentionText": "Earlier Dev",
      "mentioned": { "user": { "id": "<aadUserId from config.people>", "displayName": "Earlier Dev", "userIdentityType": "aadUser" } } },
    { "id": 1, "mentionText": "Product Owner",
      "mentioned": { "user": { "id": "<aadUserId from config.people>", "displayName": "Product Owner", "userIdentityType": "aadUser" } } }
  ]
}
```

Each `mentions[].id` matches one `<at id="N">` tag, and `mentionText` matches the tag text exactly.

## A reply

```text
Q1: a - agree, put it in a shared package and keep the Contacts behaviour unchanged
```

Q1 is answered by its owner.
Q2 has no reply yet, so it stays open and the build uses its default (a).

## Log entry after the reply (`specs/<feature-id>/decisions.md`)

```markdown
## D-001 - Shared filter panel package
- Ticket: [AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973)
- Kind: engineering
- Owner: Earlier Dev - authored [PR 1931](https://github.com/elay-io/outreach-front/pull/1931) that built the Contacts panel for [AB#2897001](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897001)
- Status: answered
- Blocks build: yes
- Default if no answer: none - the build waits
- Question: Should the filter panel move into a shared package that both lists import?
- Asked: 2026-11-10 in [Teams thread](<message web url>)
- Answer: a - agree, put it in a shared package and keep the Contacts behaviour unchanged
- Answered by: Earlier Dev
- Answered on: 2026-11-10
- Links: [PR 1931](https://github.com/elay-io/outreach-front/pull/1931), [ContactsFilterPanel.tsx at 3f2a9c1](https://github.com/elay-io/outreach-front/blob/3f2a9c1/src/contacts/ContactsFilterPanel.tsx), [AB#2897001](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897001)

## D-002 - Saved filters per list or shared
- Ticket: [AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973)
- Kind: product
- Owner: Product Owner - created [AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973)
- Status: open
- Blocks build: no
- Default if no answer: a - per list
- Question: Should a filter saved on the Contacts list also show up on the Sequences list?
- Asked: 2026-11-10 in [Teams thread](<message web url>)
- Answer: -
- Answered by: -
- Answered on: -
- Links: [AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973)
```

## ADO write-back comment on [AB#2897973](https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973)

```html
<p><b>Decision D-001</b> for <a href="https://dev.azure.com/access-devops/Elay/_workitems/edit/2897973">AB#2897973</a>: Shared filter panel package</p>
<p><b>Question:</b> Should the filter panel move into a shared package that both lists import?</p>
<p><b>Answer:</b> a - move it to a shared package with the filter fields passed in; keep the Contacts behaviour unchanged.<br>
<b>Answered by:</b> Earlier Dev, 2026-11-10, in the <a href="<message web url>">Teams spec decision thread</a>.</p>
<p><b>Links:</b> <a href="https://github.com/elay-io/outreach-front/pull/1931">PR 1931</a>, <a href="https://dev.azure.com/access-devops/Elay/_workitems/edit/2897001">AB#2897001</a></p>
```

After posting, read it back with `$expand=renderedText` and confirm it has 4 anchors.
