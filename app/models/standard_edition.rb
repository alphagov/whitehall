class StandardEdition < Edition
  include Edition::Identifiable

  after_find :initialize_block_content
  validates_associated :block_content
  validates :configurable_document_type, presence: true, inclusion: { in: -> { ConfigurableDocumentType.all_keys } }

  def self.choose_document_type_form_action
    "choose_type_admin_standard_editions_path"
  end

  def self.associations(association_classes)
    @associations ||= []
    association_classes.each do |association_class|
      include association_class.edition_concern
      @associations << association_class
    end
  end

  def self.configurable_associations
    @associations || []
  end

  Configuration = Struct.new(
    :key,
    :title,
    :description,
    :base_path_prefix,
    :publishing_api_schema_name,
    :publishing_api_document_type,
    :rendering_app,
    :authorised_organisations,
    keyword_init: true
  )

  def self.settings(*values)
    @configuration = Configuration.new(values)
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

  # Required to work around https://github.com/globalize/globalize/issues/611
  def block_content=(value)
    @block_content_shim ||= self.class.properties.new
    if value.is_a? self.class.properties
      @block_content_shim.assign_attributes(value.attributes)
    else
      @block_content_shim.assign_attributes(value)
    end
    super(value)
  end

  def block_content
    return nil if self[:block_content].nil?
    @block_content_shim
  end

  private
  def initialize_block_content
    @block_content_shim ||= self.class.properties.new
    @block_content_shim.assign_attributes(self[:block_content]) unless self[:block_content].nil?
  end
end
