# 4. content-object-store-added-with-a-rails-engine

Date: 2024-06-27

## Status

Accepted

## Context

The content modelling team is going to be building features to allow small
reusable content objects to be included or embedded into other GOV.UK documents.
We plan to allow consistent reuse, and edit-once update-everywhere behaviour,
valuable during uprating for example, or when highly-duplicated content, like
phone numbers and email addresses change.

- What we build should in theory be able to be used by any publishing app
  Content Blocks have the same publishing process as documents (drafts, 2i,
  authorisation etc)
- When a Content Block is updated, any documents referencing it should also be
  updated
- Content Blocks can be categorised with meaning (so they're not just blocks of
  text)
- The structure of user-facing content within Content Blocks is customisable
  (Examples of content are email addresses and tax rates, but could include much
  more complicated structured data.)

### Further context

- There is a wider principle of not creating new publishing apps
- We don't have time to prototype this proof of concept in a new temporary app
- Whitehall offers behaviour that we are also likely to need, though we don't
  yet have a firm understanding of which parts
- _Contact_ Blocks already exist to allow some reuse but only within Whitehall.
  This functionality was added directly into the Whitehall app. There is an
  opportunity to extract that and bring it closer to Content reuse

## Decisions and Consequences

Our first step towards building this service is to begin building the
create/edit functionality.

1. We will build the internal user-facing service in Whitehall

    - Our users already have access to Whitehall
    - Users will be able to add/edit content blocks with new user journeys
    - We can reuse the existing infrastructure and deployment pipeline

2. We will build it in an engine

    - We want to ensure that we are 'good neighbours' and can create this
      service in a way that isn't polluting the Whitehall repo.
    - We also want to build with a view to this service being used outside of
      Whitehall. It makes sense therefore to put the code in an engine separate
from the rest of the repo.
    - We may learn that this publishing journey should be in a separate
      publishing app, at which point extraction would be easier
    - Our beta may not solve a problem in the right way, in which case deletion
      from Whitehall would be easier
    - We will test the engine approach as a viable route and set an example for
      other publishing apps who also wish to merge into Whitehall
