# 3. Introduce reusable content items

Date: 2024-05-28
Status: Draft

## Context

We are currently investigating how best to afford Whitehall users the ability to create reusable content items which can be included in other content pages. The reusable content items should share the same lifecycle as normal Whitehall documents, i.e. they have drafts, should be reviewed, and are then published and possibly unpublished.

We would like to share as much behaviour as appropriate between our existing `Edition` model and the new reusable content item. However, currently that is impossible to do without making reusable content items a subclass of `Edition` because of the coupling between the `Edition` and `Document` models. We would like to avoid making reusable content items a subclass of `Edition` if we can because reusable content items should not have many of the behaviours of the edition, such as having attachments or being searchable.

We are therefore planning to refactor the `Edition` and `Document` models to decouple the various `Edition` subclasses from each other and enable easy sharing of useful `Edition` behaviour with the new reusable content item types.

## Decision

We will aim to migrate Whitehall towards ![a data schema like this](0003-introduce-reusable-content-items/editions.mmd). Note that tables which are less relevant to the proposed changes are omitted from the diagram. There are two key differences between the proposed schema and the current schema.

Firstly, documents no longer have multiple editions. Instead, they have multiple versions. Each version stores all the information relating to a document as it exists on Publishing API, including its denormalised content. All metadata relating to a specific version of a document, such as the change note and the version number, are stored with the version.

Secondly, all of the document metadata that is unlikely to change between versions, such as the original publication date, access limiting, and its political status, is stored against the document. This means that editions are merely a catch all for the various types of content data that exist on Whitehall. The document and edition together represent the next version of a document. Some fields on the document, such as the scheduled publication date and the state, will be reset once a new version of the document is created.

Finally, you will have noticed that there are now two tables for implementing an email reusable content item. The reusable content items are versionable and will be able to share the behaviour with the document model via a concern.

### Workflow

The flow for creating and editing a document would look something like the below. Note that all operations that involve creating or updating a version should be transactional and should rollback if any part of the model is invalid or if Publishing API rejects the related request:

[//]: # (TODO: Turn the list below into a sequence diagram)

1. The user will select a document type and complete the document editing form as they do at present.
2. When the user submits the form, it will save a document, the edition belonging to the document, and a version. The document will be put into the draft state.
3. The version data will be sent to Publishing API so that it can be accessed on the draft content stack.
4. Subsequent edits will result in a repeat of steps 2 and 3.
5. The user submits the document for review as they usually would. The document state is updated to `submitted`.
6. Once the document has been reviewed, its state is updated to `reviewed`.
7. The user publishes the document. The document state is updated to `published` and the `published_at` column is set on the related version.
8. The publishing request is sent to Publishing API
9. When a user wants to create a new version of the document, they click on the `Create new edition` button as usual. The document state is set to `draft` and a new record is created in the `versions` table. The process continues from step 3 above.

The flow for reusable content items could be very similar, as they will be able to share much of the behaviour with the document model.

## Benefits

The schema has several benefits that align well with the GOV.UK product strategy:

- It will make it easier to consolidate other publishing applications into Whitehall because we will have more flexibility in modelling the content types. Manuals, for example, would not have to be squeezed into the existing edition model.
- Because the content data is decoupled from the concept of a GOV.UK page, it should be easier to expose for consumption by other clients in the future, such as the GOV.UK app.
- It will allow for faster evolution of the reusable content feature in the future, compared to coupling reusable content items tightly to the existing edition model.

It also has some user-facing benefits within the scope of Whitehall:

- It will allow for easier evolution of document collections, as they could be decoupled from the edition model whilst remaining versionable
- The documents listing in Whitehall will behave much more logically for users, because it will genuinely be filtering documents instead of editions

There are also a number of technical advantages:

- It will decouple content data (editions/emails), content metadata (documents/reusable content items), and workflow (versions). 
- It will allow separation of edition types into separate database tables in the future
- It will allow the easy sharing of the existing edition workflow with reusable content items, without coupling them together tightly
- It will remove the necessity to copy data from the previous edition of a document to the new version, as the data is snapshotted each time the document is sent to Publishing API instead
- Having a snapshot of the data sent to Publishing API will make it easy to republish previous editions
- The document is responsible for storing metadata about an edition, making it easier to perform operations such as "get me all the documents belonging to an organisation" or "tell me what version this document is on"

## Consequences

We'll have yet another copy of the content data, namely the version data, to keep in sync with the true content data while the document is in the draft state. However this should be fairly easy to manage because we are not synchronising data across a network partition. Once the document has been published, then the version data becomes the source of truth for the published document.

This will also be quite a costly undertaking. In order to keep costs to a minimum and avoid service interruptions, we're planning to follow an expand and contract approach. Essentially the process will be:

1. Set up a feature flag for the new document workflow
2. Add the new `versions` table and add the new columns, all set to nullable, to the `documents` table
3. Develop document resources and workers which match the behaviour of the existing edition resources and workers. Hopefully we will be able to copy and paste a substantial amount of our tests and code
4. Test our new workflows, thoroughly
5. Cut over the links in Whitehall to point to our new document resources, using our feature flag toggle

