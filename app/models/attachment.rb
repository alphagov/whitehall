class Attachment < ActiveRecord::Base
  has_many :edition_attachments
  has_many :editions, through: :edition_attachments
  has_one :attachment_source

  belongs_to :attachment_data

  delegate :url, :content_type,
    :pdf?, :file_extension, :file_size,
    :number_of_pages, :file, :filename,
    to: :attachment_data

  after_destroy :destroy_attachment_data_if_required

  accepts_nested_attributes_for :attachment_data

  VALID_COMMAND_PAPER_NUMBER_PREFIXES = ['C.', 'Cd.', 'Cmd.', 'Cmnd.', 'Cm.']

  validates_with AttachmentValidator
  validates :title, presence: true
  validates :isbn, isbn_format: true, allow_blank: true
  validates :command_paper_number, format: {
    with: /^(#{VALID_COMMAND_PAPER_NUMBER_PREFIXES.join('|')}) ?\d+/,
    allow_blank: true,
    message: "is invalid. The number must start with one of #{VALID_COMMAND_PAPER_NUMBER_PREFIXES.join(', ')}"
  }
  validates :order_url, format: URI::regexp(%w(http https)), allow_blank: true
  validates :order_url, presence: {
    message: "must be entered as you've entered a price",
    if: -> publication { publication.price.present? }
  }
  validates :price, numericality: {
    allow_blank: true, greater_than: 0
  }

  def self.parliamentary_sessions
    (1951..Time.zone.now.year).to_a.reverse.map do |year|
      [Date.new(year).strftime('%Y'), Date.new(year + 1).strftime('%y')].join('-')
    end
  end

  def price
    return @price if @price
    return price_in_pence / 100.0 if price_in_pence
  end

  def price=(price_in_pounds)
    @price = price_in_pounds
    store_price_in_pence
  end

  def accessible_by?(user)
    editions.all? { |e| e.accessible_by?(user) }
  end

  private

  def store_price_in_pence
    self.price_in_pence = if price && price.to_s.empty?
      nil
    elsif price
      price.to_f * 100
    end
  end

  def destroy_attachment_data_if_required
    unless Attachment.where(attachment_data_id: attachment_data.id).any?
      attachment_data.destroy
    end
  end
end
