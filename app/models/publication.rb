# Publications live at https://www.gov.uk/government/publications
#
# There are many types of publications - see `PublicationType`.
#
# Publication pages are rendered by Whitehall.
#
# Note that `Publicationesque` inherits from `Edition`
class Publication < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::WorldLocations
  include Edition::StatisticalDataSets
  include Edition::TopicalEvents

  before_validation :set_statistics_announcement
  validates :publication_type_id, presence: true
  validate :only_publications_allowed_invalid_data_can_be_awaiting_type
  validate :attachment_required_before_moving_out_of_draft
  validate :statistics_announcement_is_matching_type, if: :statistics_announcement

  has_one :statistics_announcement
  attr_accessor :statistics_announcement_id

  after_save :touch_statistics_announcement

  scope :statistical_publications, -> { where("publication_type_id IN (?)", PublicationType.statistical.map(&:id)) }
  scope :non_statistical_publications, -> { where("publication_type_id NOT IN (?)", PublicationType.statistical.map(&:id)) }
  scope :corporate_publications, -> { where(publication_type_id: PublicationType::CorporateReport.id) }

  def set_statistics_announcement
    if statistics_announcement_id.present?
      self.statistics_announcement = StatisticsAnnouncement.find(statistics_announcement_id)
    end
  end

  def statistics_announcement_is_matching_type
    unless statistics_announcement.publication_type == publication_type
      errors.add(:publication_type_id, message: "does not match announcement type: must be '#{statistics_announcement.publication_type.singular_name}'")
    end
  end

  def touch_statistics_announcement
    if published? && !statistics_announcement.nil?
      statistics_announcement.reload.touch
    end
  end

  def self.subtypes
    PublicationType.all
  end

  def self.by_subtype(subtype)
    where(publication_type_id: subtype.id)
  end

  def self.by_subtypes(subtype_ids)
    where(publication_type_id: subtype_ids)
  end

  def self.not_statistics
    where("publication_type_id NOT IN (?)", PublicationType.statistical.map(&:id))
  end

  def self.statistics
    where(publication_type_id: PublicationType.statistical.map(&:id))
  end

  def rendering_app
    Whitehall::RenderingApp::GOVERNMENT_FRONTEND
  end

  def allows_inline_attachments?
    false
  end

  def allows_external_attachments?
    true
  end

  def allows_attachment_references?
    true
  end

  def can_have_attached_house_of_commons_papers?
    true
  end

  def all_nation_applicability_selected?
    newly_created = document.nil? || document.new_record?
    newly_created ? false : all_nation_applicability
  end

  def display_type_key
    publication_type.key
  end

  def detailed_format
    publication_type.detailed_format || super
  end

  def search_format_types
    super + [Publication.search_format_type] + publication_type.search_format_types
  end

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end

  def publication_type=(publication_type)
    self.publication_type_id = (publication_type && publication_type.id)
    set_access_limited
    self.publication_type
  end

  def publication_type_id=(publication_type_id)
    super
    set_access_limited
    self.publication_type_id
  end

  def has_changed_publication_type?
    previous_edition && previous_edition.publication_type != publication_type
  end

  def national_statistic?
    publication_type == PublicationType::NationalStatistics
  end

  def statistics?
    PublicationType.statistical.include?(publication_type)
  end

  def access_limited_by_default?
    # Without a publication_type we can't correctly work out if we should
    # be access_limited or not.  When we get a publication_type, we'll
    # sort this out.  Happily, abesence of a publication_type invalidates
    # us, so returning nil is ok even though it would break the SQL insert
    if publication_type.present?
      publication_type.access_limited_by_default?
    end
  end

  def translatable?
    !non_english_edition?
  end

  def has_attachments?
    !attachments.empty?
  end

  def search_index
    super.merge(
      has_official_document: has_official_document?,
      has_command_paper: has_command_paper?,
      has_act_paper: has_act_paper?,
    )
  end

  def path_name
    statistics? ? "statistic" : "publication"
  end

  def allows_html_attachments?
    true
  end

  def associated_documents
    attachables.flat_map(&:html_attachments)
  end

  def deleted_associated_documents
    attachables.flat_map(&:deleted_html_attachments)
  end

  def base_path
    return "/government/statistics/#{slug}" if statistics? || national_statistic?

    "/government/publications/#{slug}"
  end

  def publishing_api_presenter
    PublishingApi::PublicationPresenter
  end

private

  def attachment_required_before_moving_out_of_draft
    if %w[submitted scheduled published].include?(state) && !has_attachments?
      errors.add(:base, "Publications must have either a URL for off-site documents, an attachment or HTML version before being #{current_state}")
    end
  end

  def only_publications_allowed_invalid_data_can_be_awaiting_type
    if !can_have_some_invalid_data? && PublicationType.migration.include?(publication_type)
      errors.add(:publication_type, "must be changed")
    end
  end
end
