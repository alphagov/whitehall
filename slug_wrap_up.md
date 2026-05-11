# Slugs

This document is a wrap-up of the slug rework, which involved both code and data changes, and has had some implications on the behaviour of slugs for editions. It includes a history of the changes, a summary of the current state of the world, and a list of known issues and improvements to be made.

## Legend
* CIP = CorporateInformationPage
* LP = LandingPage 
* WNS = WorldwideNewsStory
* DC = DocumentCollection
* CFE = CallForEvidence
* CONS = Consultation
* S = `slug`
* SO = `slug_override`
* SFT = `slug_from_title`

## A history of slugs (as of May 2026)

A short history of slug related changes is:
- `e02e8280` Add slug column and index to editions table (20260205110846_add_slug_to_editions_table.rb) - db migration
- `cdf04d33` (10/02/2026) Store slug for edition when title changes
- `38f27e5c` Copy slug from documents table to editions table 20260216110353_copy_slug_from_documents_to_editions.rb - data migration, simply copies all document slugs into the editions table
- `24ff76fe` Added slug_override column to editions table - db migration
- `2acaa5bb` (31/03/2026) Enable slug update opt out via override column - allows setting overrides on edition if "live" slug should be kept on new editions.
- *`325b7c1b` (09/04/2026) Add a data migration to apply slug overrides for live documents -> 20260409100353_copy_slug_from_documents_to_edition_slug_override.rb
- `91587649` (09/04/2026) Remove references to document slugs
- `00989ff7` (09/04/2026) Remove slugs for editions feature flag
- `00229bdb` (09/04/2026) Remove slug column from documents table
- `371e1f57` Add `slug_from_title` to editions
- `99e62187` Set both `slug` and `slug_from_title` when edition title changes
- **`3797f8e5` Add data migration to generate `slug_from_title` - 20260414111505_generate_slug_from_title.rb data migration
- `3b43faa3` Add migration to backfill `slug_from_title` with the value of `slug` - 20260505152712_backfill_slug_from_title_on_post_publication_editions.rb
- `b19a8377` Add migration to set `slug` to `slug_override`, if override is present 20260503161913_set_slug_to_slug_override_when_slug_override_present.rb - a db migration
- `1749b24c` Update callbacks for slug generation, and remove reader methods

Notes:
- *`325b7c1b` is hard to decipher historically. It's most likely that, between February and April, editions started storing a title-based slug in the slug column, but the document slug kept being used. New changes were under a feature flag, but unsure if the flag was ever turned on while in place. The editions slugs were originally set to the document slug (38f27e5c), so they all historically did match the live slug. Editions redrafted in the interim (Feb-Apr) would have stored a title-based slug different from the document slug. `325b7c1b` likely only set the `slug_override` to the value of the document slug, only for these interim editions. For all new editions after 2acaa5bb the override would be intentionally (but optionally) set by the user via the checkbox in the form, so they would continue having correct data.
- **`3797f8e5` set both the `slug` and `slug_from_title` to a title-based candidate slug (this was generated anew running the callback), but also set `slug` to `slug_override` if present, in one swoop, albeit just for draft editions. This was slightly overzealous, as at this point in time the code was not yet ready to use a slug column storing the override.

See implications of these changes in the next section.

Basecamp post:
https://3.basecamp.com/4322319/buckets/15005645/messages/9765051561

### Some risky and confusing data implications

`325b7c1b` addressed all the diverging editions in the interim, and set their overrides. But it left out all the other live editions where the historical slug is not title-based, and there is no override to reflect that (not a functional problem, but a data integrity problem).

