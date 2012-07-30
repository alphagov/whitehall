class Publication < Edition
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include Edition::Attachable
  include Edition::Countries

  validates :publication_date, presence: true
  validates :publication_type_id, presence: true


  scope :with_content_containing, -> *keywords {
    pattern = "(#{keywords.join('|')})"
    where("#{table_name}.title REGEXP :pattern OR #{table_name}.body REGEXP :pattern", pattern: pattern)
  }

  scope :published_before, -> date { where(arel_table[:publication_date].lteq(date)) }
  scope :published_after,  -> date { where(arel_table[:publication_date].gteq(date)) }

  scope :in_chronological_order, order(arel_table[:publication_date].asc)
  scope :in_reverse_chronological_order, order(arel_table[:publication_date].desc)

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end

  def publication_type=(publication_type)
    self.publication_type_id = publication_type && publication_type.id
  end

  def has_summary?
    true
  end

  def national_statistic?
    publication_type == PublicationType::NationalStatistics
  end
end
