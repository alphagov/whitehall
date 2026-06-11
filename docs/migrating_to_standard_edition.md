# Migrating to StandardEdition

We're gradually migrating all document types to use the StandardEdition model, as per [ADR 006: Config-driven content types](./adr/0006-config-driven-content-types.md).

## Steps to recreate a legacy content type

1. Build the legacy content type as a new config-driven format with its own configuration under `app/models/configurable_document_types`.

2. Backfill the behaviours (this is the difficult bit). You'll want to:
  - Analyse what features and behaviours exist on the legacy content type
  - Decide which should be carried over to the config-driven version
  - Consider whether any existing config-driven behaviours can be adapted for your needs. If not,
  - Build the new behaviour into StandardEdition in a generic way such that other content types could also 'opt in' to the behaviour if required 

3. "Launch" the new content type by changing the EditionWorkflowController to redirect users to the StandardEdition workflow ([example](https://github.com/alphagov/whitehall/blob/a9c1b8fbbd6256cd6145a11cbb65cf4e02b59e52/app/controllers/admin/new_document_controller.rb#L53))

## Steps to migrate a legacy content type

Use the [StandardEditionMigrator](https://github.com/alphagov/whitehall/blob/main/app/services/standard_edition_migrator.rb) to migrate both editionable and non-editionable content types.

The StandardEditionMigrator takes a 'recipe' that tells the migrator service how to build a StandardEdition from the legacy record. It also has built-in payload comparison, so that it can take the Publishing API payload of the legacy content item and 'diff' it against the StandardEdition Publishing API payload of the _converted_ content item, aborting the migration if the diff isn't as expected.

Conceptually, the diff should be empty: converting legacy content types to being config-driven is a straight up refactor that shouldn't affect the end user experience. In practice, the diffs end up being subtly different, so we have to configure the recipe to state which bits of the diff are 'expected'.

Your recipe will need to define the following methods:

- `legacy_presenter` - the presenter for the legacy content type, e.g. `PublishingApi::NewsArticlePresenter`
- `build_edition(legacy_record)` - create a StandardEdition, and assign its attributes based on what is in the legacy_record. This is the main part of the recipe. *Important*: be careful to no persist anything here as this method is also called by the preview_migration method. It is cleaner to build all of this in memory, than to make the actual changes and then rely on rolling back (which can have unexpected side effects such as updating Publishing API). Any records in memory that need saving in the real migration should be added to a `@artefacts_to_save` array, which gets persisted later on in the migration workflow. Any edition IDs on the artefacts will be automatically filled in later.

Then the following methods are all about normalisation of the payloads, for comparison purposes:

- `ignore_legacy_content_fields(content)` - defines which fields in the `details` hash of the legacy content item will not be carried over to the `details` hash of the config-driven content item. (Sometimes we consciously drop fields if they're no longer required). E.g. `content[:details].delete(:first_public_at)` (which is a legacy field no longer needed - see [this PR description](https://github.com/alphagov/whitehall/pull/10670)).
- `ignore_new_content_fields(content)` - defines which fields in the `details` hash of the config-driven content item were not present in the legacy content item. E.g. `content[:details].delete(:image)`
- `ignore_legacy_links(links)` - defines which links in the legacy content item will not be carried over to the links of the config-driven content item. E.g. `links.delete(:worldwide_organisations)`
- `ignore_new_links(links)` - defines which links in the config-driven content item were not present on the legacy content item. If no changes, just return unchanged, i.e. `links`. The same applies to all of the above arguments.

The migrator itself offers a few methods:

- `preview_migration(legacy_record, recipe)` - given an old record and a recipe, this will build the StandardEdition in memory and summarise its before-and-after payloads, including any diff.
- `migrate_existing_document(legacy_record, recipe, raise_if_payloads_differ: boolean<true>)` - overwrites an existing (legacy) Document and all of its Editions. It is intended to be called for legacy edition types such as Publication, Speech, etc. It is not compatible with other content types. Passing `raise_if_payloads_differ: true` aborts the migration if the normalised payloads don't match.
- `create_new_document(legacy_record, recipe, raise_if_payloads_differ: boolean<true>)` - creates a new Document instance and one 'published' Edition. It is intended to be called for legacy content types that don't follow the Document/Edition model, e.g. TopicalEvent, Organisation etc. It could in theory support legacy edition types too, so that we have an alternative to overwriting-in-place (could instead duplicate a given Document and then delete the old one).
- `enqueue_bulk_migration(scope, recipe, migration_method: string, raise_if_payloads_differ: boolean<true>)` - enqueues the migration of an array of legacy records, using the migration method provided ("migrate_existing_document" or "create_new_document"), using StandardEditionJob.

With that in mind, the steps for migrating a legacy content type to being config-driven is roughly as follows:

1. Choose a guinea pig legacy document, e.g. `TopicalEvent.find(123)` and use it as the basis of writing your recipe.
   `StandardEditionMigrator.preview_migration(TopicalEvent.find(123), StandardEditionMigrator::TopicalEventRecipe)`.
   Gradually build up your recipe (and associated tests) until you have a recipe that fully carries over all the relevant fields and the normalised payloads match.

2. Try migrating that one document locally (using `migrate_existing_document` or `create_new_document`).
   Manually test that the resulting StandardEdition is as you expect. If not, iterate the recipe.

3. Try the same on Integration so that you can also check the converted content item looks as it should on the frontend (you'll need to edit and republish the document to have it present to Publishing API). Compare the resulting page with how it looks on Production.

4. Try a few more examples locally, especially where you know they differ (e.g. some have translations, or 'features', or no associated organisations, etc). Keep iterating the recipe.

5. When you think the recipe is complete, try a bulk migration of everything in scope (or take it more slowly to begin with, e.g. `.limit(10)`).

6. Come up with a plan for the handful of stragglers.
   You'll likely run into a few instances that, for whatever reason, cannot be easily auto-migrated.
   See [examples of issues we ran into with NewsArticles](https://gov-uk.atlassian.net/browse/WHIT-2487?focusedCommentId=165943).
   Typically a little manual intervention is required, e.g. to patch up some data first.

8. Test running the full migration (and any manual patches) on Integration.
   If you've used `create_new_document`, you'll need to delete the old legacy records, e.g. `TopicalEvent.destroy_all`, so that you don't have two competing items per document.
   When you're down to one item per document, [bulk republish by type](https://whitehall-admin.integration.publishing.service.gov.uk/government/admin/republishing/bulk/by-type/new) to present them all downstream.
   Then keep an eye out for Sentry errors, and manually check a handful of documents to see if they've been updated as expected.

9. Repeat for Production.

10. Celebrate! 🥳 Then delete the recipe - you won't need it again.
