# 5. Use JSON Schema for flexible page schemas

Date: 2025-06-16

## Status

Accepted

## Context

We are adding a feature to Whitehall which will allow us to define content types using a schema file. We need to select a format for the schema.

We could build our own schema format and encode it in a popular serialization format such as JSON, YAML, or TOML. This would give us complete control over the schema so that we can support unknown future use cases.

Alternatively, we could use an existing schema format, such as Avro, JSON schema or protobuf. These are likely to be more restrictive, but will mean that we can leverage existing open source libraries to work with the schemas.

## Decision

We have chosen to adopt [JSON schema](https://json-schema.org/) for the schema files, for the following reasons:

1. GOV.UK content schemas already use JSON schema.
2. Whitehall already has the [JSONSchemer gem](https://github.com/davishmcclurg/json_schemer) installed for working with JSON schemas.
3. Defining schema formats is a complex task. We should leverage existing solutions where they meet our needs.

## Consequences

We can iterate more quickly on Flexible Pages because we are using established open source tools with a solid theoretical foundation. We will not have to spend time making decisions about how to represent most content types.

It may be slightly harder to deliver complex flexible page features. However, JSON schema can be extended if necessary using the "x-" prefix for custom schema attributes. This will allow us to support features not provided by default JSON schema, though we intend to keep these to a minimum.
