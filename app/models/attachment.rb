# Abstract base class for Attachments.
#
# Attachment instances should never be directly created. Instead, the
# more concreate FileAttachment and HtmlAttachment sub-classes should be used
# in all instances.
#
class Attachment < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true
  has_one :attachment_source

  belongs_to :attachment_data

  delegate :url, :content_type, :pdf?, :csv?,
    :extracted_text, :file_extension, :file_size,
    :number_of_pages, :file, :filename, :virus_status,
    to: :attachment_data

  before_save :set_ordering, if: -> { ordering.blank? }

  after_destroy :destroy_unused_attachment_data

  accepts_nested_attributes_for :attachment_data

  VALID_COMMAND_PAPER_NUMBER_PREFIXES = ['C.', 'Cd.', 'Cmd.', 'Cmnd.', 'Cm.']

  validates_with AttachmentValidator
  validates :attachable, presence: true
  validates :title, presence: true
  validates :isbn, isbn_format: true, allow_blank: true
  validates :command_paper_number, format: {
    with: /^(#{VALID_COMMAND_PAPER_NUMBER_PREFIXES.join('|')}) ?\d+/,
    allow_blank: true,
    message: "is invalid. The number must start with one of #{VALID_COMMAND_PAPER_NUMBER_PREFIXES.join(', ')}"
  }
  validates :order_url, uri: true, allow_blank: true
  validates :order_url, presence: {
    message: "must be entered as you've entered a price",
    if: -> publication { publication.price.present? }
  }
  validates :price, numericality: {
    allow_blank: true, greater_than: 0
  }

  scope :with_filename, ->(basename) {
    joins(:attachment_data).where('attachment_data.carrierwave_file = ?', basename)
  }

  scope :files, where('type = ?', 'FileAttachment')

  scope :for_current_locale, -> { where(locale: [nil, I18n.locale]) }

  def self.parliamentary_sessions
    (1951..Time.zone.now.year).to_a.reverse.map do |year|
      starts = Date.new(year).strftime('%Y')
      ends = Date.new(year + 1).strftime('%y')  # %y gives last two digits of year
      "#{starts}-#{ends}"
    end
  end

  def price
    if @price
      @price
    elsif price_in_pence
      price_in_pence / 100.0
    end
  end

  def price=(price_in_pounds)
    @price = price_in_pounds
    store_price_in_pence
  end

  def html?
    false
  end

  def could_contain_viruses?
    true
  end

  def is_command_paper?
    command_paper_number.present? || unnumbered_command_paper?
  end

  def is_act_paper?
    hoc_paper_number.present? || unnumbered_hoc_paper?
  end

  private

  def store_price_in_pence
    self.price_in_pence = if price && price.to_s.empty?
      nil
    elsif price
      price.to_f * 100
    end
  end

  # Only destroy the associated attachment_data record if no other
  # attachments are using it
  def destroy_unused_attachment_data
    if attachment_data && Attachment.where(attachment_data_id: attachment_data.id).empty?
      attachment_data.destroy
    end
  end

  def set_ordering
    self.ordering = attachable.next_ordering
  end
end
