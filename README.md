# whitehall

whitehall is a Ruby on Rails content management application for content published by government departments and agencies.

## Nomenclature

- *Govspeak* A variation of [Markdown](https://daringfireball.net/projects/markdown) used throughout whitehall as the general publishing format

## Technical documentation

whitehall is a Ruby on Rails app built on a MySQL database. It is deployed in two modes: 'admin' for publishers to create and manage content and 'frontend' for rendering some content under https://www.gov.uk/government and https://www.gov.uk/world. whitehall also sends most content to the Publishing Platform and search.

Assets are currently handled by whitehall. It handles uploads, virus scanning and serving of assets. There is a current project to migrate whitehall to use [Asset Manager](http://github.com/alphagov/asset-manager).

## Dependencies

- [alphagov/asset-manager](http://github.com/alphagov/asset-manager): provides uploading for static files (migration in progress)
- [alphagov/rummager](http://github.com/alphagov/rummager): allows documents to be indexed for searching in both Finders and site search
- [alphagov/publishing-api](http://github.com/alphagov/publishing-api): documents are sent here, persisted and then requested.

## Running the application

```
$ ./startup.sh
```
If you are using the [GDS development virtual machine](https://docs.publishing.service.gov.uk/manual/get-started.html#4-boot-your-vm) then the application will be available on the host at http://whitehall-admin.dev.gov.uk/

Further setup instructions are available in the [detailed setup guide](docs/detailed_setup_guide.md).

## Running the test suite

```
$ bundle exec rake
```

## Other documentation

[Contributing guide](CONTRIBUTING.md)
[CSS](docs/css.md)
[Draft assets](docs/draft-assets.md)
[Edition workflow](docs/edition_workflow.md)
[How to publish a finder in whitehall](docs/finders.md)
[Internationalisation](docs/internationalisation_guide.md)
[JavaScript](docs/javascript.md)
[Local assets](docs/local_asset_setup_guide.md)
[Migration sync checks](docs/migration_sync_checks.md)
[Search setup guide](docs/search_setup_guide.md)
[Testing guide](docs/testing_guide.md)
[Timestamps](docs/timestamps.md)

## Generating technical documentation

We use [YARD](https://github.com/lsegal/yard) for the technical documentation. You can generate a local copy with:

    yard server --reload

You can also read the docs on [rdoc.info](http://rdoc.info/github/alphagov/whitehall/frames).

## Licence

[MIT License](LICENCE)
