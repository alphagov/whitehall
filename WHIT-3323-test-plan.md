# Test

## Data tests

### SFT backfill migration

```pseudo-code
Check that slug = SFT if SO NULL or SO present but slug not yet set to SO.
```

Test both SO present and SO not present on a live edition.
- republishing a live edition
- calling .touch on a live edition
- doing a validate: false
  - trying to reslug with override
  - trying to reslug with title change and no override
  
-> plus other manual tests below

### Slug backfill migration

1. Check that wherever a SO is present, the slug = SO. For all states (bar deleted and superseded).

2. Check that slug = SFT for all drafts, where SO is not present.

This + point 1 would mean the rule applies to all states:
- (SLUG = SO (if present) || SFT) && SFT is never NULL
- SLUG is always set*

Exception*: CIPs if we later null columns for slug.

## Manual tests

1. ✅ Publication (as a regular edition, no support for non-en primary)
2. ✅ News story (as a regular standard edition, english primary locale)
3. ✅ World news story (non-en primary support, plus legacy data for supported locales)
4. [skipped] News story (non-en edition)
5. ✅ Collection (non-en edition)
6. ✅ CIPs
7. ✅ LPs

Data combinations that we need to look into:
- ✅ published with no SO
- ✅ published with SO
- ✅ published with no SO and slug is not title based e.g. suffix
- ✅ draft with SO
- ✅ draft with no SO
- ✅ withdrawn with SO
- ✅ withdrawn without SO
- ✅ withdrawn no SO and slug not title-based
- ✅ unpublished with SO
- ✅ unpublished without SO
- ✅ unpublished with a deleted prefix
- ✅ scheduled (already scheduled and newly scheduled, with/without SO)
- ✅ blank SO
- ✅ translations?

Test sequence: 
Live states:
- Republish
- Make new draft from live
- Does checkbox look correct?
- Save with "keep live slug" checked; preview
- Save with "keep new slug" checked; preview
- Revert to previous checkbox option and save; preview
- Publish; preview
- Unpublish/Withdraw; preview

Existing Draft From Published (created before migration):
- Change title, save, preview
- Does checkbox look correct?
- Save with "keep live slug" checked; preview  OK
- Save with "keep new slug" checked; preview OK
- Revert to previous checkbox option and save; preview OK
- Publish

First Draft (existing data):
- Change title, save, preview
- Does checkbox look correct?
- Save with "keep live slug" checked; preview  OK
- Save with "keep new slug" checked; preview OK
- Revert to previous checkbox option and save; preview OK
- Publish

New Created Document
- Change title, save, preview
- Does checkbox look correct?
- Save with "keep live slug" checked; preview  OK
- Save with "keep new slug" checked; preview OK
- Revert to previous checkbox option and save; preview OK
- Publish
