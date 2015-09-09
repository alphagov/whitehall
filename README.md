[![Code Climate](https://codeclimate.com/github/alphagov/whitehall.png)](https://codeclimate.com/github/alphagov/whitehall)

# Whitehall App

"Whitehall" is the code name for the
[Inside Government](https://www.gov.uk/government/) project, which
aims to bring Government departments online in a consistent and
user-friendly manner. Documentation can be found on [rdoc](http://rdoc.info/github/alphagov/whitehall/frames).

[Contributing guide](https://github.com/alphagov/whitehall/blob/master/CONTRIBUTING.md).

## Getting set-up locally

### Pre-requisites

* Ruby 2.1.4
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

The test suite relies on the presence of the [govuk-content-schemas](http://github.com/alphagov/govuk-content-schemas)
repository. This should either be present at the same directory level as
the Whitehall repository, or the location must be specified explicitly via the
`GOVUK_CONTENT_SCHEMAS_PATH` environment variable.

Two other environment variables can also be (optionally) set up, typically:

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

#### Shared mustache templates

The shared mustache templates must be compiled for javascript unit and functional tests to pass.

    rake shared_mustache:compile
    rake shared_mustache:clean

Shared mustache templates are generated and stored in app/assets/javascripts/templates.js.

In absence of this generated template, shared mustache inlines mustache templates in `<script>` blocks
on the page, which enables developers to see changes to mustache without compiling. If this generated
template is checked-in, shared mustache uses this file instead of inlining templates. Hence, we don't
check-in this file.

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

  STATIC_DEV=https://assets-origin.preview.alphagov.co.uk bundle exec rails server

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
[GOV.UK frontend application](https://github.com/alphagov/frontend) to
serve results.

### Rebuilding whitehall search index

The easiest way to get a search index is to replicate it from the preview
environment.  This will not contain local changes to your content, but will be
enough for many tests.  To fetch the replica, use the "replicate-data-local"
script from the `development` project (as documented in that project's README).
If you need to have local changes in your dev environment copied into the
search index, you will actually need to rebuild the search index.

The whitehall search index is called 'government'. Rebuilding of the whitehall
search index can now be done with a bulk data dump. This also supports
construction of a new detached index and seamless switchover from the
existing to the new index. There are two parts to this process, a
`rummager_export.rb` script in whitehall which dumps the whitehall data to
STDOUT, and a `bulk_load` script in rummager which accepts that data on STDIN
and loads it into rummager.

The `bulk_load` script also takes care of constructing the new offline index,
locking the index for writes (so that index write workers queue up waiting for
the new index to come online during indexing, avoiding data loss during
reindex), and seamlessly switching to the new index on completion.

Steps:

1. Make sure you have created the rummager indices by running the
following task from the rummager repo:

    RUMMAGER_INDEX=government bundle exec rake rummager:migrate_index

2. Run the bulk export and load:

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
Detailed Guidance. In tests, this is stubbed out, see `config/initializers/content_api.rb`.

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

#### Pluralised translations

For terms that are translatable in both singular and plural forms (e.g. document.type.publication), include "one" and "other"
keys for the singular and plural translation of the term.

Note: pluralised translation terms should only ever contain these two plural form keys in en.yml, otherwise the code that
regenerates the other translation locale files will not recognise them as being plural translations and will not generate
the correct pluralisation keys for the different locales.

### Updating the locales files

There are rake tasks to export and import a CSV file of translations and keys
(provided by the [`rails_translation_manager`](https://github.com/alphagov/rails_translation_manager)
gem. These CSV files are exported, edited and then imported back as `.yml` files.

There's no timeline for how frequently this is done, so you can expect many translation values to be missing in non EN locales.
