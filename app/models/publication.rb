class Publication < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::WorldLocations
  include Edition::DocumentSeries
  include Edition::StatisticalDataSets

  validates :publication_date, presence: true
  validates :publication_type_id, presence: true
  validate :only_publications_allowed_invalid_data_can_be_awaiting_type

  after_update { |p| p.published_related_policies.each(&:update_published_related_publication_count) }
  before_save ->(record) { record.access_limited = nil unless record.publication_type.can_limit_access? }

  def allows_inline_attachments?
    false
  end

  def allows_attachment_references?
    true
  end

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end

  def publication_type=(publication_type)
    self.publication_type_id = publication_type && publication_type.id
  end

  def can_have_summary?
    true
  end

  def national_statistic?
    publication_type == PublicationType::NationalStatistics
  end

  def first_published_date
    publication_date.to_date
  end

  def statistics?
    [PublicationType::Statistics, PublicationType::NationalStatistics].include?(publication_type)
  end

  def can_limit_access?
    true
  end

  def access_limited?
    statistics? && super
  end

  private

  def only_publications_allowed_invalid_data_can_be_awaiting_type
    unless self.can_have_some_invalid_data?
      errors.add(:publication_type, 'must be changed') if PublicationType::ImportedAwaitingType == self.publication_type
    end
  end

  def set_timestamp_for_sorting
    self.timestamp_for_sorting = publication_date
  end
end
