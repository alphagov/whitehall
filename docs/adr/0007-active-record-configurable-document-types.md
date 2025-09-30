# 7. Refactor configurable document types to Active Record models

Date: 2025-10-02

## Context

We have started an effort to migrate all of Whitehall's document type configuration to a new abstraction which we are referring to as "config-driven content types". See [0006-config-driven-content-types.md](0006-config-driven-content-types.md) for more information.

Our original plan was to use JSON files to configure the document types, and to use JSON schema to configure the attributes related to each document (see [0005-use-json-schema-for-flexible-page-schemas.md](0005-use-json-schema-for-flexible-page-schemas.md)). However, the choice of JSON has proven to be insufficient to express the variety of behaviours that are required for Whitehall document types. It has also proven difficult to integrate the JSON schema behaviours with Ruby on Rails. All aspects of the Rails framework are very tightly coupled to Active Record, so tasks such as validating the document using JSON schema and then presenting any errors to the user became very difficult.

## Decision

We are going to refactor the existing configurable document implementation so that each document type is configured using an Active Record model.

## Consequences

- We will be able to add new features for configurable documents more quickly, as we will have the full feature-set of Rails at our disposal
- We will have to manage the risk that Whitehall maintenance remains difficult because each document type becomes unique. It will be much easier to add one-off features to document types when they are encoded in Ruby. One of the motivations for choosing JSON in the first place was to constrain the complexity of the system, so we will need to ensure that features for configurable documents are implemented in a reusable and composable manner.
