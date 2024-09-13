# History Mode

Documents published by Whitehall can be marked "political". This means that when there is a change of government, the document will be associated with the government that was in power at the time it was first published[^1]. This association will be indicated by a banner on GOV.UK which warns the user that the content is considered "historical" and is therefore no longer likely to be relevant.

The `political` flag is stored as a boolean column on the `editions` database table, and its value is copied to each new edition of a document.

## The Impact of Edition Workflow on History Mode

Publishers cannot set the political flag on the first edition of a document. Instead, the political flag is set to a default value when the first edition is published based on several criteria such as the type of the document, whether it is associated with a political organisation, and whether it is associated with a government minister. This is done in the [Edition Publisher](../app/services/edition_publisher.rb). The criteria are specified in the [Political Content Identifier](../lib/political_content_identifier.rb).

After the first edition is published, publishers can override the political flag on subsequent editions via the edition editing form. Overriding the flag requires that the publisher has managing editor or GDS editor permissions. The flag can be overridden on any type of document via the user interface, irrespective of its eligibility as determined by the [Political Content Identifier](../lib/political_content_identifier.rb). Note, however, that this doesn't necessarily mean history mode can be applied to the document ([see exclusions](#exclusions)).

## Exclusions

When an edition is sent to Publishing API, the political status of the edition is merged into the `details` object using the [political details payload builder](../app/presenters/publishing_api/payload_builder/political_details.rb).

There are some content types for which political details are not added to the payload, meaning that **history mode cannot be applied to documents of these types**.

At time of writing, the only content type excluded from history mode is:

- Fatality notices ([presenter](../app/presenters/publishing_api/fatality_notice_presenter.rb))

In the future, it would seem desirable that we re-apply the logic from the [Political Content Identifier](../lib/political_content_identifier.rb) within the [political details payload builder](../app/presenters/publishing_api/payload_builder/political_details.rb), if the eligibility rules are the same. Having the logic all in one place would make the behaviour of history mode easier to understand.

## Overrides

In some cases it is necessary to specify a government other than the default government to appear on the history mode banner. This is usually only required when content is published shortly after a change of government. In that situation, the new government may not be the government that should be associated with the document.

GDS admins and GDS editors have the option to select a particular government for content that has been marked political. If a selection is made, the government ID is stored in the `government_id` field in the `editions` database table. When a government has been specified, Whitehall will link the document to that government instead of the government that was in power on the date the content was published.

Note that should we choose to rearrange historical governments in future (e.g. specify them by election result rather than by Prime Minister) there is no provision to ensure that the correct government is maintained for content with an override in place. We elected not to implement any safeguards here as we think it is unlikely that changes to historical governments will be made in the near future.

## Applying History Mode

When the government changes, it will be "closed" via the Whitehall user interface by a member of the GOV.UK content team. This will publish an update to the government content item. The content item will have its "current" value set to false, as specified in the [GovernmentPresenter](../app/presenters/publishing_api/government_presenter.rb).

Next, a developer will run the `election:republish_political_content` rake task. This task republishes all documents that have been marked as political. All documents have a link to their associated government, so Publishing API's [link expansion](https://docs.publishing.service.gov.uk/repos/publishing-api/link-expansion.html) feature will ensure that the linked government is "closed" for each document when it is re-presented to the content store. This will result in [government-frontend](https://github.com/alphagov/government-frontend) rendering the historical content banner on the documents. The banner is controlled in government frontend's [political content presenter](https://github.com/alphagov/government-frontend/blob/a643a4a9175af953e5683ee2ca5464ec384ed28e/app/presenters/content_item/political.rb#L19).

[^1]: Some content is linked to the government that was in power on a different date to the publishing date, e.g. speeches are associated with the government in power on the date the speech was given rather than the date the speech was published on GOV.UK.
