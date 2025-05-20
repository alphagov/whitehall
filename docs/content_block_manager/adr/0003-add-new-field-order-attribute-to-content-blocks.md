# 3. Add a new Field Order attribute to content blocks 

Date: 2025-05-20

## Context

We are introducing the concept of "views" for entire blocks, in addition to being able to embed individual
attributes. These views can be ordered in specific ways (for example, a user can choose to show the telephone
number before the address in the case of a contact), as well as allowing custom views to be created to allow
only specific attributes to be shown.

At the moment, the order and presentation of blocks is controlled by code in the 
[`content_block_tools`](https://github.com/alphagov/content_block_tools) gem. Each block type has a presenter
which returns a representation of all the attributes in a block, styled in a particular way. For example, the
render method for a contact block looks like this:

```ruby
def default_content
  content_tag(:div, class: "contact") do
    concat content_tag(:p, content_block.title, class: "govuk-body")
    concat(email_addresses.map { |email_address| email_address_content(email_address) }.join.html_safe) if email_addresses.any?
    concat(phone_numbers.map { |phone_number| phone_number_content(phone_number) }.join.html_safe) if phone_numbers.any?
  end
end
```

This returns the elements in a strict order, styled in a particular way, and can only be changed by developers.

Additionally, it will be difficult to allow users to create new views, without having some mechanism to tell the
gem that we expect to see only specific attributes in the view.

## Decision

We will add a new `field_order` objects to all content blocks. This will have a `default` key by default, which 
specifies the order that fields and child objects will be rendered when displaying an entire block. If the field
is a first-class child of the block, this will be returned as a string, otherwise it will be returned as an object,
with the key being the object type, and the value being an array of all the objects of that type that we want to return.

For example, when given a block which with a JSON representation like so:

```json
{
  "details": {
    "email_addresses": {
      "email-1": {
        "title": "Email 1",
        "email_address": "hello@example.com",
        "description": "General enquiries"
      },
      "email-2": {
        "title": "Email 2",
        "email_address": "hiagain@example.com",
        "description": "More enquiries"
      }
    },
    "telephones": {
      "telephone-1": {
        "title": "Telephone 1",
        "telephone": "1234 567 89"
      }
    },
    "addresses": {
      "address-1": {
        "title": "Main address",
        "street_address": "1 Westminster Road",
        "locality": "London",
        "region": "Greater London",
        "postcode": "W1A 2BC",
        "country": "United Kingdom"
      }
    },
    "field_order" ...
  }
}
```

The `field_order` object (within the `details` object) will look like this by default:

```json
{
  "field_order": {
    "default": [
      "title",
      { "email_addresses":  ["email-1", "email-2"] },
      { "telephones":  ["telephone-1"] },
      { "addresses":  ["address-1"] }
    ]
  }
}
```

If the user wanted to alter the order by, say, putting the addresses first, the JSON sent would look like so:

```json
{
  "field_order": {
    "default": [
      "title",
      { "addresses":  ["address-1"] },
      { "email_addresses":  ["email-1", "email-2"] },
      { "telephones":  ["telephone-1"] }
    ]
  }
}
```

Equally, if they wanted to have `email-1`, then `telephone-1`, followed by `email-2`, the JSON would look like this:

```json
{
  "field_order": {
    "default": [
      "title",
      { "email_addresses":  ["email-1"] },
      { "telephones":  ["telephone-1"] },
      { "email_addresses":  ["email-2"] },
      { "addresses":  ["address-1"] }
    ]
  }
}
```

This will instruct the presenter to return, first the title, then `email-1`, `email-2`, `telephone-1`, then `address-1`.

Additionally, if a user wanted to create a new view, which only had email addresses, they could create a new 
`field_order` object and send this to the API:

```json
{
  "field_order": {
    "default": [
      "title",
      { "email_addresses":  ["email-1", "email-2"] },
      { "telephones":  ["telephone-1"] },
      { "addresses":  ["address-1"] }
    ],
    "only_emails": [
      { "email_addresses":  ["email-1", "email-2"] },
    ]
  }
}
```

When a user uses the default embed code (for example `{{embed:content_block_contact:my-contact-details}}`) in a 
document, then the block will be presented with the default field_order.

If they wanted to use the `only_emails` field order, they could use en embed code which looks like this:

```
{{embed:content_block_contact:my-contact-details#only_emails}}
```

## Consequences

This will mean adding some additional functionality to the Content Block Tools gem ([PR in progress here](https://github.com/alphagov/govuk_content_block_tools/pull/39))
which will read the `field_order` object and render those fields in order.

We will also need to update the Publishing API schemas to ensure the `field_order` attribute is supported.

We will then be able to add functionality to create a default sort order at the point of publication to Content
Block Manager, then add the functionality to reorder the fields and send that to the API.

Any change in order should be treated as a new "edition" of a Content Block, so we will need to ensure that this
is represented in the timeline when viewing a content block.

Once we have a default field added, we will then be able to add functionality to add new views, as well as change
the logic in the Content Block Tools gem to support the new embed code format.
