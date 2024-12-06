# 5. Keep document history in sync with Publishing API via RabbitMQ

Date: 2025-11-27

## Status

Accepted

## Context

When Content Blocks created in the Content Block Manager are used in documents, we want to be able to 
record when a change to a content block triggers an update to the host document. Currently this works
like so:

* Content block is updated
* We find all documents that use the content block
* Each document is then represented to the content store with the updated content block details

This all happens in Publishing API, so there is no record in Whitehall (or any other publishing apps) 
of when a change to a document has been triggered by an update to a content block.

In order to do this, we need to update the Publishing API to record an event when a document has been
republished as a result to a change to a content block, as well as add an endpoint that allows us to 
see the events for a particular document, as well as filtering by event type and date. 

An JSON representation of event object will look like this:

```json
  {
  "id": 115,
  "action": "HostContentUpdateJob",
  "user_uid": null,
  "created_at": "2024-11-28T14:14:11.375Z",
  "updated_at": "2024-11-28T14:14:11.375Z",
  "request_id": "91cfbab2f3ff8889ff55a1c7b308d60c",
  "content_id": "0c643225-b5ae-4bd4-8c5d-9d8911433e28",
  "payload": {
    "locale": "en",
    "message": "Host content updated by content block update",
    "content_id": "0c643225-b5ae-4bd4-8c5d-9d8911433e28",
    "source_block": {
      "title": " Universal Credit Helpline ",
      "content_id": "a55a917b-740f-466b-9b31-9a9df4526de4",
    }
  }
}
```

However, we still need a way to include these events in the history. Whitehall is particularly complex as
the document history is stored in the database and [paginated][1]. This means we can't fetch the events and
weave them into the history, as we don't have the entire history to hand to ensure we add the events to the
right place within the history.

We could send a request to the Publishing API endpoint before we fetch the history and then create
new events, however:

1. This will result in an API call every time a user views a document; and
2. Carrying out an INSERT query on a GET request isn't a pattern we want to encourage

## Decision

With this in mind, we are proposing adding a new message queue consumer in Whitehall. Rabbit MQ messages
are already sent by Publishing API when documents are republished, so we can consume the existing 
`published_documents` topic. 

We will set up a queue in Whitehall to listen for events with the `host_content` key, so we only listen 
for events triggered by a content object update. We did consider setting up a brand new topic for 
when `host_content` items were updated, but the `published_documents` topic has all the information 
we need and adding a new topic would come with added complexity and  make the whole architecture more complicated.

When we receive a message, we will:

* Make a call to the `events` endpoint in Publishing API for that Content ID to find the latest 
`HostContentUpdateJob` event
* Create a new `EditorialRemark` for the latest live edition for the Whitehall Document with that 
Content ID, informing the user that the document was republished by a change to the content block

Included in the events payload will be information about the triggering content block. We did consider
sending this information as part of the payload, but the payload already includes a lot of information,
including the full document, so we concluded that we didn't want to add more information to an already
large payload. The way payloads are created is already quite complex, with a number of dependent presenter
classes, so conditionally adding more data to the payload would add complexity to the Publishing API code.

## Consequences

We will need to set up a RabbitMQ consumer in Whitehall, which will require some minor work on the 
ops side of things. It will also mean we will need to consider two-way communication between the
two applications when thinking about the publishing platform architecture.

However, once this is set up, this could potentially open up the possibility of  more two way 
communication between Whitehall and Publishing API in the future, such as feeding back to
the user when something has not published successfully.

## Alternatives considered

We could remove pagination entirely from the events, or carry out in-memory pagination, but these
options could result in performance issues, especially with older documents. We would also have to
make an API call to Publishing API each time a document is loaded, which could slow things down.

Another option could be to treat Publishing API as the source of truth for the history of a document,
but this could be a considerably more complex piece of work, which we would have limited resource for.
If we decided in the future that it was worth the investment of time, we could still do this further
down the line.

[1]: https://github.com/alphagov/whitehall/blob/main/app/models/document/paginated_timeline.rb
