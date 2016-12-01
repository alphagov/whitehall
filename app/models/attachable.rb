module Attachable
  extend ActiveSupport::Concern

  included do
    has_many :attachments,
             -> { not_deleted.order('attachments.ordering, attachments.id') },
             as: :attachable,
             inverse_of: :attachable
    has_many :html_attachments,
             -> { not_deleted.order('attachments.ordering, attachments.id') },
             as: :attachable

    if respond_to?(:add_trait)
      add_trait do
        def process_associations_after_save(edition)
          @edition.attachments.each do |attachment|
            edition.attachments << attachment.deep_clone
          end
        end
      end
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

  def allows_file_attachments?
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

  def allows_external_attachments?
    false
  end

  def allows_attachment_type?(type)
    case type
    when "html"
      allows_html_attachments?
    when "external"
      allows_external_attachments?
    when "file"
      allows_file_attachments?
    else
      false
    end
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

  def has_official_document?
    has_command_paper? || has_act_paper?
  end

  def has_command_paper?
    attachments.any?(&:is_command_paper?)
  end

  def has_act_paper?
    attachments.any?(&:is_act_paper?)
  end

  def search_index
    super.merge("attachments" => attachments.map(&:search_index))
  end

  def next_ordering
    max = Attachment.where(attachable_id: id, attachable_type: self.class.base_class).maximum(:ordering)
    max ? max + 1 : 0
  end

  def delete_all_attachments
    attachments.each { |attachment| attachment.update(deleted: true) }
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
      if ordered_attachment_ids.count < attachments.unscoped.minimum(:ordering)
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
