module ConfigurableDocumentTypes
  module Conversions
    class NewsArticle
      def initialize(old_type, new_type, api = Whitehall::PublishingApi)
        @old_type = old_type
        @new_type = new_type
        @api = api
      end

      def convert(edition)
        # TODO: make this work for all possible news article conversions
        edition.edition_organisations.delete_all

        @api.patch_links(edition)
        edition.configurable_document_type = @new_type.key
      end
    end
  end
end