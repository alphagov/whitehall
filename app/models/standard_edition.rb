class StandardEdition < Edition
  include Edition::Identifiable
  include Edition::Images
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

  def body
    block_content["body"]
  end

  def can_set_previously_published?
    type_instance.settings["backdating_enabled"]
  end

  def translatable?
    type_instance.settings["translations_enabled"]
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
end
