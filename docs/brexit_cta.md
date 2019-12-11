# Brexit CTA

The Brexit CTA is custom markdown which has been introduced with the aim of providing a quick way to update Brexit messaging across multiple documents.  A need arose from content designers finding it very time consuming to update a CTA with Brexit messaging that was being used across hundreds of documents.  With the expectation that this messaging may change multiple times in the future, the Brexit CTA is a tool to update the messaging in one place and remove the need for content designers to manually update the CTA in every document that contains it.

## How the Brexit CTA works
The Brexit CTA is invoked using `$BrexitCTA` markdown in a document's body.  When it is detected by the [GovspeakHelper](../app/helpers/govspeak_helper.rb) it is replaced with a chunk of [custom CTA markdown](../app/views/documents/_brexit_cta.text.erb).

When the Brexit CTA is updated, content contains `$BrexitCTA` markdown will need to be republished in order for the changes to take effect.

## How to update the Brexit CTA
1. The Brexit CTA needs to be updated in [this partial](../app/views/documents/_brexit_cta.text.erb).
2. Once updated, deploy the change.
3. Run the following rake task to republish documents containing the Brexit CTA:
```
bundle exec rake republish_brexit_cta_documents
```
