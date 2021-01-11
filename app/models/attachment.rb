# Abstract base class for Attachments.
class Attachment < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :scoped, scope: :attachable

  belongs_to :attachable, polymorphic: true
  has_one :attachment_source

  belongs_to :attachment_data

  before_save :set_ordering, if: -> { ordering.blank? }
  before_save :nilify_locale_if_blank
  before_save :prevent_saving_of_abstract_base_class

  VALID_COMMAND_PAPER_NUMBER_PREFIXES = ["CP", "C.", "Cd.", "Cmd.", "Cmnd.", "Cm."].freeze

  validates_with AttachmentValidator, on: :user_input
  validates :attachable, presence: true
  validates :title, presence: true, length: { maximum: 255 }
  validates :isbn, isbn_format: true, allow_blank: true
  validates :unique_reference, length: { maximum: 255 }, allow_blank: true

  scope :with_filename,
        lambda { |basename|
          joins(:attachment_data).where("attachment_data.carrierwave_file = ?", basename)
        }

  scope :files, -> { where(type: FileAttachment) }

  scope :for_current_locale, -> { where(locale: [nil, I18n.locale]) }

  scope :not_deleted, -> { where(deleted: false) }
  scope :deleted, -> { where(deleted: true) }

  class Null
    def deleted?
      false
    end

    def attachable
      Attachable::Null.new
    end
  end

  def self.parliamentary_sessions
    (1951..Time.zone.now.year).to_a.reverse.map do |year|
      starts = Date.new(year).strftime("%Y")
      ends = Date.new(year + 1).strftime("%y") # %y gives last two digits of year
      "#{starts}-#{ends}"
    end
  end

  def is_official_document?
    is_command_paper? || is_act_paper?
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

  def rtl_locale?
    return false if locale.blank?

    Locale.new(locale).rtl?
  end

  def search_index
    publishing_api_details
  end

  def publishing_api_details
    # fields in common across "file_attachment_asset",
    # "html_attachment_asset", "external_attachment_asset" schemas
    attachment_fields = {
      attachment_type: readable_type.downcase,
      id: id.to_s,
      locale: locale,
      title: title,
      url: url,
    }

    if attachable.allows_attachment_references?
      # fields just for "publication_attachment_asset" schema
      attachment_fields.merge!(
        command_paper_number: command_paper_number,
        hoc_paper_number: hoc_paper_number,
        isbn: isbn,
        parliamentary_session: nil,
        unique_reference: unique_reference,
        unnumbered_command_paper: unnumbered_command_paper?,
        unnumbered_hoc_paper: unnumbered_hoc_paper?,
      )
    end

    attachment_fields.merge(publishing_api_details_for_format).compact
  end

  def publishing_api_details_for_format
    {}
  end

  def deep_clone
    dup.tap do |clone|
      clone.safely_resluggable = false
    end
  end

  def external?
    false
  end

  def file?
    false
  end

  def html?
    false
  end

  def readable_type
    ""
  end

  def url
    raise NotImplementedError, "Subclasses must implement the url method"
  end

  def delete
    update_column(:deleted, true)
  end

  def destroy
    callbacks_result = transaction do
      run_callbacks(:destroy) do
        delete
      end
    end
    callbacks_result ? self : false
  end

private

  def set_ordering
    self.ordering = attachable.next_ordering
  end

  def nilify_locale_if_blank
    self.locale = nil if locale.blank?
  end

  def prevent_saving_of_abstract_base_class
    if type.nil? || type == "Attachment"
      raise "Attempted to save abstract base class Attachment"
    end
  end
end
