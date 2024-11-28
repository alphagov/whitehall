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

With this in mind, we need to find some way of enabling two-way communication between Publishing API
and Whitehall, so publishers can see when content blocks that their document uses have been updated.

There are two potential solutions, each with their own advantages and drawbacks:

### Solution 1: Interweave content block updates in with Whitehall's history

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

When a document is loaded in Whitehall, we could then call the API and weave these events into the timeline.
However, this is complicated by the fact that Whitehall's document history is paginated, so we won't necessarily
have the full Whitehall history at load time and won't necessarily know the full date window of Publishing events
to fetch. For example:

A document has the following range of event datetimes for the first page:

```
2024-03-23T09:23:00
.....
2023-12-10T11:13:00
```

And a range of event datetimes for the second page

```
2023-11-22T12:27:00
...
2023-09-12T15:17:00
```

If we have an event that happens between `2023-11-22T12:27:00` (the newest event for the second page) and 
`2023-12-10T11:13:00` (the oldest event for the first page) it won't get picked up because it doesn't occur 
within that range of events.

We could get around this by making a request to get the datetime of the first event on the next page, thus
giving us a full window of dates to interleave, but this makes an already [complex class][1] harder to understand.

Additionally, making an extra database query and calling out to an API endpoint could have performance impacts.

It's also worth considering that currently, we display 10 events on each "page" of results. If we are interleaving
new events with each page of results, this could be confusing for the user if they only expect to see 10 results.

Another solution could be sending a request to the Publishing API endpoint before we fetch the history and then creating
new events, however:

1. This will result in an API call every time a user views a document; and
2. Carrying out an INSERT query on a GET request isn't a pattern we want to encourage

## Solution 2: Add a new message consumer in Whitehall

This would involve setting up a new RabbitMQ message topic in Publishing API that sends 
messages when a content block update triggers a change to a document. This would be a brand new 
topic that contains a thin message that includes the `content_id` of the document that has
been updated, when it was updated and information about the content block that triggered the update:

```json
{
  "locale": "en",
  "content_id": "0c643225-b5ae-4bd4-8c5d-9d8911433e28",
  "updated_at": "2024-11-28T14:14:11.375Z",
  "content_block": {
    "title": " Universal Credit Helpline ",
    "content_id": "a55a917b-740f-466b-9b31-9a9df4526de4",
  }
}
```

We will then set up a queue in Whitehall to listen for events with the relevant key. When an
event has been received, we create a new event in Whitehall (something like an `EditorialRemark`)
for the document with that `content_id`.

This will require a bit more work on both the Publishing API and Whitehall side and will involve
a degree of opacity (as well as extra lines on an architecture graph), but this will avoid complexity
when rendering the history of the document.

## Decision

We propose going with Solution 2.

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
