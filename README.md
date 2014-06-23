[![Code Climate](https://codeclimate.com/github/alphagov/whitehall.png)](https://codeclimate.com/github/alphagov/whitehall)

# Whitehall App

"Whitehall" is the code name for the
[Inside Government](https://www.gov.uk/government/) project, which
aims to bring Government departments online in a consistent and
user-friendly manner. Documention can be found on [rdoc](http://rdoc.info/github/alphagov/whitehall/frames).

[Contributing guide](https://github.com/alphagov/whitehall/blob/master/docs/CONTRIBUTING.md).

## Getting set-up locally

### Pre-requisites

* Ruby >= 1.9.3
* Rubygems and Bundler
* Mysql
* Imagemagick and Ghostscript (for generating thumbnails of uploaded
  PDFs)
* xpdf
* PhantomJS (for running the Javascript tests)

### Creating the mysql user

The database.yml for this project is checked into source control so
you'll need a local user with credentials that match those in
database.yml.

    mysql> grant all on `whitehall\_%`.* to whitehall@localhost identified by 'whitehall';

### Preparing the app

    $ cd /path/to/whitehall
    $ bundle install

### Set up the database

If you wish to use a sanitized export of the production data (recommended for
internal staff) then see the alphagov/development repo for the replication script.
Once that is imported upgrade your import to the latest schema version with

    $ bundle exec rake db:migrate

Otherwise set up an empty database with:

    $ bundle exec rake db:create:all
    $ bundle exec rake db:schema:load

### Running tests locally

Two environment variables can be (optionally) set up, typically:

    GOVUK_APP_DOMAIN=dev.gov.uk
    GOVUK_ASSET_ROOT=http://static.dev.gov.uk

Then run

    $ bundle exec rake

Alternatively run

    $ govuk_setenv whitehall env RAILS_ENV=test bundle exec rake

Note that using `bowler` or `foreman` will automatically use the
`govuk_setenv` method for you.

### Running tests in parallel

The test suite can be run in parallel like so:

    rake test:in_parallel

This will automatically prepare your test database for parallel work.

### Running javascript unit tests

Javascript unit tests can be run together:

    rake test:javascript

To run individual tests or when debugging:

    ./script/javascript-test-server

And go to http://localhost:3100/test/qunit in the browser

NB: The shared mustache templates must be compiled for the tests to pass.  Take care not to commit the compiled templates to the repository.

    rake shared_mustache:compile
    rake shared_mustache:clean


### Running the server locally

    $ bundle exec rails s

Note that the app itself will respond to requests on the root URL `/` with a
routing error: to check the app works, try visiting `/government/admin`.

### Assets

GOV.UK shares assets (eg stylesheets and JavaScript) across apps using the
[`slimmer` gem](https://github.com/alphagov/slimmer) and the [`static`
app](https://github.com/alphagov/static). Ideally, you will have a copy of
`static` running locally (at http://static.dev.gov.uk by default) and that will
be used to serve shared assets. This is how things will work by default if you
are running the GOV.UK development VM with `foreman` or `bowler`.

If you are running whitehall with `bundle exec rails server` and don't want to
run a local copy of `static`, you can tell the app to use assets served
directly from the Preview environment by setting `STATIC_DEV`:

  STATIC_DEV=https://static.preview.alphagov.co.uk bundle exec rails server

If you are only working on the Whitehall admin interface, you don't need the
assets available.

## Creating new users in Production

New users will need a sign-on-o-tron account before they can access
whitehall in production.  You can create new sign-on-o-tron accounts
with the capistrano task in alphagov-deployment/sign-on-o-tron.  This
will email the new user and prompt them to create their account.

## Getting search running locally

The Whitehall app relies on
[Rummager](https://github.com/alphagov/rummager) for document
indexing, and the
[Gov.UK frontend application](https://github.com/alphagov/frontend) to
serve results.

To use a local copy of Rummager you'll need to:

* [elasticsearch](http://www.elasticsearch.org/);
* Set the environment variable `RUMMAGER_HOST` to point to the local
  instance of Rummager (e.g. `export
  RUMMAGER_HOST=http://rummager.dev` in `.powrc`);
* You'll also need to set `RUMMAGER_HOST` when using the Rummager rake
  tasks (ie. when building search index)
* Run the `rummager` and `frontend` applications to view results. You
  just need the `rummager` app to index results.

### Rebuilding whitehall search index

The whitehall search index is called 'government'. Rebuilding of the whitehall
search index can now be done with a bulk data dump. This also supports
construction of a new detatched index and seamless switchover from the
existing to the new index. There are two parts to this process, a
`rummager_export.rb` script in whitehall which dumps the whitehall data to
STDOUT, and a `bulk_load` script in rummager which accepts that data on STDIN
and loads it into rummager.

The `bulk_load` script also takes care of constructing the new offline index,
locking the index for writes (so that index write workers queue up waiting for
the new index to come online during indexing, avoiding data loss during
reindex), and seamlessly switching to the new index on completion.

One other caveat is the attachment text extraction feature. This is controlled
by the `Whitehall.extract_text_feature?` feature flag (and
WHITEHALL_EXTRACT_TEXT_FEATURE env var). You may wish to disable this feature
in development if you don't have local copies of the attachment files.

Steps:

1. Make sure you have created the rummager indices by running the
following task from the rummager repo:

    RUMMAGER_INDEX=government bundle exec rake rummager:migrate_index

2. Run the bulk export and load:

    WHITEHALL_EXTRACT_TEXT_FEATURE=false bundle exec ./script/rummager_export.rb > government.dump
    WHITEHALL_EXTRACT_TEXT_FEATURE=false bundle exec ./script/rummager_export.rb --detailed > detailed.dump

or if you want to allow the text extraction feature

    bundle exec ./script/rummager_export.rb > government.dump
    bundle exec ./script/rummager_export.rb --detailed > detailed.dump

then

    (cd ../rummager && bundle exec ./bin/bulk_load government) < government.dump
    (cd ../rummager && bundle exec ./bin/bulk_load detailed) < detailed.dump

## Search indexing paths

There are currently two paths for whitehall searchable classes to be indexed.
For a list of searchable classes, please refer to `Whitehall.edition_classes`
(in lib/whitehall.rb).

Indexing for searchable classes that inherit from `Edition` is triggered via the
`ServiceListeners::SearchIndexer` listening to the `force_publish` and `publish`
events. Since `Edition` sets the `index_after` key in its searchable options hash to
`[]`, classes inheriting from it don't trigger indexing when saved.

To trigger indexing for an instance of these classes in unit/integration tests,
create an instance in a valid publishing state ('submitted', 'rejected') and
call `EditionService.new(your_instance).perform!`.

Indexing for additional searchable classes is triggered by save. This behaviour
is defined in `Searchable.searchable_options`, where the `index_after` is set to
`:save` as a default.

To trigger indexing for an instance of these classes in unit/integration tests,
create an instance in a valid publishing state ('submitted', 'rejected') and
call `save!` on it.

## Specifying a different endpoint for the GDS Content API

Whitehall uses the GDS Content API to serve categorisation for
Detailed Guidance.

You need to set the following environment variables :-

    CONTENT_API_ENDPOINT_URL # e.g. https://contentapi.preview.alphagov.co.uk
    CONTENT_API_USERNAME
    CONTENT_API_PASSWORD

## Generating the documentation

We use [YARD](https://github.com/lsegal/yard) for the documentation. You can generate a local copy with:

    yard server --reload

You can also read the docs on [rdoc.info](http://rdoc.info/github/alphagov/whitehall/frames).


## Meaning of timestamps

### `public_timestamp`

* point in time the edition became visible to the public on the website. Updated for major changes
* used to sort documents in the atom feed
* for building `change_history` on a document
* used when comparing edition published dates in scopes on Edition (e.g. `published_before(date)`)
* set to `first_public_at` or `major_change_published_at` on every save

### `first_published_at`

* signifies when the document was 'first published', which may be before the public timestamp. E.g. transitioned content, etc.
* Either user supplied on the form, or set during publishing to the `major_change_published_at` timestamp

### `first_public_at`

* `first_published_at` on Edition
* `opening_at` on Consultation

### `major_change_published_at`

* date of the last major change. Major changes require change notes. This is decided by the user.

## Internationalisation

This is mostly standard [Rails i18n](http://guides.rubyonrails.org/i18n.html) - Translations are stored in `config/locales/`, with a `.yml` file per locale.

If translation value is missing from a locale file then the EN value will be used instead.

### Changing an existing translation key

Edit the value of EN locale, you should then _manually_ edit all other locales to set the altered translated value to be blank.

### Adding a new translation key

_Manually_ create the key in `en.yml`, with the english text.

Run a task to add that key to all other language files:
```
bundle exec rake translation:regenerate
```

#### Known issues

Running the `translation:regenerate` task may alter unrelated keys in non-EN locales, usually around "one, two, few, many" keys.

### Updating the locales files

There are rake tasks to export and import a CSV file of translations and keys. These CSV files edited to update the translation values and then imported back in into a local file.

There's no timeline for how frequently this is done, so you can expect many translation values to be missing in non EN locales.
