# 3. Build an Object Store in Whitehall to create/edit Content Blocks 

Date: 2024-06-20

## Context

The content modelling team is going to be building features to allow small reusable content objects to be included or 
embedded into other GOV.UK documents. We plan to allow consistent reuse, and edit-once update-everywhere behaviour, valuable 
during uprating for example, or when highly-duplicated content, like phone numbers and email addresses change.

We want to ensure the following:

* What we build should in theory be able to be used by any publishing app
* Content Blocks have the same publishing process as documents (drafts, 2i, authorisation etc)
* When a Content Block is updated, any documents referencing it should also be updated
* Content Blocks can be categorised with meaning (so they're not just blocks of text)
* The structure of user-facing content within Content Blocks is customisable (Examples of content are email addresses and 
tax rates, but could include much more complicated structured data. )


## Decisions and Consequences

Our first step towards building this service is to begin building the create/edit functionality.

### 1. We will build the internal user-facing service in Whitehall

All our users who may need to add/edit content blocks should have access to the Whitehall app. 

### 2. We will build it in an engine

We want to ensure that we are 'good neighbours' and can create this service in a way that isn't polluting the Whitehall
repo. We also want to build with a view to this service being used outside of Whitehall. It makes sense therefore to put 
the code in an engine separate from the rest of the repo.

### 3. We will make Edition-like behaviour into a concern

We think that Content Blocks will need some behaviour that belongs to Editions, such as being related to a Document and 
having versions/2i. But we are aware that inheriting from [Editions may cause dependency issues](https://github.com/alphagov/whitehall/pull/9180#discussion_r1650538039) as it would mean integrating with an already 
very complex and wide-ranging model and system. 
We will plan to add a new Editionable Concern that's private to us only that (for now):

* Specifies editions as the table we want to use (with self.table_name)
* Includes the Edition::Identifiable concern (which sets up the relation between the Editions and the Document)

As we progress we can then identify the behaviours we need and import them into our Edtionable concern. This will also 
have the side effect of separating out the stuff that makes our model editionable from the stuff that is specific to it 
being a content block (i.e. the JSON columns, validation etc) and will also help us identify the bare minimum of behaviour 
required to make a model behave like an edition.

### 4. The source of truth for published Blocks will be the Publishing API

The scope of this PR is to add create/edit functionality to Whitehall - our plan for the future is that when the Blocks are 
published they will be saved on the Publishing API, and the Publishing API will be the source of truth for the published 
version of Blocks. 


