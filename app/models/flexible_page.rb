class FlexiblePage < Edition
  include Edition::Identifiable
  include Edition::Images
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
    FlexiblePageType.find(flexible_page_type)
  end

  def content_conforms_to_schema
    unless type_instance.validator.valid?(flexible_page_content)
      errors.add(:flexible_page_content, "does not conform to schema for the #{type_instance.label}.")
    end
  end
end