Between the migration of `3797f8e5` and the following code merge (1749b24c) about 2 weeks later, there was no way to correctly fetch the `slug_from_title` for drafts for the checkbox logic, if the edition had an override. The `slug_from_title` reader method at the time returned the DB `slug` which had now been set to the value of the override. On a draft edition with an override, a checked checkbox should have shown (as the title is different from live) but for this period in between it did not. 
- Typically, when an override is present, the equality check on `_page_address_controls.html.erb` will be false, the JS will not load, and the rendered and checked checkbox stays rendered. This was not true in this interim period. The behaviour was: the checkbox rendered as checked for a split second → JS then hid the container -> the checkbox still submitted the correct `slug_override` value → `slug_override` did not get inadvertently blanked, even though the user couldn't see or interact with the checkbox.
- This removed the option to use a title-based slug, but did not cause accidental reversal of already set overrides.
- It broke the then expected functionality, effectively reverting to default behaviour we had previously, i.e. using live slug with no alternative.

Another consequence of the fresh regeneration of `slug` and `slug_from_title` on pre-publication editions in `3797f8e5` is that, it possibly set different slugs from what the user may have previewed, which then went live unchecked. The `set_slug` callback is not idempotent. It typically ends up generating the same title-based slug if the state of the database does not change but, if, for example, previously clashing editions get deleted, it would generate a potentially more desirable slug (smaller suffix or no suffix at all). The scope seems negligible, but it is a possibility that some editions got published at a different slug than what was previewed, and there was no indication of this. Since the migration was run with touch false it is hard to trace what was affected. No support tickets were raised about this.

`3797f8e5` also set `slug` and `slug_from_title` on some special types, such as corporate information pages and non-en primary locale editions, which behave differently. Upon investigation, we confirmed that neither were negatively affected, but it is worth noting the implications:
- Corporate information pages always use a hardcoded slug. Nonetheless, the migration set `slug` to hardcoded type-based values, and `slug_from_title` to the document ID (i.e. the DB `slug` at the time, which was historically the document ID), which makes for confusing data.
- No non-en primary locale editions happened to have overrides set, and due to the internal locale in the migration being `:en` the slug generation logic was skipped, so they only got their `slug_from_title` set to whatever the `slug` was previously. In most cases that is a document ID (i.e. locale title cannot be slugged), which is not exactly suitable for the `slug_from_title` column. There were also historical discrepancies here, where document-ID slugs were set for perfectly supported locales, instead of title-based slugs, which again makes for confusing data.

