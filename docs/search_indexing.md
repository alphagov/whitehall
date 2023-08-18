# Search Indexing

Whitehall interacts directly with the Search API, unlike other publishing apps which leave Publishing API to manage indexing.

The Whitehall app relies on
[Rummager](https://github.com/alphagov/rummager) for document
indexing, and the
[GOV.UK frontend application](https://github.com/alphagov/frontend) to
serve results. The Whitehall search index is called 'government'.

## Search indexing paths

There are currently two paths through which Whitehall searchable classes are indexed.
For a list of searchable classes, please refer to `RummagerPresenters.searchable_classes`
(in [app/presenters/rummager_presenters.rb](../app/presenters/rummager_presenters.rb)).
Each of these searchable models includes the [Searchable](../app/models/searchable.rb) module,
which provides the base search indexing behaviour. Bear in mind that some classes may override its methods.

### Indexing Editions

Indexing for searchable classes that inherit from `Edition` is triggered via the
`ServiceListeners::SearchIndexer` listening to the `force_publish` and `publish`
events. Since `Edition` sets the `index_after` key in its searchable options hash to
`[]`, classes inheriting from it don't trigger indexing when saved. The listeners
are configured in [config/initializers/edition_services.rb](../config/initializers/edition_services.rb).

Not all editions can be indexed (e.g. they may not be available in English - at
present Gov.UK search does not support non-English content). In cases where the
edition was previously searchable but isn't any longer, the indexer will remove
the record from the search index. It also handles edge cases such as a changing
publication type or re-indexing the contents of a document collection.

To trigger indexing for an instance of these classes in unit/integration tests,
create an instance in a valid publishing state ('submitted', 'rejected') and
call `EditionService.new(your_instance).perform!`.

### Indexing Other Content

Indexing for additional searchable classes is triggered by save. This behaviour
is defined in `Searchable.searchable_options`, where the `index_after` is set to
`:save` as a default.

To trigger indexing for an instance of these classes in unit/integration tests,
create an instance in a valid publishing state ('submitted', 'rejected') and
call `save!` on it.

## Search indexing options

The `Searchable` module provides a `searchable` class method which consuming classes
can use to configure search behaviour. The `searchable` method accepts a hash of the
fields that each class intends to send to the index, interleaved with configuration
options. These are the current options:

- `index_after`: the Active Record callback that triggers adding an item to the search index
- `unindex_after`: the Active Record callback that triggers removal from the search index
- `only`: an Active Record query that is used by the `Searchable` module to prevent indexing of records that are not part of the query result set. This query is executed in the `Searchable.can_index_in_search?` method.

## Setup search locally

The easiest way to get a search index is to replicate it from the Integration
environment.  This will not contain local changes to your content, but will be
enough for many tests. To fetch the replica, use the `replicate-elasticsearch.sh`
script from `govuk-docker` (as documented in [its README](https://github.com/alphagov/govuk-docker#how-to-replicate-data-locally)).
If you need to have local changes in your dev environment copied into the
search index, you will actually need to rebuild the search index.

Rebuilding of the 'government' search index can now be done with a bulk data dump. This also supports
construction of a new detached index and seamless switchover from the
existing to the new index. There are two parts to this process, a
`rummager_export.rb` script in Whitehall which dumps the data to
STDOUT, and a `bulk_load` script in rummager which accepts that data on STDIN
and loads it into rummager.

The `bulk_load` script also takes care of constructing the new offline index,
locking the index for writes (so that index write workers queue up waiting for
the new index to come online during indexing, avoiding data loss during
reindex), and seamlessly switching to the new index on completion.

Steps:

1. Make sure you have created the search indices by running the
following task from the search-api repo:

    ```
    SEARCH_INDEX=government bundle exec rake search:migrate_schema
    ```

2. Run the bulk export and load:

    ```
    bundle exec ./script/rummager_export.rb > government.dump
    bundle exec ./script/rummager_export.rb --detailed > detailed.dump
    ```

    then

    ```
    (cd ../rummager && bundle exec ./bin/bulk_load government) < government.dump
    (cd ../rummager && bundle exec ./bin/bulk_load detailed) < detailed.dump
    ```


