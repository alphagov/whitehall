class Publication < Edition
  include Edition::NationalApplicability
  include Edition::Ministers
  include Edition::FactCheckable
  include Edition::RelatedPolicies
  include Edition::Attachable
  include Edition::Countries

  VALID_COMMAND_PAPER_NUMBER_PREFIXES = ['C.', 'Cd.', 'Cmd.', 'Cmnd.', 'Cm.']

  validates :publication_date, presence: true
  validates :isbn, isbn_format: true, allow_blank: true
  validates :command_paper_number, format: {
    with: /^(#{VALID_COMMAND_PAPER_NUMBER_PREFIXES.join('|')}) ?\d+/,
    allow_blank: true,
    message: "is invalid. The number must start with one of #{VALID_COMMAND_PAPER_NUMBER_PREFIXES.join(', ')}"
  }
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
