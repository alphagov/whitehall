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
        .merge(
          document_type: display_type_key,
          schema_name: SCHEMA_NAME,
        )
    end

  private

    attr_accessor :corporate_information_page
    attr_writer :update_type

    def_delegator :corporate_information_page, :display_type_key
  end
end
