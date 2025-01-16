# 5. Form-tracking

Date: 2025-01-16

## Status

Draft

## Context

There are over 150 forms in Whitehall, adding tracking to each one on a case by case basis would take incredibly long and introduce additional work that would need to be completed every time a new page is added. This document explores how we might add tracking in a generic way that could be applied across forms and across applications.


## Component level tracking

The current approach to tracking in Whitehall is to track components individually at a component level. This approach extends the tracking to each of the form inputs as well, tracking when a user selects or enters a value on a form.

When a user submits the form, tracked using the form submission button, the individual events would need to be combined in Google Tag Manager to construct the full contents of the form.

### Pros

- Simple, easy to reason about schema
- Implementation consistent with existing components
- Can break down to individual interactions when needed (do user change publication type after seeing the hint text)

### Cons

- Complexity tying a form submission/session together in GTM and is not inline with anything we currently do
  - To achieve this we need to discard all but last component tracking (in the case of a user changing their mind)

## From submission tracking

Rather than a collection of smaller objects, it would be possible to construct a larger, single data object at the time of form submission. The existing form tracker in publishing components does this, but only for a single field. For Whitehall and the other publishing applications we would need a way of iterating through the fields on a form.

The schema would either need to have the concept of a repeated field (TODO: Is this possible?) or vary the schema based on the number or fields and their names. On the client side this would be easy to do programatically, but (from what I understand) every field name across every field we would like to track would need to be manually inputted in GTM.

### Pros

- Single data object in GTM with form data

### Cons

- Schema varies across forms and ultimately a very large schema would need to defined in GTM
- Some kind of session like approach may still be needed (see below)

## Form errors and sessions

In both of the proposed methods data is logged before we know if a form is valid or not (this is because validation happens server side). Errors that result from a form submission are logged and by tying events together in a session it would be possible to identify successful form submissions either by looking at
- Form submissions that are not followed by errors
- Form submissions that do not result in a page view for the same URL
