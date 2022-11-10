# 1. Add View Components

Date: 2022-11-09

## Status

Accepted

## Context

Whitehall has large complex views. The established pattern is to break down the pages into many partials. Each of these partials have different functions and vary in levels of complexity. We then test these views through a combination of feature specs and view controller specs.

These specs are slow when it comes to performance. They're also often somewhat laborious to write as you are unable to isolate the section of the view that you are working on and subsequently interested in testing. As many views are large and complex, you often have to handle interactions with other applications. For example you may well have to stub out some calls to Publishing API when you only want to ensure specific fields are rendered on the page.

Often there is quite a lot of logic that sits within partials in the form of conditionals, or is pulled in from the controller or helpers.

This issue has been documented in GitHub Issue [#6954](https://github.com/alphagov/whitehall/issues/6954).

## Decision

To resolve these issues going forward, we are going to use [View Components](https://viewcomponent.org/) with the following guidelines:

1. View Components are intended for controller specific view needs, particularly to provide an easier way to test views. For components used in multiple places we have [govuk_publishing_components](https://docs.publishing.service.gov.uk/repos/govuk_publishing_components.html).

2. We consider View Components to be a part of the View layer of the application, so should only contain logic that relates to converting the input arguments into HTML. If more complex business logic is needed you can use Helper functions or add it to methods on the object passed into the component.

3. Tests for View Components should be all based on HTML output. If you need to test something more than that, it's likely not something that belongs in a View Component.

## Consequences

We will adopt View Components as described.

We will follow the [documentation](/docs/view_components.md) for implementation.
