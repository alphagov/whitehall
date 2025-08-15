# Flexible Pages

Whitehall offers a "flexible" pages feature. Flexible pages are editionable Whitehall documents that have their content schemas defined as JSON rather than in code. The content for a flexible page is stored in the `flexible_page_content` JSON column on the `edition_translations` table. Flexible pages have a "type", which is stored in the `flexible_page_type` column on the editions table. Users must select the type of flexible page they wish to create once they have selected "flexible page" from the new document type selection screen.

## Flexible Page Configuration

Flexible page types are defined as JSON. The JSON files are stored in the `app/models/flexible_page_types` directory.

The JSON for each type has these top level keys:

- 'key': The unique identifier for the flexible page type. This is what will be stored in the edition's `flexible_page_type` column.
- 'schema': The schema for the flexible page type, defined as [JSON schema](https://json-schema.org/docs). Each schema must have a root schema of the type "object".
- 'settings': The settings for the flexible page type.

These are the settings available for flexible page types. All settings are required.

| Key                      | Description                                                                                                                                                                          |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| base_path_prefix         | The prefix for the base path at which the flexible page will be published. E.g. /government/history for the page /government/history/10-downing-street                               |
| publishing_api_schema_name | The Publishing API schema name for flexible pages of this type                                                                                                                       |
| publishing_api_document_type | The Publishing API document type for flexible pages of this type                                                                                                                     |
| rendering_app            | The redering app for the flexible page type                                                                                                                                         |
| images_enabled           | Whether or not users should be able to upload images for this flexible page type using the images tab on the edition form                                                            |
| organisations            | An array of organisation content IDs. Only users from one of the listed organisations will be able to use the flexible page type. Use "null" to allow all users to use the page type |

The types are loaded from the JSON files on the first call to the `types` method on the [flexible page type model](../app/models/flexible_page_type.rb) and cached in memory. The model provides an ergonomic way to read values from a configuration file.

## Content Blocks

Each property within a flexible page schema is represented in the application as a content block. The content block is specified via the "type" and "format" options on the property schema. Content blocks are defined in the `app/models/flexible_page_content_blocks` directory.

Each content block implements the following methods:

- `json_schema_type`: The "type" value in the JSON schema property that maps to this content block
- `json_schema_format`: The "format" value in the JSON schema property that maps to this content block
- `json_schema_validator`: Returns a proc which validates user input for the property. The proc is passed as part of the 'formats' configuration value to the [JSONSchemer](https://github.com/davishmcclurg/json_schemer) gem's schema object.
- `publishing_api_payload(content)`: Returns the value to be sent to Publishing API for the property. This can return any type. If returning a hash, ensure you use symbols for the keys.
- `to_partial_path`: Returns the path to the view that renders the form control for the property. 

Block views use the following [partial-local](https://guides.rubyonrails.org/action_view_overview.html#passing-data-to-partials-with-locals-option) variables: 
- The property `schema` and `content` (default `{}`) are provided for the specific part of the tree being rendered by the content block. 
- The location in the tree is specified by the immutable [`path` object](../app/models/flexible_page_content_blocks/path.rb), which provides convenience methods for doing things such as building the correct name attribute for the form control. If you are rendering child properties for an "object" block, ensure that you push a new segment onto the path (see the [default object implementation](../app/models/flexible_page_content_blocks/default_object.rb) for an example). 
- The `root` (default `false`) attribute, which is only set to `true` for the rendering of the original `DefaultObject` block that wraps all the other blocks in the schema. 
- The `required` attribute. The required properties are defined at the parent level in [JSON schema](https://json-schema.org/docs), so the `required` attribute is extracted in the parent view, and passed on to any required child property, which then gets rendered with a "(required)" specification in its label.

Content blocks are instantiated via the [content block factory](../app/models/flexible_page_content_blocks/factory.rb). To add a new block type, add a new block class implementing the methods above to the `app/models/flexible_page_content_blocks` directory, and add the block type to the private blocks method in the factory class. The `blocks` method returns a hash that maps each block type and format to a constructor lambda. The constructor lambda receives the flexible page object as its only argument. Any values from the page object needed by the block can be passed to the block's initialize method, e.g. the Image Select block is passed the page's images.

There are two potential "gotchas" in to do with block types. The first is that you can't define a numeric type. Usually, Rails is able to cast model attribute values to a number if the attribute is stored using a numeric database column. However, because we store all the flexible page content in a single JSON column, Rails can't do that for flexible page content values. Therefore, we are forced to define all leaf schema properties as strings. It may be possible to implement some sort of type casting solution in future if this becomes especially painful.

The second "gotcha" is that you can't define nullable types, which in JSON schema is usually done by defining a type of `[string, null]`. However, Rails will typically interpret empty form input values as an empty string, rather than `nil`.
