# Configurable Document Types

Whitehall offers configurable document types. Configurable documents are editionable Whitehall documents that have their content schemas defined as JSON rather than in code. The content for an edition of a configurable document is stored in the `block_content` JSON column on the `edition_translations` table. These editions have a "type", which is stored in the `configurable_document_type` column on the editions table.

## The standard type

As of this writing, Whitehall has a single configurable type, the "standard" document type, represented by the [StandardEdition](../app/models/standard_edition.rb) model. The standard type is a simple document type with no phasing, chapters or routing logic, for example news articles, case studies and guidance. Other types such as "phased", "navigational" and "multi-part" content are planned for future implementation.

The process of migrating existing document types to the standard type is ongoing. The migration consists of the following steps: defining the new configuration for the type, migrating the data, then deleting legacy code. Note that as of 2025 we have migrated news articles (news stories, government responses etc.) and history pages to the standard configurable document type format.

## Document Type Configuration

Configurable document types are defined as JSON. The JSON files are stored in the [`app/models/configurable_document_types`](../app/models/configurable_document_types) directory. The types are loaded from the JSON files on the first call to the `types` method on the [configurable document type model](../app/models/configurable_document_type.rb) and cached in memory. The model provides an ergonomic way to read values from a configuration file.

The JSON for each type has these top level keys:

