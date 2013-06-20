# Whitehall App

"Whitehall" is the code name for the
[Inside Government](https://www.gov.uk/government/) project, which
aims to bring Government departments online in a consistent and
user-friendly manner. Documention can be found on [rdoc](http://rdoc.info/github/alphagov/whitehall/frames).

## Getting set-up locally

### Pre-requisites

* Ruby >= 1.9.2 (we have run it successfully against 1.9.2-p290 and
  1.9.3-p0)
* Rubygems and Bundler
* Mysql
* Imagemagick and Ghostscript (for generating thumbnails of uploaded
  PDFs)
* PhantomJS (for running the Javascript tests)

### Creating the mysql user

The database.yml for this project is checked into source control so
you'll need a local user with credentials that match those in
database.yml.

    mysql> grant all on `whitehall\_%`.* to whitehall@localhost identified by 'whitehall';

### Preparing the app

    $ cd /path/to/whitehall
    $ bundle install
    $ bundle exec rake db:create:all
    $ bundle exec rake db:schema:load

### Running tests locally

Three environment variables must be set up, typically:

    GOVUK_APP_DOMAIN=dev.gov.uk
    GOVUK_ASSET_ROOT=http://static.dev.gov.uk

Then run

    $ bundle exec rake

Alternatively run

    $ govuk_setenv whitehall env RAILS_ENV=test bundle exec rake

Note that using `bowler` or `foreman` will automatically use the
`govuk_setenv` method for you.

### Getting a copy of live data

There's a capistrano task which will download a dump of the mysql
database and load it on your local machine:

    cap db:import

To use it, go to the `whitehall` directory in
`alphagov-deployment` and then do:

    $ SSH_USER=$USER DEPLOY_TO=production bundle exec cap db:import

this will load data from production into your local database.

### Running the server locally

    $ script/rails s

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

# Generating the documentation

We use [YARD](https://github.com/lsegal/yard) for the documentation. You can generate a local copy with:

    yard server --reload

You can also read the docs on [rdoc.info](http://rdoc.info/github/alphagov/whitehall/frames).
