module ContentBlockManager
  class ConfirmationCopyPresenter
    def initialize(content_block_edition)
      @content_block_edition = content_block_edition
    end

    def for_panel
      if is_scheduled?
        "#{content_block_edition.block_type.humanize} scheduled to publish on #{I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)}"
      elsif more_than_one_edition?
        "#{content_block_edition.block_type.humanize} published"
      else
        "#{content_block_edition.block_type.humanize} created"
      end
    end

    def for_paragraph
      if is_scheduled?
        "You can now view the updated schedule of the content block."
      elsif more_than_one_edition?
        "You can now view the updated content block."
      else
        "You can now view the content block."
      end
    end

  private

    attr_reader :content_block_edition

    def more_than_one_edition?
      content_block_edition.document.editions.count > 1
    end

    def is_scheduled?
      content_block_edition.scheduled_publication.present?
    end
  end
end
