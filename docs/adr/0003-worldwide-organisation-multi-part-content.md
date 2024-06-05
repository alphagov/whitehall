# 3. Using multi-part content for Worldwide Organisations

Date: 2024-06-04

## Context

Whilst converting Worldwide Organisations from being non-editionable to editionable entities in Whitehall Publisher, an investigation was carried out into the best way of modelling the child pages that belong to the organisation when sent to Publishing API (and therefore Content Store).

There are two ways that a piece of content that is spread over several pages may currently be represented on GOV.UK:

1. Multiple pages (known as “parts”) on GOV.UK that are published as a single content item (i.e. all the sub-pages are in one content item). There are two existing uses of these:
   * Mainstream guides
   * Travel advice

1. Multiple pages on GOV.UK that form part of the same piece of guidance, but are published as multiple content items (i.e. each part is in a separate content items). There are many examples of this:
   * HTML attachments to Whitehall publications
   * Manuals

The rest of this section will focus on the former case where content is published as one content item, herein referred to as “multi-part content”.

### Attributes of multi-part content

* An audit history in the publishing application that spans all the parts.
* The parts are published as part of the main content item, at the same time and always have the same publishing state.
* The routes for the parts are included in the content item when presented to Publishing API. For example, in [Travel Advice Publisher](https://github.com/alphagov/travel-advice-publisher/blob/5f9bfde5c357467b41abb53eec59e6a3a30a54ba/app/presenters/edition_presenter.rb#L90).
* The routes for all parts are registered with Router API. A request to retrieve the content items for any of the parts redirects to the content item for the main page.

### Benefits of using multi-part content

* The main page and parts share a publishing state. That means that there is no need to keep the main page and parts in sync in the Publishing application. This avoids the need for the publishing application to keep the child documents in sync (e.g. as is done by [PublishingApiHtmlAttachments](https://github.com/alphagov/whitehall/blob/be9de21be77a0ce0a2c7fe64d10307d4cd82b3be/app/services/service_listeners/publishing_api_html_attachments.rb) in Whitehall).
* Don’t need to rely on link expansion for including content (e.g. page titles) from the parts in the parent page.
* Both of the above simplify the code needed in the publishing application.

### Drawbacks of multi-part content

* The main content and all the parts must have a translation for every locale they can be translated into. This means they cannot have a document translated into a second language unless all the parts are also translated. Otherwise the content item will be missing sections for some languages that may be available to users in another translation. For mainstream guides and travel advice, there are no translations and these types of content can only be published in one language.
* A large number of parts and a large amount of content within those parts would make a content item sufficiently big that the end consumer (e.g. front end application) would encounter performance issues. Using manuals as an example, they could in theory have many thousands of parts and representing all of those in one content item would make it unmanageable and lots of the data would go unused on the final page.


## Decision

Multi-part content was considered for Worldwide Organisations, by including their Worldwide Offices and Corporate Information Pages within the organisation’s content item. However Worldwide Offices and Corporate Information Pages are not required to be translated into the same language as the organisation. This stopped us from being able to turn Worldwide Organisations into multi-part content, as it meant we could not consistently provide links to all the translations and pages available within the organisation.

Instead, we opted for option 2, where all the pages are published as their own individual content items and code kept in sync. To manage the state of the child documents, we made PublishingApiHtmlAttachments more generic to handle all associated documents and renamed it [PublishingApiAssociatedDocuments](https://github.com/alphagov/whitehall/commit/425edc8f446541134a8d4b6d3c423849c8cdcaf0). By updating a model’s `associated_documents` method, other types of pages can be kept in sync with the parent document without needing any new callbacks.
