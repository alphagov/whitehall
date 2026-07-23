# History Mode

Some content on GOV.UK is deemed "political" and needs to be understood in the context of the government that it was published under. Political content first published[^1] under the current government gets no special visual treatment. Political content under a closed government gets a banner stating the government that it was published under. We say that the content is in "history mode".

The term "history mode" typically extends to the process by which a government closes, the content audit that precedes or follows the close of government, and the action of republishing the content that eventually adds the banner. This process is driven by content operations and government departments, with support from developers. As such, "history mode" is something the public sees, a "property"[^2] of the content, and an internal process. 

We also refer to political content associated with a closed government as "historic(al)" content, colloquially, and in code.

Much of the technical infrastructure for government changes sits with the Whitehall publisher. Whitehall hosts the "Machinery of government" tools that allow for the opening and closing of government, cabinet reshuffles, role appointments and organisational changes. 

This documentation is intended to provide a technical breakdown of what history mode means in the Whitehall application.

For the publisher guidance see [When history mode gets applied](https://guidance.publishing.service.gov.uk/writing-to-gov-uk-standards/plan-manage-content/retire-content/#when-history-mode-gets-applied).

For the 'how-to' guide, see [Support government changes](https://docs.publishing.service.gov.uk/manual/government-changes.html).

## How content is marked as political

The `political` flag is stored as a boolean column on the `editions` database table, and its value is copied to each new edition of a document.

There are two ways in which an edition can be marked political:
- At publish time, via the [Edition Publisher](../app/services/edition_publisher.rb), based on the criteria in the [Political Content Identifier](../lib/political_content_identifier.rb)
- After publication, via the "Political" checkbox on the edition form, by a publisher with the required permissions (managing editor or above)

Publishers cannot set the political flag on the first edition of a document. The "Political" box only shows for documents that have already been published. Reversely, the system does not attempt to reapply the Identifier logic once a document has been published, thus preserving future manual overrides.

The `PoliticalContentIdentifier` logic classifies content into three groups:
- Always political (at the time of writing, only 'World news story')
- Never political (at the time of writing 'Fatality notices', 'Official Statistics', and 'National Statistics')
- Conditionally political, if associated with a government minister, or if the content is "potentially political" by its type and also associated with a political organisation.

Not all content types support a ministers association, so they won't qualify by that criteria. Equally, not all content types support an organisations association, so they won't qualify by that criteria either. 

The potentially political content types that require an organisation association to be marked as political by the system are:
- CallForEvidence
- Consultation
- Speech
- Case study
- News articles (Press release, News story, Government response, World news story)
- Publications (CorporateReport, ImpactAssessment, PolicyPaper)

### Exceptions and ambiguities

In practice, content is truly "never" political if it's both considered "never political" by the [Political Content Identifier](../lib/political_content_identifier.rb) logic, and if it never renders the political checkbox for the manual override. Reversely, always political content can also be unmarked by publishers. At the moment, the two conditions are not unified in the code, meaning that users can still manually override what is otherwise signaled as "never political" or "always political" by the system.

The UI checkbox shows if the setting `can_be_marked_political?` is true. Which is currently not enabled for 'Fatality Notices', 'Worldwide organisations', 'Topical events', and 'History pages'.

[TBC] Are these exempt from the system setting?

We currently have 3 gates of where the political content might be set, overridden, or dropped:
- Political Content Identifier (at publish time)
- Manual override (after publication time)
- Item presenter where the political flag needs to be added to the payload

Currently, the presenters send the payload for:
- Call for evidence
- Consultation
- Detailed guide
- Document collection
- Publication 
- Speech
- Standard edition
- Statistical data set

A special case are HTML attachments, which do not get a political flag field in the database, but they do get it injected in the payload from their attachable, and thus render the government banner.

[TBC] At the time of writing, the true exceptions to this rule are:
- Fatality notices
- Worldwide Organisations
- Topical Events
- History pages


[previous]
When an edition is sent to Publishing API, the political status of the edition is merged into the `details` object using the [political details payload builder](../app/presenters/publishing_api/payload_builder/political_details.rb).

There are some content types for which political details are not added to the payload, meaning that **history mode cannot be applied to documents of these types**.

At time of writing, the only content type excluded from history mode is:

- Fatality notices ([presenter](../app/presenters/publishing_api/fatality_notice_presenter.rb))

In the future, it would seem desirable that we re-apply the logic from the [Political Content Identifier](../lib/political_content_identifier.rb) within the [political details payload builder](../app/presenters/publishing_api/payload_builder/political_details.rb), if the eligibility rules are the same. Having the logic all in one place would make the behaviour of history mode easier to understand.


## Permissions

The political UI controls consist of a checkbox for the political flag, and a conditionally rendered government association dropdown.

The following permissions apply:
- Editors cannot set or remove the political marker
- Managing editors can set or remove the political marker
- GDS Admins and Editors can set or remove the political marker, as well as change the government association for a piece of content.

When a piece of content is in "history mode", i.e., when its government is closed, the content can no longer be edited by anyone other than GDS Admins and Editors. 

Note that during the content auditing process following a government close, permissions may be briefly extended. Permissions around "historical" content will be updated in the [edition rules](../lib/whitehall/authority/rules/edition_rules.rb)


## Government Overrides

In some cases it is necessary to specify a government other than the default government to appear on the history mode banner. This is usually only required when content is published shortly after a change of government. In that situation, the new government may not be the government that should be associated with the document.

GDS admins and GDS editors have the option to select a particular government for content that has been marked political. If a selection is made, the government ID is stored in the `government_id` field in the `editions` database table. When a government has been specified, Whitehall will link the document to that government instead of the government that was in power on the date the content was published.

Note that should we choose to rearrange historical governments in future (e.g. specify them by election result rather than by Prime Minister) there is no provision to ensure that the correct government is maintained for content with an override in place. We elected not to implement any safeguards here as we think it is unlikely that changes to historical governments will be made in the near future.

## Applying History Mode

When the government changes, it will be "closed" via the Whitehall user interface by a member of the GOV.UK content team. This will publish an update to the government content item. The content item will have its "current" value set to false, as specified in the [GovernmentPresenter](../app/presenters/publishing_api/government_presenter.rb).

Publishing API's [link expansion](https://docs.publishing.service.gov.uk/repos/publishing-api/link-expansion.html) feature will ensure that the linked government is "closed" for each document associated with it, when it is re-presented to the content store. This will result in [frontend](https://github.com/alphagov/frontend) rendering the historical content banner on the documents. The banner is controlled in frontend's [political content presenter](https://github.com/alphagov/frontend/blob/e4054c2e4ae0f6473acde3442ff2d6e5839bd1cf/app/models/concerns/political.rb).

[^1]: Some content is linked to the government that was in power on a different date to the publishing date, e.g. speeches are associated with the government in power on the date the speech was given rather than the date the speech was published on GOV.UK.
[^2]: In the sense that there is an underlying property of the data that qualifies the content as "in history mode", specifically it being "political", and associated with a closed government. 
