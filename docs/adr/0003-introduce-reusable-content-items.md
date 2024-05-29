# 3. Introduce reusable content items

Date: 2024-05-28
Status: Draft

## Context

We are currently investigating how best to afford Whitehall users the ability to create reusable content items which can be included in other content pages. The reusable content items should share the same lifecycle as normal Whitehall documents, i.e. they have drafts, should be reviewed, and are then published and possibly unpublished.

We would like to share as much behaviour as appropriate between our existing `Edition` model and the new reusable content item. However, that is impossible to do without making reusable content items a subclass of `Edition` because of the coupling between the `Edition` and `Document` models. We would like to avoid making reusable content items a subclass of `Edition` if we can because reusable content items should not have many of the behaviours of the edition, such as having attachments or being searchable.

We are therefore planning to refactor the `Edition` and `Document` models to enable easy sharing of useful `Edition` behaviour with the new reusable content item types.

## Decision

We will aim to migrate Whitehall towards [a data schema like this](0003-introduce-reusable-content-items/editions.mmd). Note that tables which are less relevant to the proposed changes are omitted from the diagram.

There are two key differences between the proposed schema and the current schema.

Firstly, editioning is applied at the document level, instead of solely to the document's content. In the proposed schema, each edition stores all the information relating to a document's publishing state, including its denormalised content. All metadata relating to a specific edition of a document, such as the change note and the version number, are stored with the edition. An edition closely relates to an edition on Publishing API.

Secondly, all of the document metadata that is unlikely to change between editions, such as the original publication date, access limiting, and the political status, is stored against the document. This means that the remaining `document_contents` table is merely a catch all for the various types of content data that exist on Whitehall, and could be separated into its many types in the future. The document and document content together represent the next edition of a document. Some fields on the document, such as the scheduled publication date and the state, will be reset once a new edition of the document is created.

Finally, you will have noticed that there are now two tables for implementing an email type reusable content item. The reusable content items are editionable and will be able to share the behaviour with the document model via a concern, without having to adopot all of the behaviours of the current edition.

### Workflow

The flow for creating and editing a document would look something like the below. Note that all operations that involve creating or updating a edition should be transactional and should rollback if any part of the model is invalid or if Publishing API rejects the related request:

1. The user will select a document type and complete the document editing form as they do at present.
2. When the user submits the form, it will save a document, the content belonging to the document, and an edition. The document will be put into the draft state.
3. The edition data will be sent to Publishing API so that it can be accessed on the draft content stack.
4. Subsequent edits will result in a repeat of steps 2 and 3.
5. The user submits the document for review as they usually would. The document state is updated to `submitted`.
6. Once the document has been reviewed, its state is updated to `reviewed`.
7. The user publishes the document. The document state is updated to `published` and the `published_at` column is set on the related edition.
8. The publishing request for the edition is sent to Publishing API
9. When a user wants to create a new edition of the document, they click on the `Create new edition` button as usual. The document state is set to `draft` and a new record is created in the `editions` table. The process continues from step 3 above.

[Here is the above flow as a sequence diagram](0003-introduce-reusable-content-items/document-lifecycle-sequence.mmd)

The flow for reusable content items could be very similar, as they will be able to share much of the behaviour with the document model.

## Benefits

The schema has several benefits that align well with the GOV.UK product strategy:

- It will make it easier to consolidate other publishing applications into Whitehall because we will have more flexibility in modelling the content types. Manuals, for example, would not have to be squeezed into the existing edition model.
- Because the content data is decoupled from the concept of a GOV.UK page, it should be easier to expose for consumption by other clients in the future, such as the GOV.UK app.
- It will allow for faster evolution of the reusable content feature in the future, compared to coupling reusable content items tightly to the existing edition model.

It also has some user-facing benefits within the scope of Whitehall:

- It will allow for easier evolution of document collections, as they could be decoupled from the existing edition model whilst remaining editionable
- The documents listing in Whitehall will behave much more logically for users, because it will genuinely be filtering documents instead of editions

There are also a number of technical advantages:

- It will decouple content data, content metadata (documents/reusable content items), and workflow (editions). 
- It will allow separation of document content types into separate database tables in the future.
- It will allow the easy sharing of the existing edition workflow with reusable content items, without coupling them together tightly.
- It will remove the necessity to copy data from the previous edition of a document to the new edition.
- Having a snapshot of the data sent to Publishing API will make it easy to republish previous editions.
- The document is responsible for storing metadata about piece of content, making it easier to perform operations such as "get me all the documents belonging to an organisation" or "tell me what version this document is on". Previously we would often start from an `Edition` when answering these questions, making the query awkward to write.

## Consequences

We'll have yet another copy of the content data, namely the denormalised edition data, to keep in sync with the true content data while the document is in the draft state. However this should be fairly easy to manage because we are not synchronising data across a network partition. Once the document has been published, then the edition data becomes the source of truth for the published document.

This will also be quite a costly undertaking. In order to keep costs to a minimum and avoid service interruptions, we're planning to follow a strangler fig approach. Essentially the process will be:

1. Set up a feature flag for the new document workflow.
2. Rename existing `editions` table and update the model name.
3. Add the new `editions` table and add the new columns, all set to nullable, to the `documents` table.
4. Modify the current edition-related code so that it persists the data we want in the new columns on the `documents` table and in the `editions` table, in addition to the current behaviour. We don't need to be too precise about how we do this, because we will get a chance to redesign the code in step 6.
5. Migrate any documents that haven't been edited recently so that the new columns on the `documents` table and the `editions` table have the correct data.
6. Write the document-based routes to perform only the data operations required for the new schema, introducing one new endpoint at a time. Introduce each route into production using the feature flag, testing each one thoroughly. Once each document route is live, we can remove the corresponding edition route. During this step it will be important to ensure that code is designed to enable easy sharing of editionable behaviour.
7. Once all the routes have been replaced, we can remove any unused code, data and schema items relating to the previous edition model. We can also introduce not null constraints on the documents table where appropriate.

I'd imagine the time required to do this will be somewhere between a quarter and two quarters, depending on resource available. It's a lot of resource, but given Whitehall has been around for over a decade with the current model, this isn't surprising.

Despite the cost, I think this will be worth doing. Approximately 15% of the development tickets worked on by the Whitehall Experience team since the start of Q2 2023 have related to or been impacted by the edition model in some way. If we could reduce the time taken to deliver such tickets by, say, a third, that would free up a lot of time to spend on other priorities.

This doesn't include the large effort conducted by the Publishing Platform team to make Worldwide Organisations editionable, which would have been a much smaller effort if the suggested schema has existed, as there would have been no need to do a full migration into the `editions` table. We also know we're about to start work on reusable content items, which is likely to be a big investment in its own right and could be significantly reduced in cost if the proposed model is in place.

## Still to decide

- What should the names of these things be? Documents and editions is okay, but I'm not sure what reusable content items and document content should be called. 
