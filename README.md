# Whitehall

Whitehall is deployed in three modes:

- 'admin' for publishers to create and manage content (e.g. <http://whitehall-admin.dev.gov.uk/government/admin/news/new>)
- 'frontend' for rendering content to the public that has yet to be migrated to using Publishing API (see live examples that follow)

## Live examples (public facing APIs)

- Governments: [https://www.gov.uk/api/governments](https://www.gov.uk/api/governments)
- World Locations: [https://www.gov.uk/api/world-locations](https://www.gov.uk/api/world-locations)

## Live examples (public facing frontend)

### CSV Previews

- CSV Preview pages: [https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/560889/LEMPRD_201610180000-CSV-GOVUK.csv/preview](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/560889/LEMPRD_201610180000-CSV-GOVUK.csv/preview)

### World Information

- Help and services around the world: [https://www.gov.uk/world](https://www.gov.uk/world)
- Worldwide Organisation pages: [https://www.gov.uk/world/organisations/british-embassy-paris](https://www.gov.uk/world/organisations/british-embassy-paris)

## Running the Application

**Use [GOV.UK Docker](https://github.com/alphagov/govuk-docker) to run any commands that follow.**

Traditionally, the two sides of Whitehall are available on different domains in development, which reflect their counterparts in production:

While this usually results in different routing behaviour, in development [all routes can be accessed from either domain](https://github.com/alphagov/whitehall/blob/main/config/routes.rb#L3-L5), although [the redirect behaviour may differ](https://github.com/alphagov/whitehall/blob/main/config/routes.rb#L25-L28).

## Nomenclature

- *Govspeak* A variation of [Markdown](https://daringfireball.net/projects/markdown) used throughout whitehall as the general publishing format

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

### Running the test suite

These commands assume you have the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) running and its binaries in your PATH.

```
# run all the test suites
govuk-docker-run bundle exec rake
```

Javascript unit tests can also be run separately:

```
# run all the JavaScript tests
govuk-docker-run bundle exec rake jasmine
```

### Further documentation

See the [`docs/`](docs/) directory.

- [CSS](docs/css.md)
- [Edition model](docs/edition_model.md)
- [Edition workflow](docs/edition_workflow.md)
- [How to publish a finder in whitehall](docs/finders.md)
- [Internationalisation](docs/internationalisation_guide.md)
- [JavaScript](docs/javascript.md)
- [Search setup guide](docs/search_setup_guide.md)
- [Timestamps](docs/timestamps.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Adding a data migration](db/data_migration/README.md)

## Licence

[MIT License](LICENCE)
