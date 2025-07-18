class FlexiblePage < Edition
  include Edition::Identifiable
  include Edition::FactCheckable
  include Edition::Images
  # File attachments
  include ::Attachable
  include Edition::AlternativeFormatProvider
  validates :flexible_page_type, presence: true, inclusion: { in: -> { FlexiblePageType.all_keys } }
  validate :content_conforms_to_schema

  def self.choose_document_type_form_action
    "choose_type_admin_flexible_pages_path"
  end

  def publishing_api_presenter
    PublishingApi::FlexiblePagePresenter
  end

  def summary_required?
    false
  end

  def body_required?
    # This suppresses the 'default' 'body' that is used by legacy Editions.
    # Flexible page schemas will define their own separate "body" property
    # if it is needed (as well as its required/optional status).
    false
  end

  def can_set_previously_published?
    false
  end

  def previously_published
    false
  end

  def can_be_fact_checked?
    type_instance.settings["fact_check_enabled"]
  end

  def allows_image_attachments?
    type_instance.settings["images_enabled"]
  end

  def alternative_format_provider_required?
    type_instance.settings["file_attachments_enabled"]
  end

  def base_path
    "#{type_instance.settings['base_path_prefix']}/#{slug}"
  end

  def type
    type_instance.settings["parent_document_type"].humanize || display_type
  end

  def display_type
    type_instance.settings["publishing_api_document_type"].humanize
  end

  def type_instance
    FlexiblePageType.find(flexible_page_type)
  end

  def content_conforms_to_schema
    formats = FlexiblePageContentBlocks::Factory.build_all.each_with_object({}) do |block, object|
      object[block.json_schema_format] = block.json_schema_validator unless block.json_schema_format == "default"
    end
    unless JSONSchemer.schema(type_instance.schema, formats:).valid?(flexible_page_content)
      errors.add(:flexible_page_content, "does not conform with the expected schema")
    end
  end
end
