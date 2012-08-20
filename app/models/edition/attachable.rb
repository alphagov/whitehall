module Edition::Attachable
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(edition)
      @edition.attachments.each do |a|
        edition.edition_attachments.create(attachment_id: a.id)
      end
    end
  end

  included do
    has_many :edition_attachments, foreign_key: "edition_id", dependent: :destroy
    has_many :attachments, through: :edition_attachments

    accepts_nested_attributes_for :edition_attachments, reject_if: :no_substantive_attachment_attributes?, allow_destroy: true

    validates :alternative_format_provider, presence: true, if: :has_attachments?
    validate :alternative_format_provider_has_contact_email, if: :has_attachments?

    def no_substantive_attachment_attributes?(attrs)
      attrs.fetch(:attachment_attributes, {}).except(:accessible).values.all?(&:blank?)
    end
    private :no_substantive_attachment_attributes?

    add_trait Trait
  end

  def has_attachments?
    attachments.any?
  end

  def allows_attachments?
    true
  end

  def allows_inline_attachments?
    true
  end

  def has_thumbnail?
    thumbnailable_attachments.any?
  end

  def thumbnail_url
    thumbnailable_attachments.first.url(:thumbnail)
  end

  def thumbnailable_attachments
    attachments.select {|a| a.content_type == AttachmentUploader::PDF_CONTENT_TYPE}
  end

  def indexable_content
    (super + " " + indexable_attachment_content).strip
  end

  private

  def alternative_format_provider_has_contact_email
    if alternative_format_provider
      if ! alternative_format_provider.alternative_format_contact_email.present?
        errors.add(:alternative_format_provider, "must have an email address set")
      end
    end
  end

  def indexable_attachment_content
    attachments.all.map { |a| "Attachment: #{a.title}" }.join(". ")
  end
end
