module PublishingApi
  class CorporateInformationPagePresenter
    extend Forwardable
    include UpdateTypeHelper

    SCHEMA_NAME = 'corporate_information_page'

    attr_reader :update_type

    def initialize(corporate_information_page, update_type: nil)
      self.corporate_information_page = corporate_information_page
      self.update_type =
        update_type || default_update_type(corporate_information_page)
    end

    def_delegator :corporate_information_page, :content_id

    def content
      BaseItemPresenter
        .new(corporate_information_page)
        .base_attributes
        .merge(PayloadBuilder::PublicDocumentPath.for(corporate_information_page))
        .merge(
          description: corporate_information_page.summary,
          details: details,
          document_type: display_type_key,
          public_updated_at: public_updated_at,
          rendering_app: Whitehall::RenderingApp::WHITEHALL_FRONTEND,
          schema_name: SCHEMA_NAME,
        )
    end

    def links
      LinksPresenter
        .new(corporate_information_page)
        .extract(
          %i(
            organisations
          )
        )
    end

  private

    attr_accessor :corporate_information_page
    attr_writer :update_type

    def_delegator :corporate_information_page, :display_type_key

    def base_details
      {
        body: body,
      }
    end

    def body
      Whitehall::GovspeakRenderer
        .new
        .govspeak_edition_to_html(corporate_information_page)
    end

    def details
      base_details
        .merge(Organisation.for(corporate_information_page))
    end

    def public_updated_at
      public_updated_at = corporate_information_page.public_timestamp ||
        corporate_information_page.updated_at

      public_updated_at = if public_updated_at.respond_to?(:to_datetime)
                            public_updated_at.to_datetime
                          end

      public_updated_at.rfc3339
    end

    class Organisation
      extend Forwardable

      def self.for(corporate_information_page)
        new(corporate_information_page).call
      end

      def initialize(corporate_information_page)
        self.corporate_information_page = corporate_information_page
      end

      def call
        return {} unless organisation.present?

        {
          organisation: organisation.content_id
        }
      end

    private

      attr_accessor :corporate_information_page
      def_delegator :corporate_information_page, :owning_organisation, :organisation
    end
  end
end
