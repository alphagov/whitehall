# Whitehall

Whitehall is deployed in two modes:

- 'admin' for publishers to create and manage content (e.g. <http://whitehall-admin.dev.gov.uk/government/admin/news/new>)
- 'frontend' for rendering some legacy content (see live examples that follow)

## Live examples (frontend)

- Field of Operation: [https://www.gov.uk/government/fields-of-operation/iraq](https://www.gov.uk/government/fields-of-operation/iraq)
- World Embassies: [https://www.gov.uk/world/embassies](https://www.gov.uk/world/embassies)
- Topical Events: [https://www.gov.uk/government/topical-events/cop26](https://www.gov.uk/government/topical-events/cop26)

### Running the Application

**Use [GOV.UK Docker](https://github.com/alphagov/govuk-docker) to run any commands that follow.**

Traditionally, the two sides of Whitehall are available on different domains in development, which reflect their counterparts in production:

While this usually results in different routing behaviour, in development [all routes can be accessed from either domain](https://github.com/alphagov/whitehall/blob/main/config/routes.rb#L3-L5), although [the redirect behaviour may differ](https://github.com/alphagov/whitehall/blob/main/config/routes.rb#L25-L28).

## Nomenclature

- *Govspeak* A variation of [Markdown](https://daringfireball.net/projects/markdown) used throughout whitehall as the general publishing format

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

### Running the test suite

```
# run all the test suites
bundle exec rake
```

Javascript unit tests can also be run separately:

```
# run all the JavaScript tests
bundle exec rake jasmine
```

### Further documentation

See the [`docs/`](docs/) directory.

- [CSS](docs/css.md)
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
