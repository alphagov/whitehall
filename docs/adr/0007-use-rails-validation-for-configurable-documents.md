# 7. Use Rails validation for configurable documents

## Status

Accepted

## Context

We need to provide a way for document type configuration to specify validation rules for the document properties. These rules should be associated with the document rather than with the content blocks so that rules can vary between document types using the same blocks.

Whitehall requires validation rules that exceed the complexity of what can be specified with the basic JSON schema, so we need to find a way to implement this via the document type configuration.

We can either:

1. Use the built-in Rails validations and Whitehall's custom validators, exposing control of them via the document type configuration
2. Write an entirely custom validation system, as previously done for [Content Publisher](https://github.com/alphagov/content-publisher/blob/main/lib/requirements/checker_issues.rb)
3. Attempt to extend the existing JSON schema validation

## Decision

We have decided to use Rails existing validation rules, augmenting them with custom validators where necessary. We will declare validation rules within a given content type's JSON definition. For example, this might look like:

```json
{
    "validations": {
      "presence": {
        "attributes": ["body"]
      },
      "valid_govspeak": {
        "attributes": ["body", "lead_paragraph"],
        "safe_tags": ["div", "br", "p", "ul", "li"]
      }
    }
}
```

In the example above, we are specifying the use of two validators. The "presence" validation maps to the `ActiveModel::Validations::PresenceValidator`, and the "valid_govspeak" validation maps to a custom govspeak validator. The presence validator is asked to validate the "body" attribute on the object, and the custom govspeak validator is asked to validate both the "body" and the "lead_paragraph" attributes. The govspeak validator is also passed a "safe_tags" option via its constructor function.

We rejected option 2, the custom validation system, because reimplementing the existing validation using our own code implementation would be a time-consuming process. We would have to recreate many of Rails built-in validators and its error handling from scratch, which we would prefer to avoid. 

We rejected option 3, working within JSON schema, because the only obvious route to apply our own validation rules via JSON schema without defining custom vocabulary would be using [the `format` JSON schema annotation](https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.7). However, the [JSONschemer gem](https://github.com/davishmcclurg/json_schemer) Whitehall uses to perform JSON schema validation does not expose a way to override the validation error message displayed to the user, which means this is not a satisfactory solution. In any case, it would be an abuse of the `format` annotation, which is only really meant to be used to check the format of string inputs against a regex. This probably explains why JSONSchemer does not allow users to override the message.

## Consequences

We need to write some code to collect the errors from property validation and render these to the user. The block content attribute on the standard edition model works differently from normal Active Record attributes because it represents a JSON column, which may be used to store any shape of object. Fortunately Rails offers the [`import`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-import) method on the errors object, which can help us build a structure of nested errors.

We need to decide how to expose control over the validation rules via the configurable document type schema. This decision will be documented in [ADR-0008](./0008-drop-json-schema-for-document-configuration.md).
