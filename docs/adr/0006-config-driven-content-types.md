# 6. Config driven content types

## Status

Accepted

There has been a subsequent change of implementation approach, from defining document types as JSON to defining them in Ruby. See [7. Active Record Configurable Document Types](0007-active-record-configurable-document-types.md) for more details.

## Context

## Terminology

- “Content type” (also ‘format’): publisher/end-user facing concept (in publishing app UI, guidance, and on GOV.UK).
- “Document type”: largely synonymous with the above, but used by developers, often used alongside a “schema name”. The former is a subset of the latter. References to both concepts are hard-wired into lots of areas of code across GOV.UK, so are difficult to change. Examples of document types and schema names:
   - Document type: “press_release”, schema name: “news_article”.
   - Document type: “cma_case”, schema name: “specialist_document”.
- “Content type” is the [preferred naming](https://docs.google.com/presentation/d/1wbEU8n_AvEFyi230ahUR_AI51NVbU-rex3Po68aTMO4/edit?slide=id.g1bd648f90ee_0_8#slide=id.g1bd648f90ee_0_8) according to our publishers survey.

## Grouped content types by purpose

The [Content Types Discovery](https://docs.google.com/presentation/d/1wbEU8n_AvEFyi230ahUR_AI51NVbU-rex3Po68aTMO4/edit?slide=id.g18f26f180b0_0_4) work established a classification of content types by purpose. The relevant ones for Whitehall are as follows:

- Standard – simple, no phasing/chapters/routing (e.g. news article, guidance)
- Multi-part – connected chapters/sequences (e.g. manuals)
- Navigation – organisational or navigational pages
- Phased – changes over time (e.g. consultations, statistics)

Looking at some existing content types in Whitehall: “News Story”, “World News Story”, “Press Release” and “Government Response” are all subtypes of “News Article”. If we are to follow the recommendations in the discovery, these would all be consolidated under the “Standard” content type. The proposals in this ADR don’t commit us to going all the way on that, but do enable us to in future if we wish.

## Current situation in Whitehall

At present, each content type has its own model, controller, and custom suites of tests (unit, integration, request and feature tests). This has led to significant configuration drift over time, where similar types diverge subtly without clear reasoning.

Indeed, even understanding the total number of content types and their behaviours requires deep code inspection, because:

- Behaviours are not encapsulated within models
- Layers of inheritance, mixed-in modules, and overridden methods obscure the picture
- Behaviour is often defined indirectly (e.g. via pub/sub callbacks)

This complexity makes reasoning, maintenance, and iteration difficult. Even adding a basic new content type requires writing a lot of boilerplate code, and supporting more substantial emerging user needs (such as multi-platform support or more flexible page templates) would be a significant architectural challenge that would introduce a lot of additional complexity onto an already tech-debt-laden system.

## Decision

The config-driven architecture (first touched on in [ADR 005](https://github.com/alphagov/whitehall/blob/main/docs/adr/0005-use-json-schema-for-flexible-page-schemas.md)) will be the primary means in which we represent all content types in Whitehall. We intend to migrate all existing content types to this new architecture, starting with the migration of News Articles. The approach has already been [spiked in #10425](https://github.com/alphagov/whitehall/pull/10425).

### Key elements

#### 1. Content Type Configurations

We will begin with a one-to-one mapping of content subtype to JSON file. For example, a news_story.json config file for News Story content types. This could later be consolidated into a generic ‘standard document’ config file if we wish.

We expect to have to retain the idea of News Stories, Press Releases and so on being subtypes of “News Article”. This could be inferred by folder placement (e.g. news_article/news_story.json) or config (e.g. "ancestor": "news_article"). This ADR doesn’t prescribe which approach to take, but we should be consistent in how we apply it to other subtypes going forward.

Each config file will define allowed behaviours (e.g. via booleans such as allows_file_attachments: true) as well as field definitions (just a govspeak body for news articles, but additional fields for other types, e.g. ‘delivered on date / time’ for Speech). These fields will be stored as a hash in the existing edition_translations.flexible_page_content JSONB column.

#### 2. Core Model

For now, all config-driven content types will use the same base model: ConfigDrivenContentType (which will inherit from Edition). In time, we may introduce an intermediary layer of inheritance, e.g. StandardContentType, if there is sufficient difference in core behaviour that we need different base models for the config-driven content types.

This model will include all allowable behaviour modules (attachments, translations, etc) and use the override methods defined in each module (informed by an equivalent boolean in the config file) to enable or disable the behaviour. For example, allows_file_attachments? would be overridden to return true or false depending on a boolean in the config such as allows_file_attachments: true.

We therefore would continue to persist associations using the existing architecture for the time being (via table-level properties on the Edition table), rather than in the new JSON field.

#### 3. Principles

We will abide by the following principles whilst developing this config-driven architecture:

- Configuration over convention
   - Behaviour is discoverable from a single JSON file, not scattered across code. Every property will be explicitly defined in every JSON file: nothing inferred.
   - The “[Proposal to simplify translations in Whitehall](https://docs.google.com/document/d/1ma5gzJU8EUl3Yo6J6z3XzkEdpqUVLPLPEoSPff9ZduE/edit?tab=t.0)” document outlines a real world problem with the current implementation: there are several formats that don’t explicitly opt out of ‘translations’ or ‘foreign language only’ features: they just don’t override the default value (false) for them. If a format hasn't been opted in, it's not clear whether that was deliberate, or simply forgotten. Explicit configuration provides immediate clarity and a clear commit history audit trail.
- No concrete references to specific content types
   - Despite the multiple layers of inheritance and the composability of modules alongside allow_x? override methods, Whitehall is riddled with [examples](https://github.com/alphagov/whitehall/blob/06da2ff2029df4ef74ded21e50adf0f47a1a1e4e/app/components/admin/edition_images/lead_image_component.rb#L46-L52) of concrete references to specific content types in places quite far away from the model itself. We aim to remove all such occurrences through migrating to the config-driven approach.
- High quality, maintainable test coverage, without needless repetition
   - We want to avoid writing feature tests, integration tests and the like, for each individual content type. Instead, we want to:
      - Test each module of behaviour in isolation, and that opting in via the config file sets the allows_x? override method as it should.
      - Have schema validation that ensures each config file is valid (i.e. has all the properties it ought to, and no unknown properties).
      - Have a basic double-ledger test for each content type, whereby we write a test that checks the values for important properties in the config (e.g. a test that news_story.json has a property allows_file_attachments: true, if that’s deemed to be a behaviour too important not to enforce with a test).

#### 4. Backwards compatibility

We need to be sending exactly the same payload to Publishing API (and in turn, Content Store and the frontend rendering apps) as we have been doing in the lead up to config-driven document types. This is to enable us to work at our own pace and gain the value of the refactor more quickly.

We do, however, need to be able to easily change the payload in response to changing business requirements such as flexible pages and multi-platform support. Without prescribing the exact detail of such a system, this ADR suggests that config-driven content types could have a shared generic presenter, called at the point of publishing a document’s payload to Publishing API.

In that hypothetical system, by default, we would be sending a genericised or ‘flexible’ payload to Publishing API, and the applications downstream of Publishing API may not know how to render such a payload. We could then build a ‘legacy presenter’ to take a generic/flexible payload and map it to the existing (‘legacy’) payload structure, so that as far as Publishing API, Content Store and Frontend are concerned, nothing has changed. We could maintain this low-cost backwards compatibility solution for as long as necessary, only omitting the call to the legacy presenter when ready.

#### 5. Forwards compatibility

When schema changes are required to the content types, we need to make sure that we can release those migrations safely without breaking existing content.

It is outside of the scope of this ADR to propose a full plan for how these schema migrations will be managed, but generally we need to be mindful of the fact that removing an attribute from the schema, or changing its “key”, will make any existing content which has data stored for any such attributes incompatible with the schema. Similarly, adding a new attribute with the “required” property would make existing content invalid.

We therefore need to apply the same rigour that we would with normal database migrations to our schema migrations, but we won’t have MySQL’s built-in integrity checks to help us. We should consider building some tooling to support these migrations, such as:

1. a tool that parses all of the schemas during CI and prevents/warns about dangerous changes
2. a bulk update tool that can help us set or change data for an attribute across multiple content items during a migration

## Consequences

## Benefits

- Clarity: behaviour is declared in one place per content type.
- Consistency: reduces accidental divergence between similar types.
- Maintainability: easier to add, merge, or retire types.
- Composability: new types can easily be created from a selection of existing behaviours
- Scalability: enables more flexibility in Whitehall’s output, to accommodate multi platform requirements, personalisation, and publisher-led layouts.

## Risks / Trade-offs

- Still tied to legacy Edition table and architecture for now.
- Requires discipline to resist adding bespoke code as we migrate ever more specialised content types.
- Unknowns around the performance of querying JSON fields. (Will be stress tested early in the migration plan below).
- Unknowns around how we would accommodate adding, renaming, reordering or removing ‘blocks’/’fields’ in future.
   - Assumption: we would handle this very much like we would if we were adding, renaming or removing top-level fields on legacy content types. I.e. a database migration, perhaps with additional tooling - see [Forwards Compatibility](#5-forwards-compatibility).

## Migration Plan (Phase 1: News Articles)

1. Implement ConfigDrivenContentType base class and JSON config loader.
2. Create configs for all news article subtypes.
3. Import and opt into all the relevant behaviour modules.
4. Support wider functionality such as search, document collections, bulk republishing.
5. Verify behaviour parity via unit and double-ledger tests.
6. Map block/field data to current Publishing API payload via LegacyPresenter.
7. Migrate legacy News Articles from Content Publisher into Whitehall, into this new format. (Double benefit of unblocking Content Publisher retirement and giving Whitehall enough data to stress-test the new config-driven architecture).
8. Redirect the news article creation workflow to silently switch the publisher over to the config-driven architecture approach.
9. Migrate Whitehall’s existing/legacy news articles
10. Review and write up a plan for rolling out to the other standard content types.
