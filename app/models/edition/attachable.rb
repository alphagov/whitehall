module Edition::Attachable
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_after_save(document)
      @document.attachments.each do |a|
        document.document_attachments.create(attachment_id: a.id)
      end
    end
  end

  included do
    has_many :document_attachments, foreign_key: "edition_id", dependent: :destroy
    has_many :attachments, through: :document_attachments

    accepts_nested_attributes_for :document_attachments, reject_if: -> da { da.fetch(:attachment_attributes, {}).values.all?(&:blank?) }, allow_destroy: true

    add_trait Trait
  end

  def allows_attachments?
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

  def indexable_attachment_content
    attachments.all.map { |a| "Attachment: #{a.title}" }.join(". ")
  end
end