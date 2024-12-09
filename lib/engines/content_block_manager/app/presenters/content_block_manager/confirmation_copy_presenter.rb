module ContentBlockManager
  class ConfirmationCopyPresenter
    def initialize(content_block_edition)
      @content_block_edition = content_block_edition
    end

    def for_panel
      I18n.t("content_block_edition.confirmation_page.#{state}.banner", block_type:, date:)
    end

    def for_paragraph
      I18n.t("content_block_edition.confirmation_page.#{state}.detail")
    end

    def state
      if content_block_edition.scheduled?
        :scheduled
      elsif content_block_edition.document.editions.count > 1
        :updated
      else
        :created
      end
    end

  private

    attr_reader :content_block_edition

    def date
      I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal) if content_block_edition.scheduled_publication
    end

    def block_type
      content_block_edition.block_type.humanize
    end
  end
end
