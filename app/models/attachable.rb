module Attachable
  extend ActiveSupport::Concern

  module ClassMethods
    class Trait < Edition::Traits::Trait
      def process_associations_after_save(edition)
        edition.related_editions = @edition.related_editions
      end
    end

    def attachable(class_name)
      self.attachment_join_table_name = "#{class_name}_attachments".to_sym

      has_many attachment_join_table_name, foreign_key: "#{class_name}_id", dependent: :destroy
      has_many :attachments, through: attachment_join_table_name

      no_substantive_attachment_attributes = ->(attrs) do
        attrs.fetch(:attachment_attributes, {}).except(:accessible).values.all?(&:blank?)
      end
      accepts_nested_attributes_for attachment_join_table_name, reject_if: no_substantive_attachment_attributes, allow_destroy: true

      if respond_to?(:add_trait)
        add_trait do
          def process_associations_after_save(edition)
            @edition.attachments.each do |a|
              edition.send(edition.class.attachment_join_table_name).create(attachment_id: a.id)
            end
          end
        end
      end
    end
  end

  included do
    class_attribute :attachment_join_table_name
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
