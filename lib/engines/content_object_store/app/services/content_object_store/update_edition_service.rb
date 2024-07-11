module ContentObjectStore
  class UpdateEditionService
    def initialize(content_block_edition)
      @content_block_edition = content_block_edition
    end

    # TODO: This will allow the user to set both to blank
    # TODO: This needs to forward updates to Publishing API
    def call(document_title, details)
      ActiveRecord::Base.transaction do
        document = @content_block_edition.document
        document.update!(title: document_title)

        @content_block_edition.update!(details: details)
        @content_block_edition.save
      end
    end
  end
end
