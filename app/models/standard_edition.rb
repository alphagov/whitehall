class StandardEdition < Edition
  include Edition::Identifiable
  include Edition::Images
  validates :flexible_page_type, presence: true, inclusion: { in: -> { ConfigurableDocumentType.all_keys } }
  validate :content_conforms_to_schema

  def self.choose_document_type_form_action
    "choose_type_admin_standard_editions_path"
  end

  def publishing_api_presenter
    PublishingApi::StandardEditionPresenter
  end

  def summary_required?
    false
  end

  def body_required?
    false
  end

  def can_set_previously_published?
    false
  end

  def previously_published
    false
  end

  def allows_image_attachments?
    type_instance.settings["images_enabled"]
  end

  def base_path
    "#{type_instance.settings['base_path_prefix']}/#{slug}"
  end

  def type_instance
    ConfigurableDocumentType.find(flexible_page_type)
  end

  def content_conforms_to_schema
    formats = ConfigurableContentBlocks::Factory.new(self).build_all.each_with_object({}) do |block, object|
      object[block.json_schema_format] = block.json_schema_validator unless block.json_schema_format == "default"
    end
    unless JSONSchemer.schema(type_instance.schema, formats:).valid?(flexible_page_content)
      errors.add(:flexible_page_content, "does not conform with the expected schema")
    end
  end
end
