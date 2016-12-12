[![Code Climate](https://codeclimate.com/github/alphagov/whitehall.png)](https://codeclimate.com/github/alphagov/whitehall)

# Whitehall App

"Whitehall" is the code name for the
[Inside Government](https://www.gov.uk/government/) project, which
aims to bring Government departments online in a consistent and
user-friendly manner. Documentation can be found on [rdoc](http://rdoc.info/github/alphagov/whitehall/frames).

## Nomenclature

* *Govspeak* A variation of [Markdown](https://daringfireball.net/projects/markdown)
used throughout 'Whitehall' as the general publishing format

## Technical Documentation

Whitehall is a Rails 4 app built on a MySQL database. It is deployed
in two modes, 'admin' for publishers to create and manage content and
'frontend' for rendering content under https://www.gov.uk/government. In addition to
storing and managing its own content database Whitehall also updates
various other APIs including search and is currently being migrated
towards a new publishing model utilising [Publishing
API](https://github.com/alphagov/publishing-api) and
[Content Store](https://github.com/alphagov/content-store).

## Dependencies

* Xcode (for the Command Line Tools `xcode-select --install`)
* Ruby 2.2.3
* Rubygems and Bundler
* Mysql
* Imagemagick and Ghostscript (for generating thumbnails of uploaded
  PDFs)
* xpdf (first download [XQuartz](http://www.xquartz.org/))
* PhantomJS (for running the Javascript tests)

## Running the application

The application can be started with

```
bundle exec rails s
```

Note that the application itself will respond to requests on the root URL `/` with a
routing error. To check that it works, try visiting `/government/admin` and `/government/organisations`.

Further setup instructions are available in the [detailed setup guide](docs/detailed_setup_guide.md)

## Running the test suite

See the [testing guide](docs/testing_guide.md)

## Assets

GOV.UK shares assets (eg stylesheets and JavaScript) across apps using the
[`slimmer` gem](https://github.com/alphagov/slimmer) and the [`static`
app](https://github.com/alphagov/static).

See the [local asset setup guide](docs/local_asset_setup_guide.md)

## Search

The Whitehall app relies on
[Rummager](https://github.com/alphagov/rummager) for document
indexing, and the
[GOV.UK frontend application](https://github.com/alphagov/frontend) to
serve results.

See the [search setup guide](docs/search_setup_guide.md)

## How to publish a finder in whitehall?

- You will need to create a JSON file in the whitehall repository, under [whitehall/lib/finders][finders-folder]
- You can base it on one of the existing files in that folder
- Double-check the filter format and document noun - the filter format is used for rummager to return the data, while the document noun is displayed to the user
- The default_documents_per_page key can be used to paginate very long finders (see [whitehall/lib/finders/case_studies.json][case-studies] for an example)
- Running the [finders:publish rake task][rake-task] will publish your new finder to the [publishing-api](https://github.com/alphagov/publishing-api), the the route defined in the JSON will be taken over by [finder-frontend](https://github.com/alphagov/finder-frontend)

[finders-folder]: https://github.com/alphagov/whitehall/tree/master/lib/finders
[case-studies]: https://github.com/alphagov/whitehall/blob/master/lib/finders/case_studies.json
[rake-task]: https://github.com/alphagov/whitehall/blob/master/lib/tasks/publish_finders.rake

## Other guides

[Timestamps](docs/timestamps.md)

[Internationalisation](docs/internationalisation_guide.md)

[Creating new users](docs/creating_new_users.md)

[Contributing guide](CONTRIBUTING.md)

[Migration sync checks](docs/migration_sync_checks.md)

## Generating the documentation

We use [YARD](https://github.com/lsegal/yard) for the documentation. You can generate a local copy with:

    yard server --reload

You can also read the docs on [rdoc.info](http://rdoc.info/github/alphagov/whitehall/frames).

## Licence

[MIT License](LICENCE)
