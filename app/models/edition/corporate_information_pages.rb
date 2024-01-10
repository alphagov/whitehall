module Edition::CorporateInformationPages
  extend ActiveSupport::Concern

  included do
    delegate :corporate_information_pages, to: :document
  end

  def build_corporate_information_page(params)
    CorporateInformationPage.new(params.merge("owning_organisation_document" => document))
  end

  def unused_corporate_information_page_types
    CorporateInformationPageType.for(self) - corporate_information_pages.map(&:corporate_information_page_type)
  end
end