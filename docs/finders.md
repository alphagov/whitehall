# Finders

## Retired finders

There used to be finders for announcements, publications and statistics in this
application, however these have been replaced by new finders rendered by
finder-frontend and published from [search-api](https://github.com/alphagov/search-api/tree/master/config/finders).

We redirect searches from the old finders to the new in order to maintain a
reasonable experience for users.  Because we need to translate some of the
query parameters, we do it in the controllers:
- [statistics](https://github.com/alphagov/whitehall/blob/master/app/controllers/statistics_controller.rb)
- [statistics announcements](https://github.com/alphagov/whitehall/blob/master/app/controllers/statistics_announcements_controller.rb)

## How to publish a finder in whitehall

**Please consider publishing new finders from [search-api](https://github.com/alphagov/search-api/tree/master/config/finders). There are [schema tests for both finders and email signup pages](https://github.com/alphagov/search-api/tree/630a6947395d11267be3cc056c7370c65bb5723e/spec/unit/content_item_publisher) there.**

Create a JSON file in [lib/finders][finders-folder]. You can base it on one of the existing files in that folder.

Double-check the filter format and document noun - the filter format is used for rummager to return the data, while the document noun is displayed to the user.

The default_documents_per_page key can be used to paginate very long finders (see [whitehall/lib/finders/case_studies.json][case-studies] for an example).

Running the [finders:publish rake task][rake-task] will publish your new finder to the [publishing-api](https://github.com/alphagov/publishing-api), and the route defined in the JSON will be taken over by [finder-frontend](https://github.com/alphagov/finder-frontend).

[finders-folder]: https://github.com/alphagov/whitehall/tree/master/lib/finders
[case-studies]: https://github.com/alphagov/whitehall/blob/master/lib/finders/case_studies.json
[rake-task]: https://github.com/alphagov/whitehall/blob/master/lib/tasks/publish_finders.rake