- 'key': The unique identifier for the document type. This is what will be stored in the edition's `configurable_document_type` column.
- 'forms': The forms configuration for the document type. This describes how the document type's fields are presented on the UI. Each form (e.g., `documents`, `images`) contains a hash of `fields` hash whose keys should match attributes defined in `schema.attributes`. See [Block Rendering](#block-rendering) section for more details on how forms are rendered.
- 'schema': The schema for the document type. It contains `attributes` to define the data type for each form field and `validations` to specify what validations to run against the attributes. More details about attributes in [content blocks](#content-blocks).
- 'presenters': The presenters for the document type. This helps to define a list of presenters that will consume the document type's content. Each presenter contains a hash of keys, matching model attributes defined in `schema.attributes`, whose values should map to their presenter's corresponding BlockContent payload builder method - see the [Publishing API Payload](#publishing-api-payload) section for more details.
- 'associations': The associations for the document type. This is a list of strings that map to a set of association objects in the Rails app. All associations are included as concerns on the corresponding edition model (such as `StandardEdition`), and then required depending on whether they are included in the document type's configuration.
- 'settings': A set of configurations for the content type, including edition behaviours that we want to turn on, downstream information or admin-side rendering details.

These are the settings available for configurable document types.

| Key| Required                                                                                            | Description                                                                                                                                                                                                                                                             |
|---|-----------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| base_path_prefix         | Y                                                                                                   | The prefix for the base path at which the document will be published e.g. '/government/history for the page /government/history/10-downing-street'.                                                                                                                     |
| configurable_document_group | N                                                                                                   | Optional grouping for document types. Used for categorisation in the admin interface, including search filters. Typically matches the `publishing_api_schema_name`. For example, both `news_story` and `government_response` types would have the group `news_article`. |
| publishing_api_schema_name | Y                                                                                                   | Name of the schema in the Publishing API for this document type. Different types might share the same schema name. For example, `news_story` and `government_response` types both use the `news_article` schema.                                                        |
| publishing_api_document_type | Y                                                                                                   | The Publishing API document type for documents of this type.                                                                                                                                                                                                            |
| rendering_app            | Y                                                                                                   | The frontend application responsible for rendering this document type.                                                                                                                                                                                                  |
| images_enabled           | Y  | Whether users can upload images for this document type. When enabled, it renders the Images tab.                                                                                                                                                                        |
| send_change_history | Y                                                                                                   | Whether to send change history to the Publishing API. The change history will allow users to see major change updates to the document. Most editionable types should have this enabled.                                                                                 |
| file_attachments_enabled | Y                                                                                                   | Whether file attachments are allowed for this document type. When enabled, it renders the Attachments tab.                                                                                                                                                              |
| organisations            | Y                                                                                                   | An array of organisation content IDs. Only users from one of the listed organisations will be able to use the document type. Use "null" to allow all users to use the document type.                                                                                    |
| backdating_enabled       | Y                                                                                                   | Whether backdating is allowed for this document type. This is required for documents representing past printed papers or documents from other digital sources outside Whitehall.                                                                                        |
| history_mode_enabled     | Y                                                                                                   | Whether history mode is enabled for this document type. This controls whether the document can be marked as political.                                                                                                                                                  |
| translations_enabled    | Y                                                                                                   | Whether translations are supported for this document type.                                                                                                                                                                                                              |

## Content Blocks

Each attribute in `schema.attributes` holds the data type for its corresponding content block. The block's `type` is used for automatic type casting in the [block content model](../app/models/standard_edition/block_content.rb).

Content blocks are specified via the "block" property in the `forms` configuration. All available content blocks are defined in the `app/models/configurable_content_blocks` directory.

NB: The `title` and `summary` attributes for standard editions are not stored in the block content, but rather as first-class attributes on the edition model itself.

Each content block implements the following methods:
- `template_name`: The name of the template for rendering the block. The template must be in the `admin/configurable_content_blocks` directory.

### Block rendering

Each `form` in the configuration is rendered as a default object block. When we render the [form](../app/views/admin/standard_editions/_form.html.erb) for a standard edition, we initialise a `DefaultObject` block. The `schema` passed to the render method only selects the `documents` form from the configuration. This selection is not yet schema driven, but hardcoded in the standard edition view. For example, we also render images by hardcoding the `form` selection in the [images component](../app/components/admin/edition_images/uploaded_images_component.html.erb), which then renders the "Images" tab.

When the default object block's [view](../app/views/admin/configurable_content_blocks/_default_object.html.erb) gets rendered, we loop through the corresponding form's `fields` and initialise and render blocks matching the specified schemas. The blocks will render in the order they are defined in the `fields` hash.

The default object block is a recursive block type, as it can contain other **object** blocks within its properties. This allows us to build arbitrarily deep trees of content blocks, as defined in the `forms` hash. The following is an example of a configuration that would display two tabs for a standard edition. The first tab also contains nested fields.

```json
{
  "forms": {
    "form_corresponding_to_a_tab": {
      "fields": {
        "leaf_property_one": {
          "title": "Leaf property one",
          "description": "A block in a tabbed content view",
          "block": "govspeak"
        },
        "nested_object": {
          "title": "Nested object",
          "block": "default_object",
          "fields": {
            "leaf_property_in_nested_object_one": {
              "title": "Nested leaf one",
              "block": "default_date"
            },
            "leaf_property_in_nested_object_two": {
              "title": "Nested leaf two",
              "block": "default_string"
            }
          }
        }
      }
    },
    "another_form_corresponding_to_a_tab": {
      "fields": {
        "leaf_property_two": {
          "title": "Leaf property two",
          "description": "A block in another tabbed content on the page",
          "block": "default_string"
        }
      }
    }
  }
}
```
The rendering process would be as follows:
- Renders a tab view, whose rendering is typically controller by some config-driven setting, or is always rendered, such as the edition "Documents" tab.
- Renders a `DefaultObject` block using the `_default_object.html.erb` partial. We pass in the `forms.form_corresponding_to_a_tab` schema.
- Loops through the `fields` properties:
  - Renders `leaf_property_one` which is a `Govspeak` block (using the `_govspeak.html.erb` partial)
  - Renders `nested_object`, which is another `DefaultObject` block.
    - Loops through the `nested_object`'s `fields` properties:
      - Renders `leaf_property_in_nested_object_one`, which is a `DefaultDate` block (using the `_default_date.html.erb` partial)
      - Renders `leaf_property_in_nested_object_two`, which is a `DefaultString` block (using the `_default_string.html.erb` partial)
- Renders the second tab by repeating the process for `another_form_corresponding_to_a_tab`.

### Publishing API Payload

The `StandardEditionPresenter` uses the document type's `presenters` configuration to compose the `details` hash for Publishing API. The `presenters` hash maps each attribute (defined in `schema.attributes`) to its corresponding block content payload builder method.

For example, a presenter configuration will look like:

```json
{
  "presenters": {
    "publishing_api": {
      "body": "govspeak",
      "image": "lead_image_select"
    }
  }
}
```

This instructs the presenter that the `body` attribute should use the `govspeak` payload builder and the `image` attribute should use the `lead_image_select` payload builder. 

Each block type maps to a publishing API payload builder method (see [app/presenters/publishing_api/payload_builder/block_content.rb](../app/presenters/publishing_api/payload_builder/block_content.rb)), which is called for the attributes configured in the presenter.

This separation allows the same attribute to be presented differently in the UI (via the forms configuration) and in the Publishing API payload, providing flexibility for future changes.

### Create a new content block type

1. Add a new block class to the [content blocks directory](../app/models/configurable_content_blocks)
   - Include the `Renderable` and `BaseConfig` modules.
   - Implement the `template_name` method
2. Add the block type and class to the [content blocks map](../app/models/configurable_document_type.rb)
3. Create a view template for the block in the `app/views/admin/configurable_content_blocks` directory
   - The name of the template should correspond to the block class name.
4. If your block must use a new data type, you might need to make changes to the [block content model](../app/models/standard_edition/block_content.rb)
5. Ensure you can present the content managed by your block. Check the presenter level [block content abstraction](../app/presenters/publishing_api/payload_builder/block_content.rb). If you're adding a new data type, you might also need to add a new builder method.
6. Make sure the block supports each of the following features:
   1. RTL rendering depending on the locale
   2. rendering the primary locale content under the input
   3. the required attribute
   4. rendering validation errors.

### Using a content block in the schema
To use a content block, you need to define it in both the schema and forms:

- Define the UI in `forms.<form_tab>.fields.<field_name>`:
  - `title`: Display label for the field.
  - `description`: (Optional) Help text shown to the user.
  - `required`: (Optional) Whether the form label should include the `(required)` guidance 
  - `block`: Block component to use (e.g., `govspeak`, `lead_image_select`). Must match a format registered in the [content blocks map](../app/models/configurable_document_type.rb).

- Define the data type in `schema.attributes.<field_name>`:
  - `type`: Data type for the attribute (e.g., `string`, `integer`, `date`). Used for type casting in the [block content model](../app/models/standard_edition/block_content.rb).

- Define the Publishing API mapping in `presenters.publishing_api`:
  - Maps the attribute name to its payload builder method (e.g., `"body": "govspeak"`).

- Add other presenters as needed, following the same mapping structure above.

### Content Block Validation

Rails validations can be applied to properties by adding a `validations` key to `schema`, alongside the `attributes` specification. The value for the `validations` key should be an object. The keys for the object must map to a validator, as defined in the ['block content' model](../app/models/standard_edition/block_content.rb). The value for each key is an object which will be passed to the validator constructor. The `attributes` represents an array of the names of the attributes to be validated, required for all but custom validators. Other options may be passed depending on what arguments the validator's `initialize` method accepts. 

NB: This structure means that validations technically sit at the "parent" level, so that most schemas have validations at the root level, validating the properties immediately under, such as `body`. Any subsequent object type blocks would have validations defined for their nested attributes.

Example:

```json
{
  "schema": {
    "attributes": {
      "body": {
        "type": "string"
      },
      "image": {
        "type": "integer"
      }
    },
    "validations": {
      "presence": {
        "attributes": ["body"]
      },
      "max_file_size_custom_validator": {
        "attributes": ["image"],
        "maximum_file_size": 9000
      }
    }
  }
}
```

For more complex validation logic, you must define your custom validators. These custom validators are still decoupled from any schema and tested independently. Though they may be specific to a document type, they can be reused across multiple types if needed.

## Associations

Associations can be added to configurable document types to link them to other content in Whitehall, for example, organisations or topical events. These associations are defined in the `associations` key in the document type's JSON configuration file. The associations are rendered on the document form in the order they are defined in the configuration.

The available associations are:

| Association                     | Description                                                                                                                                                                              |
|---|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ministerial_role_appointments` | An appointment links a ‘ministerial role’ to a ‘person’ for a certain duration of time.                                                                                                  |
| `topical_events` | Topical events are used to communicate government activity about high-profile events or in response to a major crisis. For example, a war, pandemic, the death of a royal or the Budget. |
|`world_locations` | Here is the [canonical list](https://whitehall-admin.publishing.service.gov.uk/government/admin/world_location_news) of locations we use.                                                |
| `worldwide_organisations` | A worldwide organisation is a British embassy, High Commission or Consulate General in a worldwide location.                                                                             |
| `organisations` | Includes lead and supporting organisations.                                                                                                                                              |

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
