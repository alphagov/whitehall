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

These steps assume you have already recreated the legacy content type as a StandardEdition (above).

### The legacy content type already uses the Edition model 

If the legacy content type already uses the Edition model, the migration is made much simpler by use of the [StandardEditionMigrator](https://github.com/alphagov/whitehall/blob/main/app/services/standard_edition_migrator.rb) class.

The StandardEditionMigrator takes a 'recipe' ([example](https://github.com/alphagov/whitehall/pull/10814/changes#diff-08a7cc438a61f2e81368a00c4b5753e52a072e2e4ddc30563eb531d4d041f139R1)) that tells the migrator service how to map the legacy fields to the config-driven `block_content` structure (`map_legacy_fields_to_block_content`). It also has built-in payload comparison, so that it can take the Publishing API payload of the legacy content item and 'diff' it against the StandardEdition Publishing API payload of the _converted_ content item, aborting the migration if the diff isn't as expected.

Conceptually, the diff should be empty: converting legacy content types to being config-driven is a straight up refactor that shouldn't affect the end user experience. In practice, the diffs end up being subtly different, so we have to configure the recipe to state which bits of the diff are 'expected'.

The API is as follows:
- `configurable_document_type` - the config-driven 'configurable_document_type', e.g. `news_story`
- `presenter` - the presenter for the legacy content type, e.g. `PublishingApi::NewsArticlePresenter`
- `map_legacy_fields_to_block_content(edition, translation)` - defines which top level 'fields' of the legacy edition should be injected into the `block_content` of the config-driven edition. E.g. `{ "body" => translation.body }`.
- `ignore_legacy_content_fields(content)` - defines which fields in the `details` hash of the legacy content item will not be carried over to the `details` hash of the config-driven content item. (Sometimes we consciously drop fields if they're no longer required). E.g. `content[:details].delete(:first_public_at)` (which is a legacy field no longer needed - see [this PR description](https://github.com/alphagov/whitehall/pull/10670)).
- `ignore_new_content_fields(content)` - defines which fields in the `details` hash of the config-driven content item were not present in the legacy content item. E.g. `content[:details].delete(:image)`
- `ignore_legacy_links(links)` - defines which links in the legacy content item will not be carried over to the links of the config-driven content item. E.g. `links.delete(:worldwide_organisations)`
- `ignore_new_links(links)` - defines which links in the config-driven content item were not present on the legacy content item. If no changes, just return unchanged, i.e. `links`. The same applies to all of the above arguments.

The migrator itself offers two methods:

- `preview`: to see how many unique documents and editions are in scope for migration
- `migrate!`: to perform the actual migration. It takes two arguments:
  - `compare_payloads` (default `true`): runs the legacy content item through its Publishing API presenter and compares it with the converted content item through the StandardEdition presenter, raising an exception if the diff contains any differences not accounted for by the recipe.
    It is highly recommended to keep this on, but it does slow down the migration somewhat.
  - `republish` (default `true`): whether or not to republish the document after it has been migrated.
    This is a nice idea in theory, but in practice can cause [race conditions with document slugs being changed](https://gov-uk.atlassian.net/browse/WHIT-2766?focusedCommentId=165942), so use with caution.

With that in mind, the steps for migrating a legacy content type to being config-driven is roughly as follows:

1. Write a recipe and [associated tests](https://github.com/alphagov/whitehall/pull/10814/changes#diff-54659f36bda92219acd8b13bc0a48192707fcd668c591e4651ddbe5b58981a4bR1).

2. See how many unique documents and editions are in scope for migration:
   `StandardEditionMigrator.new(scope: Document.where(document_type: "NewsArticle")).preview` 

3. Try converting a legacy content item (or several) locally. Example:

   ```ruby
   array_of_one_test_document = Document.where(id: NewsArticle.where(id: 1733267).map(&:document_id))
   StandardEditionMigrator.new(scope: array_of_one_test_document).migrate!
   ```

   If you want a clearer view of what's going on, you could call the worker directly, synchronously:

   ```ruby
   StandardEditionMigratorWorker.new.perform(document.id, { "republish" => true, "compare_payloads" => true })
   ```

4. Test the converted content item to make sure it still works as expected.

5. Do the same on Integration so that you can also check the converted content item looks as it should on the frontend.
   Compare it with how it looks on Production.

6. Repeat the steps locally for more content items.
   You will likely run into edge cases you haven't factored in to your recipe, which you'll want to tweak accordingly.

   ```ruby
   StandardEditionMigrator.new(scope: Document.where(document_type: "NewsArticle").first(5000)).migrate!(republish: false, compare_payloads: true)
   ```

7. Come up with a plan for the handful of stragglers.
   You'll likely run into a few instances that, for whatever reason, cannot be easily auto-migrated.
   See [examples of issues we ran into with NewsArticles](https://gov-uk.atlassian.net/browse/WHIT-2487?focusedCommentId=165943).
   Typically a little manual intervention is required, e.g. to patch up some data, before you can then invoke the `StandardEditionMigratorWorker` to complete the migration of the document.

8. Test running the full migration (and any manual patches) on Integration.

9. Run the full migration (and any manual patches) on Production.

10. Celebrate! 🥳 Then delete the recipe - you won't need it again.

### The legacy content type does not use the Edition model

You'll need to perform a bespoke migration.
