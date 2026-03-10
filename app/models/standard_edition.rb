class StandardEdition < Edition
  include Edition::Identifiable
  include Edition::Images
  include ::Attachable
  include Edition::Featurable
  include Edition::AlternativeFormatProvider
  include Edition::RoleAppointments
  include Edition::TopicalEvents
  include Edition::WorldLocations
  include Edition::Organisations
  include Edition::WorldwideOrganisations
  include HasBlockContent
  include StandardEdition::LeadImage

  FEATURED_DOCUMENTS_DISPLAY_LIMIT = 6

  attr_accessor :current_tab_context

  validates :configurable_document_type, presence: true, inclusion: { in: -> { ConfigurableDocumentType.all_keys } }

  scope :with_news_article_document_type, -> { where(configurable_document_type: ConfigurableDocumentType.where_group("news_article").map(&:key)) }

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
    block_content.respond_to?(:body) ? block_content.body : block_content["body"]
  end

  def body=(_)
    nil
  end

  def can_set_previously_published?
    type_instance.settings["backdating_enabled"]
  end

  def translatable?
    type_instance.settings["translations_enabled"]
  end

  def locale_can_be_changed?
    translatable? && translations.size <= 1
  end

  def allows_lead_image?
    type_instance.form("images").present?
  end

  def allows_image_attachments?
    type_instance.settings["images"]["enabled"]
  end

  def allows_file_attachments?
    type_instance.settings["file_attachments_enabled"]
  end

  def allows_features?
    type_instance.settings["features_enabled"]
  end

  def can_be_associated_with_topical_events?
    [
      ConfigurableContentBlocks::Path.new("topical_event_ids"), # Legacy: delete when topical events migrated
      ConfigurableContentBlocks::Path.new("topical_event_document_ids"),
    ].any? { |path| field_paths.include?(path) }
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

  def group
    type_instance.settings["configurable_document_group"]
  end

  def organisation_association_enabled?
    field_paths.include?(ConfigurableContentBlocks::Path.new("lead_organisation_ids"))
  end

  def worldwide_organisation_association_required?
    required_field_paths.include?(ConfigurableContentBlocks::Path.new("worldwide_organisation_document_ids"))
  end

  def world_location_association_required?
    required_field_paths.include?(ConfigurableContentBlocks::Path.new("world_location_ids"))
  end

  def is_in_valid_state_for_type_conversion?
    %w[draft submitted rejected].include?(state)
  end

  def defines_tabs?
    type_instance.dynamic_tabs.any?
  end

  def valid_tab_key?(key)
    key == "documents" || type_instance.dynamic_tabs.any? { |tab| tab["id"] == key }
  end

  def default_tab
    "documents"
  end

  def permitted_image_usages
    type_instance.settings["images"]["usages"].each_with_object([]) do |(usage_key, config), result|
      kinds = config["kinds"].map { |kind_name| Whitehall.image_kinds[kind_name] }
      result << ImageUsage.new(key: usage_key, kinds:, **config.except("kinds"))
    end
  end

  def error_labels
    {}.tap do |labels|
      ConfigurableContentBlocks::DefaultObject.root_block_for(self, "documents").each do |block|
        # we only want labels for leaf fields, so do nothing if this field isn't one
        next if block.respond_to? :field_blocks

        labels[block.path.validation_error_attribute] = block.title
      end
    end
  end

private

  def field_paths(&block)
    [].tap do |paths|
      ConfigurableContentBlocks::DefaultObject.root_block_for(self, "documents").each do |field|
        # we only want paths for leaf fields, so do nothing if this field isn't one
        next if field.respond_to? :field_blocks

        paths << field.path if !block_given? || block.call(field)
      end
    end
  end

  def required_field_paths
    field_paths { |field| field.required == true }
  end

  def string_for_slug
    title if primary_locale.to_sym == translation.locale
  end
end
