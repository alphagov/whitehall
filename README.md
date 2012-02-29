# Whitehall App

## Getting set-up locally

### Pre-requisites

* Ruby >= 1.9.2 (we have run it successfully against 1.9.2-p290 and 1.9.3-p0)
* Rubygems and Bundler
* Mysql
* Imagemagick and Ghostscript (for generating thumbnails of uploaded PDFs)
* PhantomJS (for running the Javascript tests)

### Creating the mysql user

The database.yml for this project is checked into source control so you'll need a local user with credentials that match those in database.yml.

    mysql> grant all on `whitehall\_%`.* to whitehall@localhost identified by 'whitehall';

### Preparing the app

    $ cd /path/to/whitehall
    $ bundle install
    $ bundle exec rake db:create:all
    $ bundle exec rake db:schema:load

### Running the server locally

    $ script/rails s

## Creating new users in Production

New users will need a sign-on-o-tron account before they can access whitehall in production.  You can create new sign-on-o-tron accounts with the capistrano task in alphagov-deployment/sign-on-o-tron.  This will email the new user and prompt them to create their account.

## Using local assets

* Set `STATIC_DEV` to point to your local instance of the `static` app when running the `whitehall` app e.g. `STATIC_DEV=http://static.dev`

## Getting search running locally

The Whitehall app relies on a separate instance of [Rummager](https://github.com/alphagov/rummager) for document search. The default (citizen) configuration is overridden by the `whitehall-rummager` project in the deployment repository.

To use a local copy of Rummager you'll need to:

* Tell Rummager to use the whitehall Solr core by setting `:path: "/solr/whitehall-rummager"` in `rummager/solr.yml`.
* Tell Rummager to listen for requests on the whitehall path prefix by setting `:path_prefix: "/government"` in `rummager/router.yml`.
* Set `RUMMAGER_HOST` to point to the local instance of Rummager (e.g. `export RUMMAGER_HOST=http://rummager.dev` in `.powrc`).
* You'll also need to set `RUMMAGER_HOST` when using the Rummager rake tasks e.g. `RUMMAGER_HOST=http://rummager.dev rake rummager:index`.
* Optional: if you want to hit the Rummager app directly from a browser (i.e. not using `Accept: application/json`), e.g. to see how the citizen app works, then you may want to set `SLIMMER_ASSET_HOST` to point to your local instance of the `static` app.

To use a local copy of Solr - see the instruction in the Rummager [README.md](https://github.com/alphagov/rummager).