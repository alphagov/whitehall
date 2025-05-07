class ContentBlockManager::Shared::EmbeddedObjectsComponent < ViewComponent::Base
  def initialize(content_block_edition:, subschema:, redirect_url:)
    @content_block_edition = content_block_edition
    @subschema = subschema
    @redirect_url = redirect_url
  end

private

  attr_reader :content_block_edition, :subschema, :redirect_url

  def subschema_name
    subschema.name.humanize.singularize.downcase
  end

  def subschema_keys
    @subschema_keys ||= content_block_edition.details[subschema.block_type]&.keys || []
  end

  def show_add_button?
    content_block_edition.document.is_new_block?
  end

  def add_button_text
    has_embedded_objects? ? "Add another #{subschema_name}" : "Add #{helpers.add_indefinite_article subschema_name}"
  end

  def has_embedded_objects?
    subschema_keys.any?
  end
end
