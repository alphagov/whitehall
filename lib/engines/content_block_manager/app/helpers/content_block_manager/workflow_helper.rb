module ContentBlockManager
  module WorkflowHelper

    CONFIRMATION_COPY = Data.define(:panel_copy, :paragraph_copy)
    def confirmation_copy(is_scheduled:, content_block_edition:)
      if is_scheduled
        panel_copy = "#{content_block_edition.block_type.humanize} scheduled to publish on #{I18n.l(@content_block_edition.scheduled_publication, format: :long_ordinal)}"
        paragraph_copy = "You can now view the updated schedule of the content block."
      elsif more_than_one_edition?(content_block_edition:)
        panel_copy = "#{content_block_edition.block_type.humanize} published"
        paragraph_copy = "You can now view the updated content block."
      else
        panel_copy = "#{content_block_edition.block_type.humanize} created"
        paragraph_copy = "You can now view the content block."
      end
      CONFIRMATION_COPY.new(panel_copy:, paragraph_copy:)
    end

    def more_than_one_edition?(content_block_edition:)
      content_block_edition.document.editions.count > 1
    end

  end
end