# Content Block Manager

Content Block Manager is used by publishers to create and manage "blocks" on content
that can be reused and kept up to date across various pieces of content.

## Where is it?

Content Block Manager is a "mini application" within [Whitehall](https://github.com/alphagov/whitehall),
packaged as a Rails Engine.

All the code for Content Block Manager is is located at
[lib/engines/content_block_manager](https://github.com/alphagov/whitehall/tree/main/lib/engines/content_block_manager)
within Whitehall.

## Running the Application

As the application is contained within Whitehall, the app can be run by [following the
same instructions to run Whitehall](https://github.com/alphagov/whitehall?tab=readme-ov-file#running-the-application).

Once the application is up and running, Content Block Manager will be available at http://whitehall-admin.dev.gov.uk/content-block-manager.

## Running the test suite

The test suite runs within the main Whitehall test suite, but if you want to run Content Block Manager
tests on their own, you can run the following:

### Unit tests

```bash
govuk-docker-run bundle exec rails test lib/engines/content_block_manager/test/**/*
```

### Cucumber tests

```bash
govuk-docker-run env RAILS_ENV=test bundle exec cucumber lib/engines/content_block_manager/features/
```

### Jasmine tests

Currently not possible

## Why is is packaged this way?

The rationale for packaging the code in this way can be found in the Whitehall ADR - [ADR-0004](https://github.com/alphagov/whitehall/blob/main/docs/adr/0004-content-object-store-added-with-a-rails-engine.md)

### Further documentation

See the [`docs/`](https://github.com/alphagov/whitehall/blob/main/lib/engines/content_block_manager/docs) directory.
