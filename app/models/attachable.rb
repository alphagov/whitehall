module Attachable
  extend ActiveSupport::Concern

  included do
    has_many :attachments, as: :attachable, order: 'attachments.ordering, attachments.id', before_add: :set_order

    no_substantive_attachment_attributes = ->(attrs) do
      attrs.except(:accessible, :attachment_data_attributes).values.all?(&:blank?) &&
        attrs.fetch(:attachment_data_attributes, {}).values.all?(&:blank?)
    end
    accepts_nested_attributes_for :attachments, reject_if: no_substantive_attachment_attributes, allow_destroy: true

    if respond_to?(:add_trait)
      add_trait do
        def process_associations_after_save(edition)
          @edition.attachments.each do |attachment|
            edition.attachments << attachment.class.new(attachment.attributes)
          end
        end
      end
    end
  end

  def build_empty_attachment
    unless attachments.any?(&:new_record?)
      attachment = attachments.build
      attachment.build_attachment_data
    end
  end

  def valid_virus_state?
    attachments.each do |attachment|
      if attachment.could_contain_viruses? && (attachment.virus_status != :clean)
        return false
      end
    end
    true
  end

  def allows_attachments?
    true
  end

  def allows_attachment_references?
    false
  end

  def allows_inline_attachments?
    true
  end

  def can_order_attachments?
    !allows_inline_attachments?
  end

  def can_have_attached_house_of_commons_papers?
    false
  end

  def has_thumbnail?
    thumbnailable_attachments.any?
  end

  def thumbnail_url
    thumbnailable_attachments.first.url(:thumbnail)
  end

  def thumbnailable_attachments
    attachments.select { |a| a.content_type == AttachmentUploader::PDF_CONTENT_TYPE }
  end

  def search_index
    super.merge("attachments" => extracted_attachments)
  end

  def extracted_attachments
    attachments.map do |attachment|
      {
        title: attachment.title,
        content: attachment.extracted_text,
        isbn: attachment.isbn,
        command_paper_number: attachment.command_paper_number,
        unique_reference: attachment.unique_reference,
        hoc_paper_number: attachment.hoc_paper_number
      }
    end
  end

  private

  def set_order(new_attachment)
    new_attachment.ordering = next_ordering unless new_attachment.ordering.present?
  end

  def next_ordering
    max = attachments.maximum(:ordering)
    max ? max + 1 : 0
  end
end
