module Document::Attachable
  extend ActiveSupport::Concern

  class Trait < Document::Traits::Trait
    def process_associations_after_save(document)
      @document.attachments.each do |a|
        document.document_attachments.create(attachment_id: a.id)
      end
    end
  end

  included do
    has_many :document_attachments, foreign_key: "document_id", dependent: :destroy
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
    attachments.pdf
  end
end