# Testing Guide

## Running tests locally

The test suite relies on the presence of the [govuk-content-schemas](http://github.com/alphagov/govuk-content-schemas)
repository. This should either be present at the same directory level as
the Whitehall repository, or the location must be specified explicitly via the
`GOVUK_CONTENT_SCHEMAS_PATH` environment variable.

Two other environment variables can also be (optionally) set up, typically:

    GOVUK_APP_DOMAIN=test.gov.uk
    GOVUK_ASSET_ROOT=https://static.test.gov.uk

Then run

    $ bundle exec rake

Alternatively run

    $ govuk_setenv whitehall env RAILS_ENV=test bundle exec rake

Note that using `bowler` or `foreman` will automatically use the
`govuk_setenv` method for you.

## Running tests in parallel

The test suite can be run in parallel like so:

    rake test:in_parallel

This will automatically prepare your test database for parallel work.

## Running javascript unit tests

Javascript unit tests can be run together:

    rake test:javascript

To run individual tests or when debugging:

    ./script/javascript-test-server

And go to http://localhost:3100/test/qunit in the browser

### Shared mustache templates

The shared mustache templates must be compiled for javascript unit and functional tests to pass.

    rake shared_mustache:compile
    rake shared_mustache:clean

Shared mustache templates are generated and stored in app/assets/javascripts/templates.js.

In absence of this generated template, shared mustache inlines mustache templates in `<script>` blocks
on the page, which enables developers to see changes to mustache without compiling. If this generated
template is checked-in, shared mustache uses this file instead of inlining templates. Hence, we don't
check-in this file.
