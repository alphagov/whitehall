module Edition::LiteEdition
  extend ActiveSupport::Concern

  UNMODIFIABLE_STATES = %w[scheduled published superseded deleted unpublished].freeze

  def creator
    edition_authors.first&.user
  end

  def creator=(user)
    if new_record?
      edition_author = edition_authors.first || edition_authors.build
      edition_author.user = user
    else
      raise "author can only be set on new records"
    end
  end

  # 'previously_published' is a transient attribute populated
  # by request parameters, and because it's not persisted it's
  # not converted to a boolean, hence this manual attr writer method.
  # NOTE: This method isn't called when the user fails to select an
  # option for this field and so the value remains nil.
  def previously_published=(value)
    @previously_published = value.to_s == "true"
  end

  def previously_published
    return first_published_at.present? unless new_record?

    @previously_published
  end

  def can_set_previously_published?
    true
  end

  def can_be_related_to_organisations?
    false
  end

  def historic?
    return false unless government

    political? && !government.current?
  end

  def government
    @government ||= Government.on_date(date_for_government) unless date_for_government.nil?
  end

  def first_public_at
    first_published_at
  end

  def previous_edition
    document.ever_published_editions.where.not(id:).last
  end

  def display_type
    I18n.t("document.type.#{display_type_key}", count: 1)
  end

  def display_type_key
    format_name.tr(" ", "_")
  end

  def format_name
    self.class.format_name
  end

  def public_path(options = {})
    return if base_path.nil?

    options[:locale] ||= primary_locale
    append_url_options(base_path, options)
  end

  def base_path
    url_slug = slug || id.to_param
    "/government/generic-editions/#{url_slug}"
  end

  def attachables
    []
  end

  def unmodifiable?
    persisted? && UNMODIFIABLE_STATES.include?(state_was)
  end

  def publishing_api_presenter
    PublishingApi::GenericEditionPresenter
  end

  def set_auth_bypass_id
    self.auth_bypass_id = SecureRandom.uuid
  end

  included do
    self.table_name = "editions"

    include Edition::Traits
    # Adds a statemachine for the publishing workflow. States and methods like
    # `publish` and `withdraw` are defined here.
    include Edition::Workflow
    include Edition::Translatable
    include Edition::Identifiable
    include Edition::LimitedAccess
    include Edition::ActiveEditors

    include AuditTrail

    has_many :edition_authors, dependent: :destroy, foreign_key: :edition_id
    has_many :authors, through: :edition_authors, source: :user

    validates :title, presence: true, if: :title_required?, length: { maximum: 255 }

    before_create :set_auth_bypass_id

    def self.format_name
      @format_name ||= model_name.human.downcase
    end
  end

private

  def date_for_government
    published_edition_date = first_public_at.try(:to_date)
    draft_edition_date = updated_at.try(:to_date)
    published_edition_date || draft_edition_date
  end
end
