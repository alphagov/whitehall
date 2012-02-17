class Publication < Document
  include Document::NationalApplicability
  include Document::Ministers
  include Document::FactCheckable
  include Document::RelatedPolicies
  include Document::Attachable
  include Document::Countries
  include Document::Featurable

  validates :publication_date, presence: true
  validates :isbn, isbn_format: true, allow_blank: true
  validates :order_url, format: URI::regexp(%w(http https)), allow_blank: true

  def has_summary?
    true
  end

  def self.published_in_reverse_chronological_order
    published.order(arel_table[:publication_date].desc)
  end
end
