# Configurable Document Types

Whitehall offers configurable document types. Configurable documents are editionable Whitehall documents that have their content schemas defined as JSON rather than in code. The content for an edition of a configurable document is stored in the `block_content` JSON column on the `edition_translations` table. These editions have a "type", which is stored in the `configurable_document_type` column on the editions table.

## Document Type Configuration

Configurable document types are defined as JSON. The JSON files are stored in the `app/models/configurable_document_types` directory.

The JSON for each type has these top level keys:

- 'key': The unique identifier for the document type. This is what will be stored in the edition's `configurable_document_type` column.
- 'schema': The schema for the document type, defined as [JSON schema](https://json-schema.org/docs). Each schema must have a root schema of the type "object".
- 'associations': The associations for the document type. This is a list of strings that map to a set of association objects in the Rails app.
- 'settings': The settings for the document type.

These are the settings available for configurable document types. All settings are required.

| Key                      | Description                                                                                                                                                                         |
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| base_path_prefix         | The prefix for the base path at which the document will be published. E.g. /government/history for the page /government/history/10-downing-street                                   |
| publishing_api_schema_name | The Publishing API schema name for documents of this type                                                                                                                           |
| publishing_api_document_type | The Publishing API document type for documents of this type                                                                                                                         |
| rendering_app            | The redering app for the document type                                                                                                                                              |
| images_enabled           | Whether or not users should be able to upload images for this document type using the images tab on the edition form                                                                |
| organisations            | An array of organisation content IDs. Only users from one of the listed organisations will be able to use the document type. Use "null" to allow all users to use the document type |

The types are loaded from the JSON files on the first call to the `types` method on the [configurable document type model](../app/models/configurable_document_type.rb) and cached in memory. The model provides an ergonomic way to read values from a configuration file.

## Content Blocks

Each property within a configurable document schema is represented in the application as a content block. The content block is specified via the "type" and "format" options on the property schema. Content blocks are defined in the `app/models/configurable_content_blocks` directory.

Each content block implements the following methods:

- `json_schema_type`: The "type" value in the JSON schema property that maps to this content block
- `json_schema_format`: The "format" value in the JSON schema property that maps to this content block
- `json_schema_validator`: Returns a proc which validates user input for the property. The proc is passed as part of the 'formats' configuration value to the [JSONSchemer](https://github.com/davishmcclurg/json_schemer) gem's schema object.
- `publishing_api_payload(content)`: Returns the value to be sent to Publishing API for the property. This can return any type. If returning a hash, ensure you use symbols for the keys.
- `to_partial_path`: Returns the path to the view that renders the form control for the property. 

Block views use the following [partial-local](https://guides.rubyonrails.org/action_view_overview.html#passing-data-to-partials-with-locals-option) variables: 
- The property `schema` and `content` (default `{}`) are provided for the specific part of the tree being rendered by the content block. The content is for the edition's primary locale.
- The location in the tree is specified by the immutable [`path` object](../app/models/configurable_content_blocks/path.rb), which provides convenience methods for doing things such as building the correct name attribute for the form control. If you are rendering child properties for an "object" block, ensure that you push a new segment onto the path (see the [default object implementation](../app/models/configurable_content_blocks/default_object.rb) for an example). 
- The `root` (default `false`) attribute, which is only set to `true` for the rendering of the original `DefaultObject` block that wraps all the other blocks in the schema. 
- The `required` attribute. The required properties are defined at the parent level in [JSON schema](https://json-schema.org/docs), so the `required` attribute is extracted in the parent view, and passed on to any required child property, which then gets rendered with a "(required)" specification in its label.
- The `right_to_left` (default `false`) attribute. This is set to true if the locale for the edition translation is set to a language which is read from right to left.
- The `translated_content` (default `nil`) attribute. If the edition is a translation, then this will be populated with the translated content. Blocks must populate their values with the translated content if it is provided, and may wish to show the content for the primary locale as an aid to the user.
- The `errors` (default `[]`) attribute. The validation errors for the edition. Use the `errors_for` helper function and pass it both the errors and the attribute "path" to pass the attribute errors to the form control component.

Content blocks are instantiated via the [content block factory](../app/models/configurable_content_blocks/factory.rb). To add a new block type, add a new block class implementing the methods above to the `app/models/configurable_content_blocks` directory, and add the block type to the private blocks method in the factory class. The `blocks` method returns a hash that maps each block type and format to a constructor lambda. The constructor lambda receives the configurable document edition object as its only argument. Any values from the edition object needed by the block can be passed to the block's initialize method, e.g. the Image Select block is passed the edition's images.

There are two potential "gotchas" in to do with block types. The first is that you can't define a numeric type. Usually, Rails is able to cast model attribute values to a number if the attribute is stored using a numeric database column. However, because we store all the edition content in a single JSON column, Rails can't do that for block content values. Therefore, we are forced to define all leaf schema properties as strings. It may be possible to implement some sort of type casting solution in future if this becomes especially painful.

The second "gotcha" is that you can't define nullable types, which in JSON schema is usually done by defining a type of `[string, null]`. However, Rails will typically interpret empty form input values as an empty string, rather than `nil`.

### Content Block Validation

Rails validations can be applied to properties by adding a `validations` key to the property's object schema. The value for the `validations` key should be an object. The keys for the object must map to a validator, as defined in the ['block content' model](../app/models/standard_edition/block_content.rb). The value for each key is an object which will be passed to the validator constructor. The `attributes` must be included in that object, and must be an array of the names of the attributes to be validated. Other options may be passed depending on what arguments the validator's `initialize` method accepts.
Example:
```json
{
  "validations": {
    "presence": {
      "attributes": ["body"]
    },
    "max_file_size_custom_validator": {
      "attributes": [
        "image"
      ],
      "maximum_file_size": 9000
    }
  }
}
``` 

## Associations

Associations can be added to configurable document types to link them to other content in Whitehall, for example, organisations or topical events. These associations are defined in the `associations` key in the document type's JSON configuration file.

The available associations are:

- `ministerial_role_appointments`
- `topical_events`
- `world_locations`
- `organisations` (includes lead and supporting organisations)

### Architecture

Configurable associations have been implemented using plain old Ruby objects that bundle together the behaviour of the association in a single object, rather than distributing it across several locations in the codebase. The exception to this is persistence behaviour, which remains within the existing Active Record edition concerns. In the future, once the current document types have been migrated to the configurable document type architecture, it may be possible to merge the concerns and the association classes. Until then, any Active Record configuration of the association should take place in the Standard Edition model or the concern.

We use a factory pattern to isolate the association from Active Record, so that the association cannot manipulate the edition model and cause unexpected side effects elsewhere in the application.

The associations are consumed by the [standard edition form](../app/views/admin/standard_editions/_form.html.erb) and the [standard edition presenter](../app/presenters/publishing_api/standard_edition_presenter.rb). They each iterate through the list of associations configured for the document type. The standard edition form renders each association, and the standard edition presenter outputs the links for each association.

### Adding a new association

Adding a new type of association involves changes to several files to handle both the admin interface for selecting the association and the data that is sent to the Publishing API.

The process is as follows:

1.  **Create an association class**: Add a new class to the `app/models/configurable_associations` directory.

2.  **Update the factory**: The factory at `app/models/configurable_associations/factory.rb` is responsible for instantiating the association classes. You need to add the new association to the `associations` hash in this file. The key should match the one used in the document type's JSON configuration.

3.  **Create a view partial**: To allow users to select the association in the admin interface, you need to create a new ERB partial in the `app/views/admin/configurable_associations` directory. The name of the partial should correspond to the key of your new association (e.g., `_my_new_association.html.erb`). This partial will be rendered on the document's edit page. Add the `to_partial_path` method to the association class. The `to_partial_path` method should return the path of the partial template. The partial will have a variable in scope that matches the name of the association class, in snake case, which you can use to access data and methods from the association object.

4.  **Presenter links**: The `app/presenters/publishing_api/standard_edition_presenter.rb` is responsible for generating the payload that is sent to the Publishing API. The `links` method in this presenter iterates over the configured associations for a document type and calls the `links` method on each association object to build up the links hash for the payload. Ensure your new association class provides the correctly formatted links hash.
