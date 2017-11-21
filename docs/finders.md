# How to publish a finder in whitehall

Create a JSON file in [lib/finders][finders-folder]. You can base it on one of the existing files in that folder.

Double-check the filter format and document noun - the filter format is used for rummager to return the data, while the document noun is displayed to the user.

The default_documents_per_page key can be used to paginate very long finders (see [whitehall/lib/finders/case_studies.json][case-studies] for an example).

Running the [finders:publish rake task][rake-task] will publish your new finder to the [publishing-api](https://github.com/alphagov/publishing-api), and the route defined in the JSON will be taken over by [finder-frontend](https://github.com/alphagov/finder-frontend).

[finders-folder]: https://github.com/alphagov/whitehall/tree/master/lib/finders
[case-studies]: https://github.com/alphagov/whitehall/blob/master/lib/finders/case_studies.json
[rake-task]: https://github.com/alphagov/whitehall/blob/master/lib/tasks/publish_finders.rake
