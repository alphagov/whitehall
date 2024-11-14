# Pushing content to Publishing API

After seeding the Whitehall database, not all content will automatically be
pushed to the Publishing API. An example of this is role appointments: you might
notice that pages like the prime minister page and the ministers index look a
little bare.

The [republishing user
interface](http://whitehall-admin.dev.gov.uk/government/admin/republishing) can
be used to push the majority of content to the Publishing API:

- "All documents" - meaning all editionable content.
- "All individual pages" - certain individual pages represented in Whitehall by
presenters. This doesn't cover every presenter-based page in Whitehall, only
those listed at the top of the republishing user interface, and whose classes
are referenced in `Admin::RepublishingHelper#republishable_pages`.
- "All non-editionable content" - meaning everything other that
documents/editionable content but excluding individual pages.

## Limitations

The usefulness of the data pushed to the Publishing API is limited by the
comprehensiveness of the seed data. Seed data might need expanding if this
process doesn't provide the content needed to support specific development
needs.

As mentioned above, some individual pages/presenter-based content is currently
unsupported.

## Alternatives

An alternative is to [replicate data from
integration](https://github.com/alphagov/govuk-docker/blob/main/docs/how-tos.md#how-to-replicate-data-locally),
but this is a slow process and not always successful.
