# Welsh HTML attachments blocked by stale English redirects

## Summary

Seven Welsh HTML attachments on consultations, including one on a consultation outcome, could not be published to Publishing API. Each `cy` publish was rejected with a 422 `conflict`, because an `en` redirect content item already sat at the same base path.

The redirects were created automatically by Publishing API in Sept 2024. That happened when a Whitehall change (later reverted) moved the attachments off their slug URLs. When later Whitehall changes moved them back to their slug URLs *and* changed their locale to `cy`, Publishing API couldn't clear the old redirects, because it only clears conflicting editions in the same locale.

Six of the seven have been stuck since the April 2025 locale backfill. PR #11849 didn't cause the problem. Its republish brought it to light again, and it also caught one more attachment (a consultation outcome).

## Errors seen

PR #11849's data migration (`20261002120000_set_locale_on_non_english_response_html_attachments.rb`) republished 24 documents. Four attachments failed, for example:

```
base path=/government/consultations/datgelu-taliadaur-diwydiant-ir-sector-gofal-iechyd/datgelu-taliadaur-diwydiant-ir-sector-gofal-iechyd
conflicts with content_id=164c2145-74ae-47f6-add4-4a57c788381d and locale=en
```

The failing paths are on HTML attachments of the consultation itself (`/government/consultations/<slug>/<attachment-slug>`). These aren't the response attachments the migration changed. They were caught because the migration republishes whole documents.

## Affected content

All the titles are Welsh with curly apostrophes (`’`), so they aren't ASCII-only.

| Attachment content_id | Attached to | Whitehall document | Blocking `en` redirect edition (Publishing API) | `cy` draft created |
|---|---|---|---|---|
| `7f1b1a94-13d2-4434-8769-973f20a73334` | Consultation | 491618 | 14828632 (published) | 2025-04-24 |
| `5cae1d8f-66a4-4e77-ab10-f898c7b2400a` | Consultation | 539913 | 14843446 (published) | 2025-04-24 |
| `8b3b65b9-f820-4180-8458-bf5610684d02` | Consultation | 538765 | 14843066 (published) | 2025-04-24 |
| `b05bfe61-d8a5-49cd-89e3-a24145af7d9f` | Consultation | 540197 | 14843511 (published) | 2025-04-24 |
| `eaa8f2ee-8cfe-41ec-a4a0-d61ce58a410a` | Consultation | 523713 | 14838292 (published) | 2025-04-24 |
| `3b73ef27-278a-42ea-8e27-6f0f95e59d3c` | Consultation | 469261 | 14821575 (published) | 2025-04-24 |
| `3a89fc19-a45a-4776-967a-6d3caca6f29d` | Consultation outcome | 469261 | 14821613 (unpublished) | 2026-10-02 |

Every redirect points from the attachment's slug path to `/…/<attachment content_id>`. That is, each one is the attachment's own leftover redirect. Every attachment is on its document's live edition. Document 469261 also has a submitted edition (1410496) waiting for review.

## How we got here

### Oct 2023: attachments published at slug paths in `en`

The attachments were created with no `locale` set, so Whitehall sent them to Publishing API as `en`. They were given slugs generated from their titles, e.g. `/government/consultations/datgelu-…/datgelu-…`.

### 24 Jul 2024: identifier changed to content_id for non-ASCII titles (`55f9d09b24`)

`HtmlAttachment#identifier` was changed to return the content_id unless the title was ASCII-only:

```ruby
def identifier
  return slug if slug_eligible?   # title.ascii_only? && sluggable_locale?
  content_id
end
```

The slug stayed in the database, but these attachments' base paths quietly became `/…/<content_id>`.

### 13 Sept 2024: Publishing API creates redirects

The next republish of each document sent the `en` attachment at its new content_id path. When a draft's base path changes, Publishing API's `RedirectService` (called from `Commands::V2::PutContent#create_redirect`) automatically creates a redirect from the old path:

- with a **new random content_id** (`SecureRandom.uuid`)
- in the **locale of the old edition** (`en`)

All four redirects we inspected were created between 11:31 and 11:49 that day. That looks like a bulk or automated republish, but we haven't identified exactly which one. The mechanism doesn't depend on what triggered it.

### 4–5 Feb 2025: identifier changed back to slug (`f40e845bf4`, `ac898d08ed`, `0609ff5b86`)

`identifier` became `slug || content_id`, and slugs became available for every locale. These attachments still had their slugs stored, so their base paths quietly switched back to the slug path.

On its own this was harmless. An `en` attachment moving back to its slug path replaces its own `en` redirect, because Publishing API's `SubstitutionHelper` clears substitutable document types (`redirect`, `gone`, …) **in the same locale**.

### 23–24 Apr 2025: locale backfill makes the conflict permanent

`2b3f8c27ac` started setting HTML attachment locales to the parent's primary locale for non-English consultations and calls for evidence. Data migration `20250423111600_fix_foreign_language_only_html_attachment_locales.rb` backfilled `locale = "cy"` on consultation-level HTML attachments and republished the documents.

Whitehall then sent the attachments as `cy` at their slug paths. The `cy` drafts were saved (all created 2025-04-24 15:51:12), but publishing them failed because the `en` redirects were still at those paths. They've been stuck as `cy` drafts since then. Their live `en` editions are still at the content_id paths, with no `parent` link.

### 2 Oct 2026: PR #11849

PR #11849 fixed the same locale problem for HTML attachments on consultation outcomes, public feedback and call for evidence outcomes (`5529d43900`). It also backfilled them and republished 24 documents (`1e840ec3d6`).

