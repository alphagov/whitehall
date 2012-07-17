class Publication < Edition
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include Edition::Attachable
  include Edition::Countries
  include Edition::Featurable

  validates :publication_date, presence: true
  validates :isbn, isbn_format: true, allow_blank: true
  validates :order_url, format: URI::regexp(%w(http https)), allow_blank: true
  validates :order_url, presence: {
    message: "must be entered as you've entered a price",
    if: lambda { |publication| publication.price.present? }
  }
  validates :publication_type_id, presence: true
  validates :price, numericality: {
    allow_blank: true, greater_than: 0
  }

  before_save :store_price_in_pence

  scope :with_content_containing, -> *keywords {
    pattern = "(#{keywords.join('|')})"
    where("#{table_name}.title REGEXP :pattern OR #{table_name}.body REGEXP :pattern", pattern: pattern)
  }

  def publication_type
    PublicationType.find_by_id(publication_type_id)
  end

  def publication_type=(publication_type)
    self.publication_type_id = publication_type && publication_type.id
  end

  def has_summary?
    true
  end

  def self.published_in_reverse_chronological_order
    published.order(arel_table[:publication_date].desc)
  end

  def national_statistic?
    publication_type == PublicationType::NationalStatistics
  end

  def price
    return @price if @price
    return price_in_pence / 100.0 if price_in_pence
  end

  def price=(price_in_pounds)
    @price = price_in_pounds
  end

  private

  def store_price_in_pence
    self.price_in_pence = if price && price.to_s.empty?
      nil
    elsif price
      price.to_f * 100
    end
  end
end
