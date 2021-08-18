# whitehall

### Running the Application

**Use GOV.UK Docker to run any commands that follow.**

Whitehall is deployed in two modes:

- 'admin' for publishers to create and manage content (e.g. <http://whitehall-admin.dev.gov.uk/government/admin/news/new>)
- 'frontend' for rendering content (eg: <http://www.gov.uk/government/get-involved>, <https://www.gov.uk/world>)

Traditionally, the two sides of Whitehall are available on different domains in development, which reflect their counterparts in production:

While this usually results in different routing behaviour, in development [all routes can be accessed from either domain](https://github.com/alphagov/whitehall/blob/main/config/routes.rb#L3-L5), although [the redirect behaviour may differ](https://github.com/alphagov/whitehall/blob/main/config/routes.rb#L25-L28).

## Nomenclature

- *Govspeak* A variation of [Markdown](https://daringfireball.net/projects/markdown) used throughout whitehall as the general publishing format

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.
### Shared mustache templates

The shared mustache templates must be compiled for JavaScript and functional tests to pass.

```
bundle exec rake shared_mustache:compile
bundle exec rake shared_mustache:clean
```

Shared mustache templates are generated and stored in app/assets/javascripts/templates.js.

In absence of this generated template, shared mustache inlines mustache templates in `<script>` blocks on the page, which enables developers to see changes to mustache without compiling. If this generated template is checked-in, shared mustache uses this file instead of inlining templates. Hence, we don't check-in this file.

### Running the test suite

```
# run all the test suites
bundle exec rake
```

Javascript unit tests can also be run separately:

```
# run all the JavaScript tests
bundle exec rake test:javascript
```

To run or debug individual JavaScript tests, try viewing them in your browser. Start the app as you would normally, and then go to `/teaspoon/default`.

### Further documentation

See the [`docs/`](docs/) directory.

- [Contributing guide](CONTRIBUTING.md)
- [CSS](docs/css.md)
- [Edition workflow](docs/edition_workflow.md)
- [How to publish a finder in whitehall](docs/finders.md)
- [Internationalisation](docs/internationalisation_guide.md)
- [JavaScript](docs/javascript.md)
- [Search setup guide](docs/search_setup_guide.md)
- [Timestamps](docs/timestamps.md)
- [Troubleshooting](docs/troubleshooting.md)

## Licence

[MIT License](LICENCE)
