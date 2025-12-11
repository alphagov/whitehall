class StandardEdition < Edition
  include Edition::Identifiable
  include Edition::Images
  include Edition::LeadImage
  include Edition::CustomLeadImage
  include ::Attachable
  include Edition::AlternativeFormatProvider
  include Edition::RoleAppointments
  include Edition::TopicalEvents
  include Edition::WorldLocations
  include Edition::Organisations
  include Edition::WorldwideOrganisations
  include HasBlockContent
  include StandardEdition::DefaultLeadImage

  validates :configurable_document_type, presence: true, inclusion: { in: -> { ConfigurableDocumentType.all_keys } }

  def format_name
    type_instance.label.downcase
  end

  def display_type
    type_instance.label
  end

  def publishing_api_presenter
    PublishingApi::StandardEditionPresenter
  end

  def update_configurable_document_type(new_type_key)
    return false if !is_in_valid_state_for_type_conversion? ||
      ConfigurableDocumentType.convertible_from(configurable_document_type).none? { |type| type.key == new_type_key }

    self.configurable_document_type = new_type_key
    save!(validate: false)
  end

  def body_required?
    false
  end

  def body
    block_content["body"]
  end

  def can_set_previously_published?
    type_instance.settings["backdating_enabled"]
  end

  def translatable?
    type_instance.settings["translations_enabled"]
  end

  def locale_can_be_changed?
    # New editions can change locale, but once persisted:
    # - Only world news stories can change locale
    # - Regular news stories cannot change locale
    return true if new_record? && translatable?

    translatable? && translations.size <= 1 && configurable_document_type == "world_news_story"
  end

  def allows_image_attachments?
    type_instance.settings["images_enabled"]
  end

  def allows_file_attachments?
    type_instance.settings["file_attachments_enabled"]
  end

  def can_be_marked_political?
    type_instance.settings["history_mode_enabled"]
  end

  def can_have_custom_lead_image?
    # Check if the configurable document type supports lead image selection
    type_instance.properties.values.any? { |property| property["format"] == "lead_image_select" }
  end

  def base_path
    "#{type_instance.settings['base_path_prefix']}/#{slug}"
  end

  def type_instance
    ConfigurableDocumentType.find(configurable_document_type)
  end

  def organisation_association_enabled?
    type_instance.associations.map { |assoc| assoc["key"] }.include?("organisations")
  end

  def worldwide_organisation_association_required?
    type_instance.associations.find { |assoc| assoc["key"] == "worldwide_organisations" }&.dig("required") == true
  end

  def world_location_association_required?
    type_instance.associations.find { |assoc| assoc["key"] == "world_locations" }&.dig("required") == true
  end

  def is_in_valid_state_for_type_conversion?
    %w[draft submitted rejected].include?(state)
  end
end
