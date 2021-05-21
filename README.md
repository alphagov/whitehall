# whitehall

Whitehall is deployed in two modes:

- 'admin' for publishers to create and manage content; and
- 'frontend' for rendering some content under https://www.gov.uk/government and https://www.gov.uk/world.

## Running the Application

Startup [using govuk-docker](https://github.com/alphagov/govuk-docker).

There are two different views within this App, a *Publishing view* and a *Site view*. Once running, whitehall does not have an index, some suggested starting pages are below:

Publishing view:
- <http://whitehall-admin.dev.gov.uk/government/admin/news/new>

Site view:
- <http://whitehall-frontend.dev.gov.uk/government/get-involved>

Some pages will need data locally to display, whitehall uses mySQL. You'll need to gain relevant permissions to access data from AWS

- [Get setup with AWS access](https://docs.publishing.service.gov.uk/manual/get-started.html)

- Once completed [a guide to install local data on whitehall can be found here](https://github.com/alphagov/govuk-docker/blob/master/docs/how-tos.md#how-to-replicate-data-locally)

## Nomenclature

- *Govspeak* A variation of [Markdown](https://daringfireball.net/projects/markdown) used throughout whitehall as the general publishing format

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

## Dependencies

### Local development dependencies

This application uses Ruby dependencies installed via [Bundler][] and [npm
dependencies][npm] installed via [Yarn][].

These can be installed with:

```
bundle install
yarn install
```

[Bundler]: https://classic.yarnpkg.com/en/docs/install/
[npm]: https://www.npmjs.com/
[Yarn]: https://classic.yarnpkg.com/en/docs/install/

## Other documentation

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
