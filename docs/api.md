# Whitehall API

Whitehall is primarily a publishing application but it also provides an API used by some applications. This API is public and is served under [https://www.gov.uk/api/](https://www.gov.uk/api/governments).

Whitehall is not the only application to provide APIs under this path. For example, [/api/content](https://www.gov.uk/api/content/government) is served by [Content API](https://content-api.publishing.service.gov.uk) and [/api/search.json](https://www.gov.uk/api/search.json) is served by [Search API](https://docs.publishing.service.gov.uk/apis/search/search-api.html) (previously known as Rummager). [This Nginx file](https://github.com/alphagov/govuk-puppet/blob/master/modules/govuk/templates/publicapi_nginx_extra_config.erb) configures this behaviour.

The [organisations API](https://www.gov.uk/api/organisations) is now hosted by
[Collections](https://github.com/alphagov/collections).

## Endpoints

[`/api/governments`](https://www.gov.uk/api/governments) (no client available)

Lists governments from newest to oldest. Includes title, start and end dates.

[`/api/governments/:id`](https://www.gov.uk/api/governments/2015-conservative-government) (no client available)

Shows the details for a single government.

[`/api/world-locations`](https://www.gov.uk/api/world-locations) ([client](https://github.com/alphagov/gds-api-adapters/blob/0f24f4bc94ed1f8713c894b854c10ea867e6cf25/lib/gds_api/worldwide.rb#L4-L6))

Lists world locations. Includes title, web URL and country code.

[`/api/world-locations/:slug`](https://www.gov.uk/api/world-locations/afghanistan) ([client](https://github.com/alphagov/gds-api-adapters/blob/0f24f4bc94ed1f8713c894b854c10ea867e6cf25/lib/gds_api/worldwide.rb#L8-L10))

Shows the details for a single world location.

[`/api/world-locations/:slug/organisations`](https://www.gov.uk/api/world-locations/afghanistan/organisations) ([client](https://github.com/alphagov/gds-api-adapters/blob/0f24f4bc94ed1f8713c894b854c10ea867e6cf25/lib/gds_api/worldwide.rb#L12-L14))

Lists worldwide organisations relating to a world location. Includes embassies, departments, sponsor organisations and details for offices such as addresses, telephone numbers and email addresses.

[`/api/worldwide-organisations/:slug`](https://www.gov.uk/api/worldwide-organisations/department-for-international-trade-afghanistan) (no client available)

Shows the details for a single worldwide organisation.

## Consumers

Please [add your application to this list](https://github.com/alphagov/whitehall/edit/master/docs/api.md) if you're using the API.

There was [an incident](https://insidegovuk.blog.gov.uk/2017/09/27/incident-report-broken-smart-answers/) where some code was removed because these dependencies weren't known.

`/api/governments`
- [Smokey](https://github.com/alphagov/smokey/blob/f8678c4fe4805334b0ace8ddf5133be99094fc04/features/publicapi.feature#L22)

`/api/world*`
- [Contacts admin](https://github.com/alphagov/contacts-admin/blob/b1a2596e5dea6eae981bd4c758984398577fced8/app/lib/services.rb#L6)
- [Smart answers](https://github.com/alphagov/smart-answers/blob/b7be47f2d2cc7d25487e4b2c5a92ebba2f8ef317/lib/services.rb#L21)
- [Smokey](https://github.com/alphagov/smokey/blob/c9ddfbe8e00d89a306ca85098509734bb8403c3e/features/whitehall.feature#L112)
