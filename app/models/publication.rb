class Publication < Publicationesque
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::AlternativeFormatProvider
  include Edition::WorldLocations
  include Edition::StatisticalDataSets
  include Edition::HtmlVersion
  include Edition::CanApplyToLocalGovernmentThroughRelatedPolicies
  include Edition::TopicalEvents

  validates :publication_date, presence: true, unless: ->(edition) { edition.can_have_some_invalid_data? }
  validates :publication_date, recent_date: true, unless: ->(edition) { edition.can_have_some_invalid_data? }
  validates :publication_type_id, presence: true
  validate :only_publications_allowed_invalid_data_can_be_awaiting_type

  after_update { |p| p.published_related_policies.each(&:update_published_related_publication_count) }

  def self.not_statistics
    where("publication_type_id NOT IN (?)", PublicationType.statistical.map(&:id))
  end

  def self.statistics
    where(publication_type_id: PublicationType.statistical.map(&:id))
  end

  def allows_inline_attachments?
    false
  end

  def allows_attachment_references?
    true
  end

  def display_type
    publication_type.singular_name
  end

  def display_type_key
    publication_type.key
  end

  def search_format_types
    super + [Publication.search_format_type] + self.publication_type.search_format_types
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

  def national_statistic?
    publication_type == PublicationType::NationalStatistics
  end

  def first_public_at
    publication_date.to_datetime unless publication_date.nil?
  end

  def make_public_at(date)
  end

  def first_published_date
    publication_date.to_date
  end

  def statistics?
    PublicationType.statistical.include?(publication_type)
  end

  def access_limited_by_default?
    # Without a publication_type we can't correctly work out if we should
    # be access_limited or not.  When we get a publication_type, we'll
    # sort this out.  Happily, abesence of a publication_type invalidates
    # us, so returning nil is ok even though it would break the SQL insert
    if self.publication_type.present?
      self.publication_type.access_limited_by_default?
    else
      nil
    end
  end

  def translatable?
    true
  end

  private

  def only_publications_allowed_invalid_data_can_be_awaiting_type
    unless self.can_have_some_invalid_data?
      errors.add(:publication_type, 'must be changed') if PublicationType.migration.include?(self.publication_type)
    end
  end
end
