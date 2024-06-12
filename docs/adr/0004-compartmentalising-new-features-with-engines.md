# 4. Compartmentalising new features with engines

Date: 2024-06-11

## Status

Accepted

## Context

The Content Modelling team is preparing to build an "Object Store" for users to create and manage
reusable pieces of content. To fit in with the wider Publishing team strategy, and ensure that
we're not standing up new "microservices" which need to be set up, managed and maintained, the 
Object Store will need to be built within an existing publishing app within the GOV.UK Publishing
estate.

Because the user base will likely contain non-GDS civil servants, we have made the decision to use
Whitehall as the home for the Object Store. This presents a couple of issues:

- Whitehall is a large application, with a large number of controllers, models and tests, which means code can be hard 
to find and reason about. 
- The Content Modelling team is a separate team from the Publishing Experience team (who manage Whitehall), and therefore
any new functionality needs to take into account work that is ongoing or patterns that have been adopted
- The Content Modelling team risk adding more technical debt on top of existing technical debt already present in the 
system

## Decision

To help with this, we're proposing that the Object Store is built as a "lean engine" that sits inside a `packages` 
directory, outside of the main `app` directory.

Each engine will contain its own controllers, models, views etc, as well as its own routes and tests.

The engines will then be loaded into the app on boot and mounted in the main application's routes

## Consequences

This will make the functionality the Content Modelling team add to Whitehall easier to reason about and provide a 
walled-off area of the application where the Content Modelling team will be able to add new functionality without 
worrying about affecting other parts of the application too much.

It will also provide a new pattern for any upcoming work where new, self-contained, functionality will be added to 
Whitehall, as well as provide a pattern for any improvements or refactoring further down the line to make existing
Whitehall functionality more modular.

It will make pulling in existing behaviour from the Whitehall application more difficult, but this isn't a pattern we
want to encourage, as we want to encourage a loose coupling, high-cohesion architecture.

If this pattern gains wider adoption, we may want to consider using something like [Packwerk](https://github.com/Shopify/packwerk) 
to formalise and enforce the boundaries between our "lean engines" and the main codebase.
