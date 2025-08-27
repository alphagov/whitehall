class StandardEdition < Edition
  include Edition::Identifiable
  include Edition::Images
  validates :configurable_document_type, presence: true, inclusion: { in: -> { ConfigurableDocumentType.all_keys } }
  validate :content_conforms_to_schema

  def self.choose_document_type_form_action
    "choose_type_admin_standard_editions_path"
  end

  def format_name
    type_instance.label.downcase
  end

  def display_type
    type_instance.label
  end

  def publishing_api_presenter
    PublishingApi::StandardEditionPresenter
  end

  def body_required?
    false
  end

  def can_set_previously_published?
    type_instance.settings["backdating_enabled"]
  end

  def allows_image_attachments?
    type_instance.settings["images_enabled"]
  end

  def can_be_marked_political?
    type_instance.settings["history_mode_enabled"]
  end

  def base_path
    "#{type_instance.settings['base_path_prefix']}/#{slug}"
  end

  def type_instance
    ConfigurableDocumentType.find(configurable_document_type)
  end

  def content_conforms_to_schema
    formats = ConfigurableContentBlocks::Factory.new(self).build_all.each_with_object({}) do |block, object|
      object[block.json_schema_format] = block.json_schema_validator unless block.json_schema_format == "default"
    end
    unless JSONSchemer.schema(type_instance.schema, formats:).valid?(block_content)
      errors.add(:block_content, "does not conform with the expected schema")
    end
  end
end
