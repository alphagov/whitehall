class ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::SummaryListHelper
  include ContentBlockManager::ContentBlock::TranslationHelper

  delegate :document, to: :content_block_edition

  with_collection_parameter :object_title

  def initialize(content_block_edition:, object_type:, object_title:, redirect_url: nil, test_id_prefix: nil)
    @content_block_edition = content_block_edition
    @object_type = object_type
    @object_title = object_title
    @redirect_url = redirect_url
    @test_id_prefix = test_id_prefix
  end

private

  attr_reader :content_block_edition, :object_type, :object_title, :redirect_url, :test_id_prefix

  def title
    "#{object_type.titleize.singularize} details"
  end

  def items
    fields_for_schema(schema).map { |field|
      [field.name, object[field.name]]
    }.to_h
  end

  def rows
    first_class_items(items).map do |key, value|
      {
        field: key_to_title(key, object_type),
        value: translated_value(value),
        data: {
          testid: [object_title.parameterize, key].compact.join("_").underscore,
        },
      }
    end
  end

  def embeddable_fields
    @embeddable_fields = schema.embeddable_fields
  end

  def object
    @object ||= content_block_edition.details.dig(object_type, object_title)
  end

  def schema
    @schema ||= content_block_edition.document.schema.subschema(object_type)
  end

  def summary_card_actions
    [
      {
        label: "Edit",
        href: helpers.content_block_manager.edit_embedded_object_content_block_manager_content_block_edition_path(
          content_block_edition,
          object_type:,
          object_title:,
          redirect_url:,
        ),
      },
    ]
  end

  def wrapper_attributes
    {
      "class" => "govuk-summary-card",
      **data_attributes,
    }
  end

  def data_attributes
    test_id_prefix.present? ? { "data-test-id" => [test_id_prefix, object_title].join("_") } : {}
  end
end