All these aspects were looked into in April 2026. A decision log from the investigations can be found in [Investigations in April 2026](#investigations-in-april-2026). A summary of the state of the world and known issues can be found in [Current state of the world](#current-state-of-the-world-may-2026).

## Current state of the world (May 2026)

For all data, the following applies:
- SFT is set and matches existing slugs for historical, post-publication editions - it was set to the value of the slug, where there was no override, or there was an override but the slug hadn't yet been set to the value of the override - see `3b43faa3`.
- SFT is set for all pre-publication editions - it was generated fresh in `3797f8e5` and keeps on being set when title changes or a new draft from published is created.
- The slug is set to the value of the override where override is present, for all editions regardless of state, except for deleted and superseded ones - see `b19a8377`.

Below are a few categories of special interest, where the data is not ideal, and/or the behaviour is not ideal, and/or there are known issues.

### Live editions

Data:
- There are numerous editions where their current slugs are not title based, and they have no overrides set. This is because `325b7c1b` only captured a small portion of editions. While not problematic, this can make DB data hard to understand.
- Slug from title has been historically set to the value of the slug where no override was present (`3b43faa3`). This means SFT are now potentially set to de facto override values. The reason why a regeneration was not viable for live data, is that the rules of slugging have changed since publication. So the best call for already live data was to just store the slug.
- Even when the slug and SFT are title based, that is in accordance with slugging logic at that point in time. If redrafted, some editions would show an override checkbox because the slug generation logic has changed since their publication, and the newly generated SFT would no longer match the live slug.

Current stats:
- 33854 out of 348827 **published** editions have "mismatched" slugs - when checking current slug DB value against a regenerated SFT. The regeneration is based on current slugging behaviour, so most of these are accurate in their own right. There are nonetheless some that have genuine overrides.
- 4041 out of 44087 **withdrawn** editions have "mismatched" slugs, but again the same applies as above.

Behaviour:
- Both slug and SFT get regenerated when the edition is redrafted. The users will get the option to use an override for preserving the live slug.

Problematic behaviours:
Withdrawn editions
- 🚨 When unwithdrawing a withdrawn edition without an explicit override set (i.e. historical slugs that are not title-based, either because they were reslugged with custom slug or because the slugging rules have since changed so a freshly generated slug candidate would not match existing SFT), the editions gets immediately republished at a title-based slug. 
- This is due to the fact that we now properly *redraft* and then publish unwithdrawn editions. So the edition will go through slug regeneration as part of unwithdrawing.
- We believe the previous slug would redirect to the new one, so there is no risk of breaking links.
- In some cases, the historical slugs are suffixed, and the new slug would be a favourable slug either with a smaller suffix or no suffix at all, so this is not necessarily a bad thing, but it is a change that users may not expect.
- Note that for genuine override cases, the user cannot currently set an alternative slug that is not title based - i.e. they cannot go back to the live slug if it was a genuine override. They'd need to change the title to generate the desired slug.

Unpublished editions
- Redrafting from unpublished behaves a lot like a first ever draft, as the corresponding `document.live_edition` is nil.
- 🚨 When redrafting an unpublished edition, we show no checkbox due to lack of live edition. This is not exactly correct, as the option to use the live slug or title based also applies here.
- If the live edition has a `slug_override` set, it is preserved when redrafting. Nonetheless, for live slugs that are not title based, a draft from unpublished would save to a new title-based slug. There is currently no indication of that to the user outside the preview feature, especially since we don't show the live address on the form anymore. This is an implication of the fact that live edition slugs are not correctly represented as overrides.

Examples of mismatches:
```json
Edition 1764843 (Publication, published) - true override
Title:           Wild bird populations in the UK and in England
Current slug:    wild-bird-populations-in-the-uk
Candidate slug:  wild-bird-populations-in-the-uk-and-in-england

Edition 315081 (StandardEdition, published) - divergent due to slugging rules changes
Title:           Changes to the UK visa application process in Egypt
Current slug:    changes-to-the-uk-visa-application-process-in-egypt-2
Candidate slug:  changes-to-the-uk-visa-application-process-in-egypt--2

Edition 1666147 (Publication, withdrawn) - true override
Title:           Farming Resilience Fund: free business advice for your farm
Current slug:    get-free-business-advice-for-your-farm
Candidate slug:  farming-resilience-fund-free-business-advice-for-your-farm

Edition 1331846 (Publication, withdrawn) - divergent due to slugging rules changes
Title:           SR2012 No 3: composting in closed systems
Current slug:    sr2012-no3-composting-in-closed-systems
Candidate slug:  sr2012-no-3-composting-in-closed-systems
```

Recommendation: TBC 👀
- TODO: Make a call on whether we are ok with the unwithdrawing behaviour?
- Consider re-enabling reslugging via the UI or rake task, so that we can give the option to set slugs that are not title based.
- Consider unpublishing behaviour -> anything we need to fix?
- Reintroduce the live page address on the form, always.
- Is it worth trying to represent the live slugs as overrides? The difficulty lies in separating discrepancies from slugging logic from genuine overrides. 

### Null and blank slug overrides

Data:
- There are slug overrides that are nil and slug overrides that are blank (''). Nils are defaults, meaning the SO was never set. Blanks are set via the form - meaning that the user actively opted to NOT use the override. 

Behaviour:
- Code currently deals with both nil and blank, so no issues.

Recommendations: TBC 👀
- There is a risk of omission when dealing with data, as a check for nil will not capture blanks, and vice versa. Is the nil vs blank distinction meaningful or should we just set nil?

### CIPs

Data: `slug` mostly set to hardcoded type-based values, and `slug_from_title` to the document ID.
Behaviour: 
- Always use hardcoded slug, ignoring title.
- Newly created CIPs will have SFT and slug set to null, due to the removal of the document ID fallback.

Recommendations TBC 👀:
-  NULL all the columns for CIPs, and introduce a custom setting to better reflect the fact that they manage their own slugs.
- Or always make them set an override, and use the current code flow to then set the slug to the override. This helps keep the behaviour more consistent, and matches what LPs do now. This would also allow us to set a not null constraint on the slug column for all editions, which would be reasonable.

### Non-en primary locale editions

Data: 
- Most are WNS (2324); then 389 DocumentCollections, then 191 Consultations, 10 CFEs, and a handful of other StandardEditions.
- WNS:
  - Most WNS have slug set to Document ID, even when the locale is supported, due to them being historically regular editions. 
  - SFT = slug = Document ID for most WNS. Does not cause issues, but the data can be confusing to understand since SFT should be "title" based.
  - Some now have title based slugs and matching SFTs (created after the move to config-driven).
- CFE, DC and CONS have title based `slug`s where supported, with a matching `slug_from_title`.

Behaviour:
- As users redraft published WNS they will get a chance to opt in for a title-based slug where the locale is supported. The data can fix itself.
- Current drafts will not show a checkbox option unless title changes - can only self-heal on the next publish-redraft cycle (when the slug generation reruns).

Behaviour issues:
- 🚨 Currently, the checkbox behaviour is misleading for non-supported locales 
  - When changing the title, regardless of whether you choose to use the live slug or title based, you always get a document ID slug. So the checkbox is not really doing anything.
  - Subsequent views of the edition will not show a checkbox (because the live and title based slugs are the same), but once you change the title again you might even see a checked! checkbox if you previously chose the override (which can be unexpected, and, again, does nothing).
- When using any amount of supported characters in the title, you will get a non-document-id slug. Not better and not worse than document ID, but likely confusing.

Recommendations: TBC 👀
- 🚨For cases where locale is not supported, the checkbox should not be shown, as it is misleading - regardless of what you choose you can only ever get a document ID slug, unless we start using more advanced transliteration. This can be a problem as we start supporting more and more non-en primaries with the move to config-driven.
- Regenerate the slugs and republish for supported locales, including live ones, so they can have nice title based slugs.
- For any type that does allow non-English primary (StandardEdition, Consultation, CallForEvidence, DocumentCollection), consider passing a locale-aware babosa transliterator (e.g. `to_slug(:russian)`, `to_slug(:arabic)`) where one exists, so non-Latin-script titles can produce readable slugs rather than always falling to `document_id`.
- Consider how to best set `slug`, and `slug_from_title` columns in cases where locale is not supported and a document ID must be set. Should we make use of the override column? Or just keep as is since mostly not problematic?

### Landing pages

Data:
- `slug_override` always set and `slug` matches the override.
- SFT set to title-based values or NULL (compounded migration effects) - messy data but not problematic as SFT is not used for LPs.
- 🚨 Their `slug_overrides` always get a "/" which is unlike other slugs.

Behaviour:
- They require a SO to be set on the form.

Problematic behaviour:
- Although the checkbox currently shows for LP, if opting out of the override, we get a validation error saying override cannot be blank. This is technically correct because we NEVER want to set a title-based slug for LPs, but it is a confusing user experience.

Recommendations: TBC 👀
- We should hide the checkbox for LPs, e.g. conditionally not render the `_page_address_controls.html.erb` in `_standard_fields.html.erb` for LP or make its own view.
- Potentially add a flag of sorts suggesting that they handle their own slugs via overrides.
- Clean up the SFTs for them (set them where they are null).

## Other problematic behaviours

1. The preview link when switching between SFT and SO does not redirect correctly. Needs to be fixed, by adding some cache-busting to the links.
   - FLow: use live slug -> use title based -> use live slug -> preview link correct indicating live slug, but when navigating to it, it shows title based slug.
2. The "Live page" no longer showing on the form for drafts - users unsure what the slug would be.
   - Especially now that the slug can be generated differently upon redrafting (maybe different suffix from the live, likely smaller --n), when there is no override, it should be shown.
3. Slug clashing errors are not shown on drafting from published, or unpublished. While that made sense prior when the default was to keep the live slug, it feels like now that we can set a new slug we should also better express clashes. At least showing the current title-based slug address as per the previous point would help.
4. Checkbox wording can be improved. It will have to change anyway as we flip the logic.
   - we should tell the user what the new title-based url will be
   - "Keep the current page URL" copy for the checkbox is confusing - it sounds like you should keep the current title (slug from title), not the override.
5. There is currently no way to override the override. Not even for developers.
   - Why have we completely removed the reslug UI?
   - We currently have no way to change the override unless it's with a title based slug.
6. Titles with spaces are funny
   - When adding trailing spaces to a title and selecting to use the live slug (i.e. the override) -> it will drop the space from the title, and save an override that matches the title-based slug, which is confusing. Won't actually show the checkbox because both the live slug and the SFT match.
7. Unpublished preview links
   - Unpublished summary page for StandardEdition doesn't seem to have a preview link at all.
   - When viewing the greyed out forms there is also no preview link to use instead.
8. The preview link on the edition form does not update when you use the checkbox - not until you save the edition. Can be confusing.
9. Unrelated bug
   - Invalid LP due to issue with image usage not permitted

## Notes on the slug logic (May 2026)

Although the slug setting callbacks (in [`app/models/concerns/edition/identifiable.rb`](../app/models/concerns/edition/identifiable.rb)) are quite concise, they pack a lot of logic. Here's a breakdown of the various slug flavours.

1. Early exit if `string_for_slug` nil in the identifiable concern
    - 1.1 `string_for_slug` definition at the edition level: `non_english_edition? ? nil : title(:en)` -> slug set to nil for non-en primaries.
    - 1.2 `string_for_slug` definition for config-driven: `title if primary_locale.to_sym == translation.locale` -> slug set to title based for the translation whose locale matches the primary.
    - 1.3 `string_for_slug` definition for corporate information pages: `nil` -> slug set to nil, always.
    - 1.4 `string_for_slug` definition for everything else that supports non-en primaries (currently only call for evidence, consultation, collections): `title`
2. Only CallForEvidence, Consultations, Document Collections and Standard Editions can have non-English primaries - `locale_can_be_changed?` is true, with the additional constraint for config-driven editions that they only allow switching locale if they only have one translation.
3. CIPs delegate their `slug` to the type, always returning a hardcoded value.
4. Previously, when the slug lived on the document model, there was a validation that always set the slug to the document ID if the slug was nil from the generation logic, but this has now been removed (see 91587649 document.rb changes), so that now if the slug cannot be generated it is simply left null. The `base_path` method on edition eventually returns the document ID anyway when calling `base_path` for this edition.
- Nonetheless, nothing should really come into identifiable and leave with a nil slug - `non_english_edition?` will not be true for anything other than StandardEdition, Consultation, CallForEvidence and DocumentCollection non-en primaries, and they use different definitions of `string_for_slug`.
5. Previously, WNS worked the same as other editions (see 1.1), meaning they exited the slug generation if the locale was not supported, and got document ID based slugs (see 4). Now they can get title based slugs if the locale title is sluggable.
6. All config driven editions can now also have non-en primaries, though currently mostly are WNS; only a few news stories exist.
7. Regardless of the logic in (1) the slug setting is always skipped for translations (i.e. when the code runs for a translation row, the slug is not updated).

## Other clean-ups or code improvements to consider

- 🪛 Set not null constraint on slug column.
- 🪛 Republishing_controller.rb -> should probably rename `document_slug` in this
- 🪛 `where_base_path_prefix_matches` method could use the group setting rather than the base path
- 🪛 Consider splitting the config for allowing translations and allowing non-en primaries?
- 🪛 For non en primaries ### Notes on the slug logic
- 🪛 Collate some of the definitions for `string_for_slug` - they pretty much do the same thing, and then the basic definition on identifiable does not seem to do much for other types that don't override it.
- 🪛 Can the code and maybe some tests make it clearer as to what slug behaviours are expected for which types? Maybe use the `locale_can_be_changed?` to exit the set slug logic early?
- 🪛 Could be clearer in code that translations do not affect slug setting.
- 🪛 Consider a new setting such as `manages_own_slug?` to capture custom behaviours such as CIPs and LPS, and use that to exit the set slug logic early for these types.

## Investigations in April 2026

Here are some decisions and actions that came out of the investigations.

### Code decisions

- Restrict set_slug callback to only run when SFT or SO are changed -> prevents an issue where `slug` would become nil if `slug_from_title` was nil and the edition was updated and saved in console (some data migration, with validate false).
- Prevent SFT from being set for post-publication states (which could also nullify the slug).

**Checkbox** - `_page_address_controls.html.erb`
- We will keep on using SFT on checkbox -> because we need to check against the new title of an edition as we edit it. This mean we need SFT set for draft-like states. We have set SFT on all drafts. Published editions will save SFT when redrafted.
- For the SO value in the checkbox -> we keep SO, with the assumption that we have the correct live slug backfilled.

**Republish** - `confirm_document.html.erb`
- We will use slug column, with the assumption that this will be "correct" for  all states -> originally we used slug_from_title (which was driven by a reader for the slug column); the underlying search is a search by slug.

**Search - Documents index page** - `searchable_by_title.rb`
- should only use slug

**Preview links** - such as "View on website" etc.
- We will use/keep the slug value, with the assumption that it will be correct for all states.

**Landing pages** code - uses the override
- should set override via UI, which then sets the slug via the identifiable logic.

### Data decisions
1. In order to support republishing we need to backfill the slug column for **post-publication** states on all types (TBC snowflakes) - set slug to `slug_override` if override present.
2. In order to support correct preview links we need to backfill the slug column for all **post-publication** states and types (TBC snowflakes) - set slug to `slug_override` if override present.
3. In order to support keeping the live URL via the checkbox, we need to backfill the slug column for all **post-publication** states and types (TBC snowflakes) - set slug to `slug_override` if override present. Otherwise, the live slug is inadequate and publishes the edition at the wrong slug.
4. We will backfill SFT for live editions, just for data integrity. This will be a plain setting of SFT to the value of the slug, rather than generation.
5. In order to support saving with the correct slug, we need to backfill the slug column for **pre-publication** editions on all types - set slug to `slug_override` if override present. Also particularly relevant for scheduled editions.
6. We agree to not attempt to fix any non-en primary data as it works as expected. Possible improvements noted below. Most problematic behaviour is the display of the checkbox without a consequence (no actual url change); SFT is set to DOC ID after the previous migrations, which is confusing in data.
7. We will not be fixing the blank slug overrides before merging this PR (#3323), because they are handled in code and in the slug backfill migration.
8. Rely on the existing `string_for_slug` early exit in the identifiable concern and NULL all slug columns for CIP. This is a clean up and can be run after PR merge.
9. Fix code to support SO setting for creating new LP editions; no data migration to backfill.

### Actions
- [Done] Fix code to support SO setting for creating new LP editions, no data migration to backfill (DD9) - separate PR, can merge before the main migration PR.
- [Done] Backfill SFT migration.
- [Done] Generate migration to backfill all slugs. Set slug to SO where SO present for all states pre and post pub -> exclude superseded and deleted
- [Done] Wrap up current PR - migration will be a data migration on the PR
- [DONE] Prepare queries to validate data after migration
- [DONE] Prepare test plan for release, including manual testing of edge cases and known issues
- Fix for CIPs (DD8) - separate PR
- Fix known issues - particularly the removal of the "Live page" from the draft view, the preview bug, and the checkbox behaviour for non-en primaries.
- Few code improvements around non-en primaries


