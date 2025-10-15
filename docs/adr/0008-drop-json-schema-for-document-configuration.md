# 8. Drop JSON schema for specifying document properties in favour of our own custom schema definition

## Status

Accepted

## Context

We need to provide a way for document type configuration to specify that existing Rails and custom validators should be applied to configurable document type properties ([see ADR-0007](./0007-use-rails-validation-for-configurable-documents.md)).

We can achieve this either by extending JSON schema using our own custom vocabulary, or abandoning JSON schema altogether in favour of our own schema definition.

## Decision

We have decided to abandon JSON schema, superseding [ADR-0005](./0005-use-json-schema-for-flexible-page-schemas.md). We have made this decision for the following reasons:

- Extending JSON schema in a correct way according to the official specification is relatively complex, compared to dropping it and using our own non-standard schema.
- We don't want it to be possible to configure the same validation rules using both Rails validations and JSON schema, as this may cause confusion over what the convention should be. If it were possible, for example, to use both the [`minLength` JSON schema property](https://json-schema.org/draft/2020-12/draft-bhutton-json-schema-validation-00#rfc.section.6.3.2) and the [Rails length validator](https://guides.rubyonrails.org/active_record_validations.html#length), we could display duplicate errors to the user, or have to perform an awkward process to identify unique errors.

## Consequences

We need to define our own schema specification. Fortunately, we already have experience of a useful tool for this... JSON schema! This is beneficial to the project because it will allow us to automate tests that all the document type configuration files are valid.

We need to find a way to apply validations to the `block_content` attribute on the `StandardEdition` model based on the value of the configured document type, which is stored on the `editions` table. This is tricky because generally Rails validation rules are configured when the model class is defined using the [`validate` class method](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate), so by the time we have looked up the document type in the database it's too late.

However, Rails also exposes [the `validates_with` instance method](https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-validates_with) for active model objects which allows validation rules to be defined at runtime. We can pass configuration values to validators using this method once we have looked them up from the appropriate configuration file based on the edition's `configurable_document_type` attribute value.

So for example, if we have a configuration for an object property or the base properties value on a document type that looks like this:

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

Then in our Ruby code we can do this:

```ruby
VALIDATORS = {
    "presence" => ActiveModel::Validations::PresenceValidator,
    "valid_govspeak" => Validations::GovspeakValidator,
}.freeze

# schema loaded from configuration file for document type based on `configurable_document_type` attribute value
schema["validations"].each do |key, options|
  raise ArgumentError, "undefined validator type #{key}" unless VALIDATORS.key?(key)

  validates_with VALIDATORS[key], options.symbolize_keys
end
```
