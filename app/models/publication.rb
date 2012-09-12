class Publication < Edition
  include Edition::Images
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include ::Attachable
  include Edition::Countries
  include Edition::DocumentSeries

  validates :publication_date, presence: true
  validates :publication_type_id, presence: true

  after_update { |p| p.published_related_policies.each(&:update_published_related_publication_count) }

  def self.published_before(date)
    where(arel_table[:publication_date].lteq(date))
  end
  def self.published_after(date)
    where(arel_table[:publication_date].gteq(date))
  end
  def self.in_chronological_order
    order(arel_table[:publication_date].asc)
  end
  def self.in_reverse_chronological_order
    order(arel_table[:publication_date].desc)
  end

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
end
