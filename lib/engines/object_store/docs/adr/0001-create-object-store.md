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

### 3. We will inherit from Editions

There is a lot of legacy code within Whitehall, and while sharing behaviour with Editions within Whitehall will save a 
lot of time around handling the publishing / approvals process, there is a lot of logic we either don’t want or need.

We did look into refactoring the Editions model to allow the concept of a “mini-edition” which would give us the minimum 
possible functionality, but this turned out to be a much larger job than we envisaged. With this in mind we will:

* We will Override / disable functionality we don’t need (such as search indexing) within our own model
* Add new functionality only to our model, rather than adding additional complexity to the inherited model and related concerns

#### 3a. We will put everything Content Block related into a JSON blob

To ensure extendability for Content Library Items, we're adding a new JSON field to Editions, which ensures we can make 
the schemas for Content Items as flexible as we can without having to add lots of extra fields to the table.

### 4. The source of truth for published Blocks will be the Publishing API

The scope of this PR is to add create/edit functionality to Whitehall - our plan for the future is that when the Blocks are 
published they will be saved on the Publishing API, and the Publishing API will be the source of truth for the published 
version of Blocks. 


