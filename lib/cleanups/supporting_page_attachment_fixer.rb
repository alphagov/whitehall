# Legacy supporting page attachment association
# We need to use this to reconstruct the missing attachment records
class SupportingPageAttachment < ActiveRecord::Base
  belongs_to :attachment
  belongs_to :supporting_page
end

# Load the original model and add legacy associations
require 'supporting_page'
class SupportingPage < ActiveRecord::Base
  has_many :supporting_page_attachments
  has_many :legacy_attachments, source: :attachment, through: :supporting_page_attachments, class_name: "Attachment"
end

module Cleanups
  class SupportingPageAttachmentFixer
    def initialize(logger = nil)
      @logger = logger || Logger.new($stdout)
    end

    def run!
      legacy_attachment_joins = SupportingPageAttachment.includes(supporting_page: :attachments).order("attachments.created_at asc")

      legacy_attachment_joins.group_by { |la| la.supporting_page }.each do |supporting_page, legacy_attachment_joins|
        next if supporting_page.nil?

        legacy_attachment_joins.each.with_index do |spa, i|
          attachment = spa.attachment
          next if attachment.nil?

          if has_attachment(supporting_page.attachments, attachment)
            @logger.info "Found:    #{supporting_page.slug} - #{attachment.id} '#{attachment.title}', changing order from #{attachment.ordering} to #{i}, created_at = #{attachment.created_at}"
            attachment.update_column(:ordering, i)
          else
            @logger.info "Creating: #{supporting_page.slug} - #{attachment.id} '#{attachment.title}', seting order to #{i}, created_at = #{attachment.created_at}"
            new_attachment_attributes = attachment.attributes.except(*ignored_attributes)
            new_attachment_attributes["ordering"] = i
            supporting_page.attachments.create!(new_attachment_attributes)
          end
        end
      end
    end

    def show_problems
      errors = []
      existing = Attachment.where(attachable_type: "SupportingPage").includes(:attachable).group_by do |a|
        a.attachable
      end
      SupportingPageAttachment.includes(supporting_page: :attachments).find_each do |spa|
        existing_attachments = existing.fetch(spa.supporting_page, [])
        next if spa.attachment.nil?

        if ! has_attachment(existing_attachments, spa.attachment)
          errors << "#{spa.supporting_page.edition_id}: #{spa.attachment.id}"
        end
      end
      errors
    end

    def ignored_attributes
      %w{id attachable_id attachable_type updated_at ordering}
    end

    def has_attachment(actual_attachments, expected_attachment)
      actual_attachments.any? do |actual|
        actual.attributes.except(*ignored_attributes) == expected_attachment.attributes.except(*ignored_attributes)
      end
    end
  end
end
