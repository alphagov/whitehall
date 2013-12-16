module Attachable
  extend ActiveSupport::Concern

  included do
    has_many :attachments, as: :attachable, order: 'attachments.ordering, attachments.id', inverse_of: :attachable

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

  def build_empty_file_attachment
    attachment = FileAttachment.new
    attachment.build_attachment_data
    attachments << attachment
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

  def allows_html_attachments?
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

  def next_ordering
    max = attachments.maximum(:ordering)
    max ? max + 1 : 0
  end

  def reorder_attachments(ordered_attachment_ids)
    return if ordered_attachment_ids.empty?

    transaction do
      # Attachment has a unique constraint on attachable type/id and ordering.
      # This stops us simply changing the ordering values of existing
      # attachments, as two rows end up with the same ordering value during
      # the update, violating the constraint.

      # To get around it, we check that we can start at 0 and fit all the
      # ordering values below the current lowest ordering.
      if ordered_attachment_ids.count < attachments.minimum(:ordering)
        start_at = 0

      # Otherwise, we start reordering at the next available number
      else
        start_at = next_ordering
      end

      ordered_attachment_ids.each.with_index(start_at) do |attachment_id, ordering|
        attachments.find(attachment_id).update_column(:ordering, ordering)
      end
    end
  end
end
