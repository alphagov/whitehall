class StandardEdition < Edition
  include Edition::Identifiable

  validates :configurable_document_type, presence: true, inclusion: { in: -> { ConfigurableDocumentType.all_keys } }

  def self.choose_document_type_form_action
    "choose_type_admin_standard_editions_path"
  end

  def self.include_association(association_klass)
    @associations ||= []
    include association_klass.edition_concern
    @associations.push(association_klass)
  end

  def self.configurable_associations
    @associations || []
  end

  def authorised_organisations
    nil
  end

  def publishing_api_presenter
    PublishingApi::StandardEditionPresenter
  end

  def self.model_name
    ActiveModel::Name.new(StandardEdition)
  end

  def format_name
    self.class.config.title.downcase
  end

  def display_type
    self.class.config.title
  end

  def body_required?
    false
  end

  def can_set_previously_published?
    false
  end

  def translatable?
    false
  end

  def allows_image_attachments?
    false
  end

  def allows_file_attachments?
    false
  end

  def can_be_marked_political?
    false
  end

  def base_path
    "#{self.class.config.base_path_prefix}/#{slug}"
  end

  def organisation_association_enabled?
    false
  end
end
