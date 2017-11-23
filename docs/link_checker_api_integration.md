# Link Checker API Integrations

Links on an edition are checked using the [LinkChecker API](https://github.com/alphagov/link-checker-api/blob/master/docs/api.md). Links are checked when the `Check Links` button is clicked on the edition show page. This fires off a request to the Link Checker API using the [`/create_batch`](https://github.com/alphagov/link-checker-api/blob/master/docs/api.md#post-batch) endpoint. Once this has checked all the links present in the edition it makes a callback with a [`batch_report`](https://github.com/alphagov/link-checker-api/blob/master/docs/api.md#batchreport-entity) that gets saved as a `LinkCheckerApiReport`.

## Models

### LinkCheckerApiReports

The `LinkCheckerApiReports` are returned by the API contain a [report](https://github.com/alphagov/link-checker-api/blob/master/docs/api.md#linkreport-entity) of all the links present in an edition.

### LinkCheckerApiReportLinks

These are saved as `LinkCheckerApiReportLinks`. These contain [information](https://github.com/alphagov/link-checker-api/blob/master/docs/api.md#linkreport-entity) on the warnings or errors on the links, including a `suggested_fix`.

The `LinkCheckerApiReport` is displayed on the admin page with a list of the broken links found on the edition.