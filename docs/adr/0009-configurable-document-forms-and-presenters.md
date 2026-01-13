# 9. Separate configurable document forms and presenters from attribute schema

## Status

Accepted

## Context

The configurable document schema introduced in [ADR-0006](./0006-config-driven-content-types.md) and evolved in [ADR-0007](./0007-use-rails-validation-for-configurable-documents.md) and [ADR-0008](./0008-drop-json-schema-for-document-configuration.md) defined document properties under `schema.properties` and grouped UI fields via `settings.edit_screens`. This conflated three concerns:

- How publishers see and group fields in the UI (form layout and copy).
- How field values are presented to downstream systems (e.g. Publishing API payload mapping and transformations).
- How attributes and validations are defined and enforced.

This coupling made it hard to:

- Group related fields in the UI without affecting payload mapping.
- Present the same attribute differently to publishers and Publishing API. E.g Duration block in topical events holding data for `start_date` and `end_date` but needed to be presented as individual fields to publishing API.
- Flatten validations while still allowing nested form structures, leading to complex validation logic.

## Decision

We refactored the configurable document type schema to separate concerns:

1. Introduced a top-level `forms` hash describing UI forms and their fields (label, description, block type), replacing `settings.edit_screens`.
2. Replaced `schema.properties` with `schema.attributes`. The current implementation focuses on simple types (string, integer, date), moving away from nested object properties. In future, we are open to introducing more complex attribute shapes like arrays. 
3. Introduced a top-level `presenters` hash to describe how attribute values are mapped or transformed for downstream consumers (e.g. Publishing API), helping to decouple UI layout from payload shape.
4. Moved validation definitions to `schema.validations`, listing validators by attribute name. Nested validations within property definitions are no longer used in current schemas to simplify validation logic.
5. Removed custom nested block content handling for `object` types. Object attributes now use Rails' default hash implementation.
6. Updated the configurable document type JSON schema to validate the new structure and removed obsolete nested-schema code paths.

## Consequences

- All configurable document type definitions must use `schema.attributes`, `forms`, and `presenters`; `settings.edit_screens` and nested property validations are no longer supported.
- UI layout changes (field grouping, titles, descriptions, block types) can now be made in `forms` without impacting Publishing API payloads, which are defined in `presenters`.
- Validators will run against the flattened `schema.attributes` namespace. Added tests ensure nested data values stored in block content are preserved when present in the payload.
- Future support for genuinely nested attribute schemas or arrays would need a new design rather than reintroducing `object` types.
- It now becomes easier to present the same attribute differently in the UI and Publishing API (or any other consumer in future) by defining separate mappings in `forms` and `presenters`.

## Example

A configurable document type schema following the new structure will be identical to this:

```json
{
  "key": "example_document_type",
  "title": "Example Document Type",
  "description": "An example document type with configurable forms and presenters",
  "forms": {
    "documents": {
      "fields": {
        "body": {
          "title": "Body",
          "description": "The main content area",
          "block": "govspeak"
        },
        "lead_paragraph": {
          "title": "Lead Paragraph",
          "description": "A short introduction",
          "block": "default_string"
        }
      }
    }
  },
  "schema": {
    "attributes": {
      "body": {
        "type": "string"
      },
      "lead_paragraph": {
        "type": "string"
      },
    },
    "validations": {
      "presence": {
        "attributes": ["body", "lead_paragraph"]
      },
      "length": {
        "attributes": ["lead_paragraph"],
        "maximum": 255
      }
    }
  },
  "presenters": {
    "publishing_api": {
      "body": "govspeak",
      "lead_paragraph": "string"
    }
  }
}
```
