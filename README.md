# Whitehall

Whitehall is deployed in two modes:

- 'admin' for publishers to create and manage content (e.g. <http://whitehall-admin.dev.gov.uk/government/admin/news/new>)
- 'frontend' for rendering some legacy content (see live examples that follow)

## Live examples (public facing frontend)

### Finders

- Non-English finders: [https://www.gov.uk/government/publications.de](https://www.gov.uk/government/publications.de)

### Fields of Operation

- Fields of Operation list: [https://www.gov.uk/government/fields-of-operation](https://www.gov.uk/government/fields-of-operation)
- Field of Operation pages: [https://www.gov.uk/government/fields-of-operation/iraq](https://www.gov.uk/government/fields-of-operation/iraq)

### Government Information

- How government works page: [https://www.gov.uk/government/how-government-works](https://www.gov.uk/government/how-government-works)
- Current ministers list: [https://www.gov.uk/government/ministers](https://www.gov.uk/government/ministers)
- Past Chancellors of the Exchequer list: [https://www.gov.uk/government/history/past-chancellors](https://www.gov.uk/government/history/past-chancellors)
- Past Foreign Secretaries list: [https://www.gov.uk/government/history/past-foreign-secretaries](https://www.gov.uk/government/history/past-foreign-secretaries)
- Past Prime Ministers list: [https://www.gov.uk/government/history/past-prime-ministers](https://www.gov.uk/government/history/past-prime-ministers)
- Past Prime Minister pages: [https://www.gov.uk/government/history/past-prime-ministers/clement-attlee](https://www.gov.uk/government/history/past-prime-ministers/clement-attlee)

### World Information

- Help and services around the world: [https://www.gov.uk/world](https://www.gov.uk/world)
- Non-English World Location News pages: [https://www.gov.uk/world/brazil/news.pt](https://www.gov.uk/world/brazil/news.pt)
- UK International Delegation pages: [https://www.gov.uk/world/uk-delegation-to-council-of-europe](https://www.gov.uk/world/uk-delegation-to-council-of-europe)
- World Embassies list: [https://www.gov.uk/world/embassies](https://www.gov.uk/world/embassies)
- Worldwide Organisation pages: [https://www.gov.uk/world/organisations/british-embassy-paris](https://www.gov.uk/world/organisations/british-embassy-paris)

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
