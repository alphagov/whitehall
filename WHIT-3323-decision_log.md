# Decision Log

What data needs to be fixed before we can remove the readers for slug and slug_from_title and remove usages of slug_from_title in the codebase, except for in the checkbox?

## Code decision

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

## Data decisions [DD]
1. In order to support republishing we need to backfill the slug column for **post-publication** states on all types (TBC snowflakes) - set slug to `slug_override` if override present.
2. In order to support correct preview links we need to backfill the slug column for all **post-publication** states and types (TBC snowflakes) - set slug to `slug_override` if override present.
3. In order to support keeping the live URL via the checkbox, we need to backfill the slug column for all **post-publication** states and types (TBC snowflakes) - set slug to `slug_override` if override present. Otherwise, the live slug is inadequate and publishes the edition at the wrong slug.
4. We will backfill SFT for live editions, just for data integrity. This will be a plain setting of SFT to the value of the slug, rather than generation.
5. In order to support saving with the correct slug, we need to backfill the slug column for **pre-publication** editions on all types (TBC snowflakes) - set slug to `slug_override` if override present. Also particularly relevant for scheduled editions.
6. We agree to not attempt to fix any non-en primary data as it works as expected. Possible improvements noted below. Most problematic behaviour is the display of the checkbox without a consequence (no actual url change); SFT is set to DOC ID after the previous migrations, which is misleading.
7. We will not be fixing the blank slug overrides before merging this PR (#3323).
8. Rely on the existing `string_for_slug` early exit and NULL all slug columns for CIP. This is a clean up and can be run after PR merge.
9. Decision: Fix code to support SO setting for creating new LP editions; no data migration to backfill.

## Remaining TODO
- [Done] Fix code to support SO setting for creating new LP editions, no data migration to backfill (DD9) - separate PR, can merge -> 🥁 Show Andrew checkbox showing and breaking for LP.
- [Done] Backfill SFT migration.
- [Done] Generate migration to backfill all slugs. Set slug to SO where SO present for all states pre and post pub -> exclude superseded and deleted
- [Done] Wrap up current PR - migration will be a data migration on the PR
  - [DONE] look into `body_to_extend` usage of override / other usages
  - [SKIP] add some tests to identifiable to capture translations behaviour
  - [DONE] review the restrictions on running set_slug_from_title and whether to exclude post-publication -> done, decided to remove the restrictions.
- [DONE] Prepare queries to validate data after migration
- [DONE] Prepare test plan for release, including manual testing of edge cases and known issues
- Fix for CIPs (DD8) - separate PR
- Investigate known issues - particularly the removal of the "Live page" from the draft view, the preview bug and the checkbox behaviour for non-en primaries.
- Few code improvements around non-en primaries

## 🥁 Release

### Option 1 - merge code separate from migration
1. backfill slugs so that all slugs = SO -> this addresses all post-publication and pre-publication editions
2. time interval here -> nothing changed for post-pub; but new editions created -> slug out of sync with override on the drafts
3. merge PR

Risks:
- slug goes out of sync with the SO
- for a slug to get out of sync with the override -> an override should be set in the space between migration running and code merging
- risk is that someone might end up publishing an edition to a slug that they have not intended
- Rogue editions in the interim - published, some drafts, scheduled 
    - Scheduled - slug "abc", sft "title", SO = "override" -> publishes at "abc"
    - Drafts - publish -> goes live with non-SO slug
    - If a draft gets published, then published slug will be NOT SO -> means previews are broken

- How many editions affected by this last migration?
```sql
  SELECT id, updated_at, slug, slug_from_title, slug_override
  FROM editions
  WHERE state NOT IN ('superseded','deleted')
  AND type NOT IN ('CorporateInformationPage','LandingPage')
  AND slug_override IS NOT NULL AND slug_override != ''
  AND slug != slug_override
  ORDER BY updated_at DESC;
=> 1.7k
```
### Option 2 - merge code and migration together
🥁 Must prepare queries to validate data.

### Decision

Release the PR with a data migration, to minimize the time interval where data could go funny.

## Investigations

### SFT backfill

Check that if we were to generate SFT from title, it is the same as the slug in the DB.

```pseudo-code
- run the quivalent of the set_slug_from_title and store it
- check that the slug = SFT
```

Ran this as a pre-check and found many examples where a new SFT would not match the existing slug, especially where the live slug is suffixed with a number. Some clashing drafts may have been removed in the meantime, so a non-suffixed slug is now available.
Also found examples of unpublished editions where the slug has a `deleted-` prefix; unusual but not a concern.

![Screenshot 2026-05-05 at 18.25.22.png](Screenshot%202026-05-05%20at%2018.25.22.png)

Implication: there is no point in setting a generated SFT from generated. It's useful to have learnt that the current slugs are not an up-to-date slug "from title".
Decision: backfill SFT with the value of the slug, where the slug hasn't already been set to the override - for live data. This has already been run for pre-publication editions. [**DD4**]

🥁 TODO: Can we identify some timestamps for published editions? Anything recent?

🥁 TODO: run the same for pre-pub editions.
Q: Any implications for drafts? Scheduled editions?
A: Even if a slug had been un-idempotently generated in the last migration, for pre-publication editions, it would have only gotten set to a more advantageous, non-suffixed or less suffixed slug. It's still the case that some scheduled editions may have gone live at a slug the user did not expect.

### Post-publication states non-problematic things (non CIP, non LP, non non-en)

1. Redrafting a published edition where SO present but slug != SO, meaning slug is still title based
- new draft gets the slug and SO from published
- live page address is reported wrong (using the title based slug)
- no checkbox because current title based SFT and live slug match
- something is triggered here, and we end up with slug=SFT= SO - thought it was the checkbox but that never renders.
-> creating, drafting and publishing a new edition ignores the SO and the value of slug is sent to publishing api -> migrate all editions with a slug_override that does match slug.

Decisions: **[DD1]** & **[DD2]**

2. Are there any live editions where despite there being no override, the current db slug does not match the downstream? Do we care?
-> since nothing has been reported since the older migrations, seems reasonable to assume this is ok.
3.  Are there any live editions where despite there being no override, the current db slug would not match the SFT if we regenerated it? Do we care? Any implications for the checkbox rendering?
  - example: slug not title based, no SO, no SFT - live edition
  -> redraft
  -> SFT != live slug => show checkbox, checkbox not checked -> user has the option to set an override or use title based slug. Seems OK.

### Pre-publication states non-problematic things (non CIP, non LP, non non-en)
SFT set on all, and all created since ✅
Slug = SO where SO present for all edition before migration.

Issues:
- scheduled editions for example -> can't release the code with the reader removal without backfill, the edition would likely go live with the wrong slug.
- even subsequent edits would not update the slug because of the restrictions on callback execution.

Decision: Set slug to SO if SO present **[DD5]**

###  Non-en primaries
In the current data, no editions with non-en primary has a slug overrides set (not published, not pre-pub).
We believe it was safe what we ran and there are no issues with the as is. We basically just re-set slug to what it was and SFT to slug.

Checkbox behaviour is a bit funny (not doing what the user would expect) for non-supported locales - but there is no data fix - the fix would be using smth outside babosa and fixing data. We agree to not fix.

🪛 Possible improvement: regenerate the slugs and republish for supported locales, including live ones, so they can have nice title based slugs. How many and what timestamps are we talking, is it worth it?
We agree to not change SFT for non-en primaries, where SFT is set to DOC ID, because it doesn't break anything atm.

🪛 Possible improvement - use override to capture doc ID based slugs for non-supported locales.
We agree not to do.

Decisions: **[DD6]**

Analysis:
Draft states - for non babosa support (slug = doc ID, SFT = doc ID, SO NULL):
- further saves NO OP, no checkbox => slug = SFT = doc ID, SO NULL
- if you change the title
  - you see a checkbox and you can select to use title based slug but it will actually still generate a document ID -> MISLEADING BOX scenario 👎 slug = SFT = doc ID, SO NULL
  - if you choose the override, sets the slug=SFT=SO=DOC ID
- publishing will send slug = SFT = DOC ID, override potentially set.
- redrafting:
  - when slug = SFT = SO = DOC ID, live slug = SFT -> no checkbox, no option to change override 👎
  - when slug = SFT = DOC ID, SO NULL, live slug = SFT -> no checkbox, no option to change override 👎
=> In this case the SFT is always set to DOC ID, and will get set to that unless excluded.

Draft states for supported babosa locales (slug = doc ID, SFT = doc ID, SO NULL):
- further saves with the same title - no checkbox - but you never get an option to set the slug to title-based even if supported locale 👎 => slug = SFT = doc ID, SO NULL
- if you change the title on subsequent saves - it would show checkbox and allow you to use new title based slug (because it is supported)
  - you can opt to use live slug -> slug = SO = Doc ID, SFT title based
  - you can opt to use new title based slug -> slug = SFT = title based, SO = blank
- you can publish - no problem, possible states:
  - slug = SFT = DOC ID, SO null
  - slug = SO = DOC ID, SFT title based
  - slug = SFT = title based, SO blank
- Redraft from published
  - when slug = SFT = doc ID, SO NULL -> callback sets SFT tot title based, SFT != live slug -> checkbox shows
    - user gets option use live slug => slug = SO = doc ID, SFT remains title based
    - user gets option to use new title based slug => slug = SFT = title based, SO blank
  - where live slug = SO = DOC ID, SFT set from title - SFT callback gets called and rewrites sft (no-op) -> SFT != live slug so the checkbox displays
    - you can keep the live -> slug = SO = doc ID, SFT title based
    - you can use the new SFT -> slug = SFT = title based, SO blank
  - where live slug = SFT = title based, SO blank -> no checkbox => slug = SFT = title based, SO blank
=> only on subsequent redrafts does SFT correct itself

Live states where babosa supportd - SFT NULL, slug = DOC ID, SO NULL -> any  implications
- redraft -> Callback sets SFT to title based, SFT != live slug -> checkbox shows
  - you can keep the live -> slug = SO = doc ID, SFT title based
  - you can use the new SFT -> slug = SFT = title based, SO blank
=>In this case SFT eventually gets set to title based on the next redraft

We looked into making SFT NULL for where SFT = DOC ID, but for supported locales, further saves would not retrigger the slug set - so it would go live with slug = DOC ID and still need to get to redraft to set SFT correctly. It doesn't really speed up anything.


### CIP
They do not support foreign locales.
They are fine, we can clean them up but they really are not affected by anything atm. As long as we call slug in the important places. And they never render the checkbox so not an issue atm.

Options:
1. Introduce a `manages_own_slug?` setting for CIPs that we can use to skip the `set_slug` and `set_slug_from_title` and backfill the slug columns to NULL (all of them) to express that the data is not in use.
2. Set slug=SO to be the value of the "hardcoded" type-based slug. SFT can be set to whatever title is.
3. Rely on the existing `string_for_slug` early exit and NULL columns i.e. no need for an additional `manages_own_slug` -> Validated that a new CIP would get NULL slug in integration -> meaning that if we NULL all columns, new editions would keep them NULL.

🪛 Code cleanup: consider renaming `string_for_slug` or using manages_own_slug? in some way.

Decision: **[DD8]**

### LP

Slug is correctly set to the value of the override for all of them (from one of Ryan's migrations)
SFT set for drafts, not for live.
Creating a LP - base_path on the form now send slug_override on the edition.
Identifiable callbacks - will still call set slug and set it to SO.
Slug override is required in the model.
We tested creating a new edition - was broken because the form was still using document slug. [fixed in PR]
If you create a new draft it shows you the checkbox:
  - if you keep live URL OK
  - if you tru to use title based slugs, error from model validation which requires slug_override

Fix options: 
1. Rely on slug_override to drive the slug setting from the form 
2. Use manages_own_slug? option to skip slug setting completely
   If we use manages_own_slug -> you exit early from the set_slug:
    - CIP: override reader (return hardcoded type slug); never write the slug.
    - LP: we need both readers and writers.

🪛 We should also fix the UI to never render the checkbox - maybe introduce a setting such as `allow_reslug`. We could also conditionally not render the `_page_address_controls.html.erb` in `_standard_fields.html.erb` for LP or make its own view.

Decision: Fix code to support SO setting for creating new editions, and no data migration to backfill. **[DD9]**

### Blanks

- We need to make sure that when we set slug in the future - we still check for both NULL and '' on the SO. [Done in PR]
We should also maybe fix this is it's always NULL when saved -> won't do as part of the first PR changes.

Decision: **[DD7]**

## Knowledge base
- Republishing never touches the DB -> so no calls to `set_slug` modifying data.
- Confirmed that `title_changed?` returns true when creating a new draft from a published edition. Yes, before clicking save further.
- We now allow setting title based slugs for everything babosa supported. TODO🥁 : Noted smth about there being no way to override, not sure what that meant?

## Known issues - to investigate
- the preview bug - what does the preview button use? Is that an issue we can ever fix in draft?
- The removal of the "Live page" from the draft view - users unsure what the slug would be.
- check behaviour for alerting on slug when creating a new draft? I did not see it (maybe it never shows on draft). But I saw it on some suffixes, when the title diverged, we got --2 but there was no alert.
- the checkbox is confusing - we should tell you what the proposed url is!!
- keep the current page URL is confusing! it sounds like you should keep the current title (slug from title) not the override
- Checkbox behaviour is misleading for non-en primaries (the user can't actually set slug from title)
- have we completely removed the reslug view? Why? Will the title based reslug be enough? Would we ever need to reslug published things more programmatically?
  -> we should probably reenable this and allow changing the override instead - we currently have no way to change the override unless it's with a title based slug.

## Other clean-ups or improvements
🪛 Republishing_controller.rb -> should probably remove `document_slug` from this
🪛 `where_base_path_prefix_matches` method could use the group setting rather than the base path.
🪛 For non en primaries
- Don't use two different methods to define string_for_slug between legacy editions and config driven. We can allow title based slugs for regular editions if locale supported. We already do this for collections and consultations and CFE. I guess the other editions are not allowed to have foreign primaries. This should be a setting perhaps, and then the method called would take the setting into consideration. TODO: make a card and add it to the translations KR.
- There are no other types that support foreign primaries outside the identifies ones. Can we find a clearer way to specify which types are being considered in the `set_slug`? -> maybe use the `locale_can_be_changed?`
- Whereas before the slug was set to doc ID when we exited set_slug (there was a method on document model that set it to doc ID), what do we do now if we cannot set it? -> does it just 500? -> NO, it just saves since there is no not null constraint. Then the base_path method on edition eventually returns the document ID anyway when calling base_path for this edition. TODO: -> Should we set not null constraint on slug? Make it clearer.
- Possible improvement: regenerate the slugs and republish for supported locales, including live ones, so they can have nice title based slugs. 
- For any type that does allow non-English primary (StandardEdition, Consultation, CallForEvidence, DocumentCollection), consider passing a locale-aware babosa transliterator (e.g. `to_slug(:russian)`, `to_slug(:arabic)`) where one exists, so non-Latin-script titles can produce readable slugs rather than always falling to `document_id`.
- Possible improvement - use override to capture doc ID based slugs for non-supported locales.

🪛 Blank SOs -> ensure we store nils, not ''.
🪛 Code cleanup: consider renaming `string_for_slug` or using manages_own_slug? in some way.
🪛 We should also fix the UI to never render the checkbox for LP - maybe introduce a setting such as `allow_reslug`. We could also conditionally not render the `_page_address_controls.html.erb` in `_standard_fields.html.erb` for LP or make its own view.
