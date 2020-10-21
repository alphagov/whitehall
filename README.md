# whitehall

whitehall is a Ruby on Rails content management application for content published by government departments and agencies.

## Nomenclature

- *Govspeak* A variation of [Markdown](https://daringfireball.net/projects/markdown) used throughout whitehall as the general publishing format

## Technical documentation

whitehall is a Ruby on Rails app built on a MySQL database. It is deployed in two modes: 'admin' for publishers to create and manage content and 'frontend' for rendering some content under https://www.gov.uk/government and https://www.gov.uk/world. whitehall also sends most content to the publishing-api and rummager.

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

### Dependent GOV.UK apps

- [alphagov/asset-manager](http://github.com/alphagov/asset-manager): provides uploading for static files
- [alphagov/publishing-api](http://github.com/alphagov/publishing-api): documents are sent here, persisted and then requested
- [alphagov/search-api](http://github.com/alphagov/search-api): allows documents to be indexed for searching in both finders and site search
- [alphagov/link-checker-api](https://github.com/alphagov/link-checker-api): checks all the links in an edition on request from the edition show page.

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
