class Publication < Edition
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include ::Attachable
  include Edition::AlternativeFormatProvider
  include Edition::Countries
  include Edition::DocumentSeries

  attachable :edition

  validates :publication_date, presence: true
  validates :publication_type_id, presence: true

  after_update { |p| p.published_related_policies.each(&:update_published_related_publication_count) }

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

  def set_timestamp_for_sorting
    self.timestamp_for_sorting = publication_date
  end
end
