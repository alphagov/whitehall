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

## Creating new users in Production

New users will need a sign-on-o-tron account before they can access
whitehall in production.  You can create new sign-on-o-tron accounts
with the capistrano task in alphagov-deployment/sign-on-o-tron.  This
will email the new user and prompt them to create their account.

## Using local assets

* Set `GOVUK_ASSET_ROOT` to point to your local instance of the `static` app
  when running the `whitehall` app e.g. `GOVUK_ASSET_ROOT=http://static.dev`, this is set
  for you within the development VM.

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
  tasks e.g. `RUMMAGER_HOST=http://rummager.dev rake rummager:index`;
* Run the `rummager` and `frontend` applications to view results. You
  just need the `rummager` app to index results.

Note: Before you index the whitehall data, make sure you have created the
rummager indices by running the following task from the rummager repo:

  RUMMAGER_INDEX=government bundle exec rake rummager:migrate_index

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