- 4 of the 6 already-stuck documents were among the 24. Their consultation-level attachments failed again with the errors above.
- The outcome attachment `3a89fc19` on document 469261 was newly set to `cy` by the migration and is blocked in the same way (its `cy` draft was created today). Its blocking redirect is `unpublished` instead of `published`. That still counts as a conflict, because only `substitute` unpublishings are excluded.
- On documents where a consultation-level attachment failed, `PublishingApiAssociatedDocuments#do_publish` stops at the first error, so attachments later in the list (such as outcomes) may not have been published.

The commit message of `1e840ec3d6` says "Publishing API substitutes the old 'en' draft/live editions". That's only true when the old edition has the same content_id and is `published`. It isn't true for these leftover redirects.

## Root cause

### Publishing API: cross-locale gap in clearing conflicting editions

- Automatic redirects are separate documents, with a random content_id, in the locale the content used to have.
- `SubstitutionHelper.blocking_editions` only clears editions **in the same locale** as the incoming one.
- `Commands::V2::Publish#clear_published_item_of_different_locale_but_matching_base_path` only clears editions with the **same content_id**, and only when they're `published`.
- `Queries::BasePathForState` (used by `BasePathForStateValidator`) treats base paths as unique **across all locales**.

So when content changes locale, it can never move back to a path where it left a redirect in its old locale. Nothing clears it except manual intervention.

A possible upstream fix would be for `blocking_editions` to clear substitutable editions (`redirect`, `gone`, etc.) in any locale, since base paths have to be unique across locales anyway.

### Whitehall: URL churn in the past, no live bug

The Jul 2024 change, and its reversal in Feb 2025, moved these attachments' URLs away and back again. The current code doesn't do this, so there's nothing live to fix in Whitehall. The problem only shows up when three things combine: a non-ASCII title, a republish between Jul 2024 and Feb 2025, and a later locale change. A Publishing API query shows only these 7 cases.

## Remediation

### Pre-checks (done)

Publishing API: every redirect points to its attachment's own content_id path, and every `cy` draft is blocked by exactly one `en` redirect:

```ruby
cids.each do |cid|
  draft = Edition.with_document.find_by(state: "draft", documents: { content_id: cid, locale: "cy" })
  redirect = Edition.with_document.find_by(base_path: draft.base_path, state: %w[published unpublished], document_type: "redirect", documents: { locale: "en" })
  pp [cid, draft.created_at, redirect.id, redirect.state, redirect.redirects.all? { |r| r[:destination].end_with?(cid) }]
end
```

Whitehall: all 7 attachments are on their document's live edition, with locale `cy`.

### 1. Publishing API: substitute the blocking redirects

Run this immediately before step 2. Once a redirect is removed, its slug path serves nothing until the `cy` attachment is published there.

```ruby
ids = [14828632, 14843446, 14843066, 14843511, 14838292, 14821575, 14821613]
Edition.where(id: ids).each { |e| e.substitute; SubstitutionHelper.substitute_message(e) }
```

This matches what Publishing API itself does to a published edition in a different locale (`Edition#substitute`). It also works on the already-`unpublished` redirect 14821613.

### 2. Whitehall: republish the affected documents

```ruby
[491618, 539913, 538765, 540197, 523713, 469261].each do |id|
  Whitehall::PublishingApi.republish_document_async(Document.find(id))
end
```

`PublishingApiDocumentRepublishingJob` re-sends both the live edition and document 469261's submitted edition, in the correct order.

### 3. Publishing API: verify

Each content_id should be `published` in `cy` at its slug path, with no leftover draft:

```ruby
cids = %w[7f1b1a94-13d2-4434-8769-973f20a73334 5cae1d8f-66a4-4e77-ab10-f898c7b2400a
          8b3b65b9-f820-4180-8458-bf5610684d02 b05bfe61-d8a5-49cd-89e3-a24145af7d9f
          eaa8f2ee-8cfe-41ec-a4a0-d61ce58a410a 3b73ef27-278a-42ea-8e27-6f0f95e59d3c
          3a89fc19-a45a-4776-967a-6d3caca6f29d]
cids.each { |cid| pp [cid, Edition.with_document.where(documents: { content_id: cid }).where.not(state: "superseded").pluck(:state, "documents.locale", :base_path)] }
```

### 4. Whitehall: redirect the old `en` editions

Only run this once step 3 is clean. It redirects `/…/<content_id>` (still live in `en`) to the slug path:

```ruby
cids.each do |cid|
  att = HtmlAttachment.where(content_id: cid, deleted: false).order(:id)
    .find { |a| ed = a.attachable.is_a?(Edition) ? a.attachable : a.attachable.parent_attachable; ed.document.live_edition&.id == ed.id }
  next puts("skip #{cid}: not on live edition") unless att
  PublishingApiRedirectJob.new.perform(cid, att.base_path, "en")
end
```

### 5. Spot check on GOV.UK

- `https://www.gov.uk/api/content/<slug path>` should return `"locale": "cy"` and a populated `links.parent`.
- `https://www.gov.uk/api/content/<content_id path>` should return a redirect to the slug path.
- Re-running the affected-content query in Publishing API should return nothing:

```ruby
Edition.with_document
  .where(state: "draft", publishing_app: "whitehall", document_type: "html_publication")
  .where.not(documents: { locale: "en" })
  .select { |e| Edition.with_document.where(base_path: e.base_path, state: %w[published unpublished], document_type: "redirect", documents: { locale: "en" }).exists? }
  .map { |e| [e.document.content_id, e.document.locale, e.base_path] }
```

## Follow-ups

- Consider raising the cross-locale substitution gap with the Publishing API maintainers.
- Optional: to find out what triggered the 13 Sept 2024 republish, look at Publishing API `events` for one of the attachment content_ids around that time.
