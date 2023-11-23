# How does Whitehall handle contact expansion in govspeak?

See also:

- [Proposal: How to handle dynamic govspeak elements (2014)](https://gov-uk.atlassian.net/wiki/spaces/WH/pages/17989791/Proposal+How+to+handle+dynamic+govspeak+elements) 
- [https://github.com/alphagov/whitehall/pull/2009](https://github.com/alphagov/whitehall/pull/2009) 

## Context

Whitehall allows publishers to reference contact information inline in govspeak, using syntax like this:

```
You can send a letter to the Government Digital Service at:

[Contact:1858]
```

This will be automatically expanded to the full address (The White Chapel Building, 10 Whitechapel High Street…) when the document is published.

If the user puts an ID that doesn't exist in the [Contact:XXX] expression, it will be silently removed from the output.

Any documents referencing this contact will be automatically republished whenever the contact is updated.

If a contact is deleted, documents referencing that contact won't be automatically updated, but when they're next published they'll switch to silently removing the contact block, as the ID is no longer referenced. This is probably a bug, but it hasn't been noticed because contacts are rarely deleted.

A similar approach is used to allow editions to link to other editions which are still in draft, and automatically handle updates to the URL path (/ slug).

## How does a document know which contacts it references?

There's a [ContactsExtractor](https://github.com/alphagov/whitehall/blob/3b933df9ae/lib/govspeak/contacts_extractor.rb#L12) class, which scans govspeak for elements matching the [/\[Contact:([0-9]+)\]/](https://github.com/alphagov/whitehall/blob/3b933df9ae/lib/govspeak/embedded_content_patterns.rb#L3) regex.

This is used to pull out a list of dependant contacts, which are stored on the Edition by the [EditionDependenciesPopulator](https://github.com/alphagov/whitehall/blob/3b933df9ae/app/services/service_listeners/edition_dependencies_populator.rb#L10). This code is [subscribed to publish / withdraw events](https://github.com/alphagov/whitehall/blob/3b933df9ae/config/initializers/edition_services.rb#L21-L23).

When an Edition is published, we call [render\_embedded\_contacts](https://github.com/alphagov/whitehall/blob/3b933df9ae/app/helpers/govspeak_helper.rb#L119C23-L119C23), which [finds the dependencies again](https://github.com/alphagov/whitehall/blob/3b933df9ae/app/helpers/govspeak_helper.rb#L167-L173) and expands them.

Ultimately, the Edition model has [a has\_many relationship with Contacts through an EditionDependencies table](https://github.com/alphagov/whitehall/blob/3b933df9ae/app/models/edition.rb#L45C13-L45C35).

## How does the code know to republish dependant documents when a contact changes?

There's a [Dependable module](https://github.com/alphagov/whitehall/blob/3b933df9ae/lib/dependable.rb#L1), which adds a "has\_many :dependent\_editions" relation to models.

The Contact model [has an after\_update callback](https://github.com/alphagov/whitehall/blob/3b933df9ae/app/models/contact.rb#L17C17-L17C45) which calls [republish\_dependent\_editions](https://github.com/alphagov/whitehall/blob/3b933df9ae/lib/dependable.rb#L12-L19) (provided by the Dependable module). This sends each dependent edition to publishing-api, which involves expanding the contacts in govspeak.

## Notes on this architecture

1. Changes to contacts which trigger updates to dependent Editions don't appear in the history of those Editions - there are no change notes, or records of any kind showing the change.
2. Contacts themselves aren't edition-able, so there's no way to create a circular dependency (although there is for linked draft editions, but that's a separate topic)

