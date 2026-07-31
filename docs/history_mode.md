# History Mode

Some content on GOV.UK is deemed "political" and needs to be understood in the context of the government that it was published under. Political content under the current government gets no special visual treatment. Political content under a closed government gets a banner stating the government that it was published under. We say that the content is in "history mode".

The term "history mode" typically extends to the process by which a government closes, the content audit that precedes or follows the close of government, and the action of republishing the content that eventually adds the banner. This process is driven by content operations and government departments, with support from developers. 

We refer to political content associated with a closed government as "historic(al)". What makes content "historic" is an interplay of fields and workflows on the edition model.

As such, "history mode" is something the public sees, a set of underlying properties of the content, and an internal process.

Much of the technical infrastructure for government changes sits with the Whitehall publisher. Whitehall hosts the "Machinery of government" tools that allow for the opening and closing of government, cabinet reshuffles, role appointments and organisational changes. 

This documentation is intended to provide a technical breakdown of what history mode means in the Whitehall application.

For the publisher guidance see [When history mode gets applied](https://guidance.publishing.service.gov.uk/writing-to-gov-uk-standards/plan-manage-content/retire-content/#when-history-mode-gets-applied).

For the 'how-to' guide, see [Support government changes](https://docs.publishing.service.gov.uk/manual/government-changes.html).

## How content is marked as political

The `political` flag is stored as a boolean column on the `editions` database table, and its value is copied to each new edition of a document.

There are three main ways in which an edition can be marked political:
- At publish time, via the [Edition Publisher](../app/services/edition_publisher.rb), based on the criteria in the [Political Content Identifier](../lib/political_content_identifier.rb)
- After publication, via the "Political" checkbox on the edition form, by a publisher with the required permissions (managing editor or above)
- Via the election rake tasks (`mark_political_content_for` and `unmark_political_content_for`) which applies the identifier logic to already published editions and their drafts. These require a republish to represent the content downstream.

Publishers cannot set the political flag on the first edition of a document. The "Political" box only shows for documents that have already been published. Reversely, the system does not attempt to reapply the `Identifier` logic once a document has been published, thus preserving future manual overrides.

> **Note:** The flag will be re-evaluated and applied to the first draft from an unpublished edition, because in this case, the edition has no "live" document.

The `PoliticalContentIdentifier` logic evaluates content based on the following criteria:
- Never political (at the time of writing, 'Fatality notices', 'Worldwide organisations', 'Official statistics', 'National statistics', 'Topical events', and 'History pages')
- Always to be marked political by the system at publication time (at the time of writing, only 'World news story')
- Conditionally political, for some types, if associated with a government minister
- Conditionally political, for some types, if associated with a political organisation

The conditionally political content types that allow being marked political by the system based on their organisation association, are:
- Call for evidence
- Consultation
- Speech
- Case study
- News articles (Press release, News story, Government response, World news story)
- Publications (CorporateReport, ImpactAssessment, PolicyPaper)

The conditionally political content types that allow being marked political by the system, based on their ministers association, are:
- Call for evidence
- Consultation
- Publication
- News articles (only Press release, News story, Government response)

We generally allow overriding the political marker via the UI checkbox for all types, except for the "never political" ones. The always political type `World news story` can still be overridden via the UI.

### Implementation details

We currently have three gates for controlling the setting of the political marker:
- Political Content Identifier (at publication time)
- Manual override (after publication time)
- Edition presenter where the political payload is added to the `details` hash

These gates are captured in the following methods:
- `history_mode_enabled?` - guards the inclusion of the flag in the presenters. Currently, it is only actively used as a conditional in the standard edition presenter. Legacy types don't use the method check, they actively include – or not – the political payload builder in the resepctive presenters; exceptions are `FatalityNotice` and `WorldwideOrganisation`. For config driven, `TopicalEvent` and `HistoryPage` do not enable history mode. By default, this method is true. To disable history mode, we override the method for legacy types that are never political or set the setting `history_mode.enabled` to false for config driven. If `history_mode_enaled?` is false, then we also make the other methods (below) false, because the political flag would never be included in payload.
- `can_be_marked_political_by_publishers?` - guards the rendering of the political controls in the admin UI, so that publishers can manually override the political flag. By default, this is true. When history mode is not enabled at all, this evaluates to false. Currently false for `FatalityNotice` and `WorldwideOrganisation` (legacy), and for `TopicalEvent` and `HistoryPage` (config driven).
- `can_be_marked_political_by_system_based_on_organisation?` - guards whether the system can set the flag at publish time if the edition is associated with any political organisations. This evaluation is also used for marking or unmarking political content via rake tasks during history mode content audits. By default, this method is false. To enable the option, we override the method for legacy types or set the setting to true for config-driven types.
- `can_be_marked_political_by_system_based_on_minister?` - guards whether the system can set the flag at publish time if the edition is associated with a minister. This evaluation is also used for marking or unmarking political content via rake tasks during history mode content audits. By default, this method is false. To enable the option, we override the method for legacy types or set the setting to true for config-driven types.
- `always_marked_political_by_system` - guards whether the system can set the flag at publish time, regardless of association with a minister or organisation. This evaluation is also used for marking or unmarking political content via rake tasks during history mode content audits. By default, this method is false. To enable the option, we override the method for legacy types or set the setting to true for config-driven types. If this method is true, the ministers and organisations methods above are false.

The various rules between the gates are also enforced in the [schema](../public/configurable-document-type.schema.json) for config-driven types.

> **Note:** HTML attachments do not implement any of these methods directly, since the methods are restricted to the edition model and its subclasses. Nonetheless, HTML attachments do support history mode. While HTML attachments do not get the political flag field in the database, they get it injected in the payload from their attachable. They will render the history mode banner just like their parent editions.

> **Note:** 'Official statistics' and 'National statistics' types have been recently changed to be "never" political, meaning that `history_mode_enabled` is `false` for them. Previously, they allowed overriding the political flag via the UI, so there is some historical data where the political flag is set to true (with the latest published edition in 2018).

## What is a historical document?

A document is considered "historical" (`historic?` in code) if it is "political" and associated with a government that is no longer "current". The "political" in this context means that the `political` flag is actually set to true in the `editions` table. For the government to be no longer current, it must have an `end_date`.

The historical status of a document is used to define permissions for History Mode.

## Permissions for political and historical content

The political UI controls consist of a checkbox for the political flag, and a conditionally rendered government association dropdown.

The following permissions apply:
- Editors cannot set or remove the political marker
- Managing editors can set or remove the political marker
- GDS Admins and Editors can set or remove the political marker, as well as change the government association for a piece of content.

When a piece of content is in "history mode", i.e., when its government is closed, the content can no longer be edited by anyone other than GDS Admins and Editors.

> **Note"** During the content auditing process following a government close, permissions may be briefly extended. Permissions around "historical" content will be updated in the [edition rules](../lib/whitehall/authority/rules/edition_rules.rb).

## How the government is determined

The following logic determines the government associated with a piece of content:
- If the government has been manually selected by a GDS admin or editor, use that government.
- If no government has been selected, then we return the government active on the date the content was either first published or updated at (with some exceptions).

> **Note**: At the time of writing, detailed guides override the government logic, practically not allowing the user to select a different government, despite the UI selector rendering.
> 
### Default government

Editions get associated with the "default" government active at the date the content was either first published or updated at (specifically, the `first_published_at` and `updated_at` timestmaps). Speeches are an exception in that they are associated with the government in power on the date the speech was given.

The `first_published_at` date is set when the content is first published (see [edition_publisher](../app/services/edition_publisher.rb)). Therefore, post-publication editions get the government at the time of publication, while first drafts get the government at the time of their last update.

Because the `first_published_at` date is usually not changed, a piece of content retains its government once it has been published. Subsequent editions of the document copy over the timestamp, thus keeping the document under the original government.

The date-based government logic runs when we present the content downstream. This enables us to change the government association when government start or end dates change, or when the `first_published_at` date is changed.

> **Note**: Whitehall offers the option of overriding the `first_published_at` date for a piece of content via the UI, which can have unintended consequences, such as the publisher locking themselves out of editing the content, due to the content entering history mode.

### Government overrides

In some cases it is necessary to specify a government other than the default government to appear on the history mode banner. This is usually only required when content is published shortly after a change of government. In that situation, the new government may not be the government that should be associated with the document.

GDS admins and GDS editors have the option to select a particular government for content that has been marked political. If a selection is made, the government ID is stored in the `government_id` field in the `editions` database table. When a government has been specified, Whitehall will link the document to that government instead of the government that was in power on the date the content was published.

Note that should we choose to rearrange historical governments in future (e.g. specify them by election result rather than by Prime Minister), there is no provision to ensure that the correct government is maintained for content with an override in place. We elected not to implement any safeguards here as we think it is unlikely that changes to historical governments will be made in the near future.

## Applying History Mode

When the government changes, it will either get an end date or be "closed" via the Whitehall user interface by a member of the GOV.UK content team. This will publish an update to the government content item. The content item will have its "current" value set to false, as specified in the [GovernmentPresenter](../app/presenters/publishing_api/government_presenter.rb).

Publishing API's [link expansion](https://docs.publishing.service.gov.uk/repos/publishing-api/link-expansion.html) feature will ensure that the linked government is "closed" for each document associated with it, when it is re-presented to the content store. This will result in [frontend](https://github.com/alphagov/frontend) rendering the historical content banner on the documents. The banner is controlled in frontend's [political content presenter](https://github.com/alphagov/frontend/blob/e4054c2e4ae0f6473acde3442ff2d6e5839bd1cf/app/models/concerns/political.rb).

There are some nuances to consider when closing a government. See [Closing a government](https://docs.publishing.service.gov.uk/manual/government-changes.html#closing-a-government) for more details. When [backdating](https://docs.publishing.service.gov.uk/manual/government-changes.html#backdating), a republishing step is required to update the government links and show the "History Mode" banner.

