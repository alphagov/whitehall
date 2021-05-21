# whitehall

Whitehall is deployed in two modes:

- 'admin' for publishers to create and manage content; and
- 'frontend' for rendering some content under https://www.gov.uk/government and https://www.gov.uk/world.

## Nomenclature

- *Govspeak* A variation of [Markdown](https://daringfireball.net/projects/markdown) used throughout whitehall as the general publishing format

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the Application

Traditionally, the two sides of Whitehall are available on different domains in development, which reflect their counterparts in production:

- admin side e.g. <http://whitehall-admin.dev.gov.uk/government/admin/news/new>

- frontend side e.g. <http://whitehall-frontend.dev.gov.uk/government/get-involved>

While this usually results in different routing behaviour, in development [all routes can be accessed from either domain](https://github.com/alphagov/whitehall/blob/530abc13018145a6efe6ab4a19f6210254e2e304/config/routes.rb#L3-L5), although [the redirect behaviour may differ](https://github.com/alphagov/whitehall/blob/530abc13018145a6efe6ab4a19f6210254e2e304/config/routes.rb#L25-L28).

### Further documentation

See the [`docs/`](docs/) directory.

- [Contributing guide](CONTRIBUTING.md)
- [CSS](docs/css.md)
- [Edition workflow](docs/edition_workflow.md)
- [How to publish a finder in whitehall](docs/finders.md)
- [Internationalisation](docs/internationalisation_guide.md)
- [JavaScript](docs/javascript.md)
- [Search setup guide](docs/search_setup_guide.md)
- [Testing guide](docs/testing_guide.md)
- [Timestamps](docs/timestamps.md)

## Generating technical documentation

We use [YARD](https://github.com/lsegal/yard) for the technical documentation. You can generate a local copy with:

    yard server --reload

You can also read the docs on [rdoc.info](http://rdoc.info/github/alphagov/whitehall/frames).

## Licence

[MIT License](LICENCE)
