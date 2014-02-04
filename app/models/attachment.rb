# Abstract base class for Attachments.
class Attachment < ActiveRecord::Base
  belongs_to :attachable, polymorphic: true
  has_one :attachment_source

  belongs_to :attachment_data

  before_save :set_ordering, if: -> { ordering.blank? }
  before_save :nilify_locale_if_blank
  before_save :prevent_saving_of_abstract_base_class

  VALID_COMMAND_PAPER_NUMBER_PREFIXES = ['C.', 'Cd.', 'Cmd.', 'Cmnd.', 'Cm.']

  validates_with AttachmentValidator
  validates :attachable, presence: true
  validates :title, presence: true
  validates :isbn, isbn_format: true, allow_blank: true
  validates :command_paper_number, format: {
    with: /\A(#{VALID_COMMAND_PAPER_NUMBER_PREFIXES.join('|')}) ?\d+/,
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

  scope :files, -> { where(type: FileAttachment) }

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

  def is_command_paper?
    command_paper_number.present? || unnumbered_command_paper?
  end

  def is_act_paper?
    hoc_paper_number.present? || unnumbered_hoc_paper?
  end

  def attachable_model_name
    attachable.class.model_name.human.downcase
  end

  private

  def store_price_in_pence
    self.price_in_pence = if price && price.to_s.empty?
      nil
    elsif price
      price.to_f * 100
    end
  end

  def set_ordering
    self.ordering = attachable.next_ordering
  end

  def nilify_locale_if_blank
    self.locale = nil if locale.blank?
  end

  def prevent_saving_of_abstract_base_class
    if type.nil? || type == "Attachment"
      raise RuntimeError, "Attempted to save abstract base class Attachment"
    end
  end
end
