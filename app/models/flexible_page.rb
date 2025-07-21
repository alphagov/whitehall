class FlexiblePage < Edition
  # Publishing workflow
  include Edition::Identifiable
  include Edition::FactCheckable
  # include Edition::Translatable # NB: doesn't look like we need this at all.

  # File attachments
  include ::Attachable
  include Edition::AlternativeFormatProvider

  # Images
  include Edition::Images
  # TODO: can these two modules be combined? Feels as though we
  # should just have `Edition::LeadImage` and allow consumers of
  # the module to opt into (or out of) CustomLeadImage via
  # overriding a method
  include Edition::CustomLeadImage
  include Edition::LeadImage

  # Associations
  include Edition::Organisations
  include Edition::RoleAppointments
  include Edition::TopicalEvents
  include Edition::WorldLocations
  include Edition::WorldwideOrganisations

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

  def translatable?
    type_instance.settings["translations_enabled"]
  end

  def can_be_fact_checked?
    type_instance.settings["fact_check_enabled"]
  end

  def allows_image_attachments?
    type_instance.settings["images_enabled"]
  end

  def can_have_custom_lead_image?
    type_instance.settings["custom_lead_image_enabled"]
  end

  def alternative_format_provider_required?
    type_instance.settings["file_attachments_enabled"]
  end

  def can_be_associated_with_world_locations?
    add_association("world_locations")
  end

  def can_be_associated_with_role_appointments?
    add_association("ministers")
  end

  def can_be_associated_with_topical_events?
    add_association("topical_events")
  end

  def can_be_related_to_organisations?
    add_association("lead_organisations")
  end

  def skip_organisation_validation?
    !can_be_related_to_organisations?
  end

  def can_have_supporting_organisations?
    add_association("supporting_organisations")
  end

  def can_be_associated_with_worldwide_organisations?
    add_association("worldwide_organisations")
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

private

  def add_association(property)
    association = type_instance.settings["associations"]
      .find { |association| association["type"] == property }
    
    !association.nil?

    # TODO: the 'required' logic
    # association.dig("required")
  end
end
