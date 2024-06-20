# History Mode

Documents published by Whitehall can be marked "political". This means that when there is a change of government, the document will be associated with the government that was in power at the time it was first published. This association will be indicated by a banner on GOV.UK which warns the user that the content is considered "historical" and is therefore no longer likely to be relevant.

The `political` flag is stored as a boolean column on the `editions` database table, and its value is copied to each new edition of a document.

## The Impact of Edition Workflow on History Mode

Publishers cannot set the political flag on the first edition of a document. Instead, the political flag is set to a default value when the first edition is published based on several criteria such as the type of the document, whether it is associated with a political organisation, and whether it is associated with a government minister. This is done in the [Edition Publisher](../app/services/edition_publisher.rb). The criteria are specified in the [Political Content Identifier](../lib/political_content_identifier.rb). 

After the first edition is published, publishers can override the political flag on subsequent editions via the edition editing form. Overriding the flag requires that the publisher has managing editor or GDS editor permissions. The flag can be overridden on any type of document, irrespective of its eligibility as determined by the [Political Content Identifier](../lib/political_content_identifier.rb).

## Applying History Mode

When the government changes, it will be "closed" via the Whitehall user interface by a member of the GOV.UK content team. This will publish an update to the government content item. The content item will have its "current" value set to false, as specified in the [GovernmentPresenter](../app/presenters/publishing_api/government_presenter.rb).

Next, a developer will run the `election:republish_political_content` rake task. This task republishes all documents that have been marked as political. All documents have a link to their associated government, so Publishing API's [link expansion](https://docs.publishing.service.gov.uk/repos/publishing-api/link-expansion.html) feature will ensure that the linked government is "closed" for each document when it is re-presented to the content store. This will result in [government-frontend](https://github.com/alphagov/government-frontend) rendering the historical content banner on the documents. The banner is controlled in government frontend's [political content presenter](https://github.com/alphagov/government-frontend/blob/a643a4a9175af953e5683ee2ca5464ec384ed28e/app/presenters/content_item/political.rb#L19).



