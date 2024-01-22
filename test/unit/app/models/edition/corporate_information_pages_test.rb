require "test_helper"

class Edition::CorporateInformationPagesTest < ActiveSupport::TestCase
  setup do
    @edition = create(:editionable_worldwide_organisation, :with_document)
    @corporate_information_page = create(:complaints_procedure_corporate_information_page, organisation: nil, worldwide_organisation: nil, owning_organisation_document: @edition.document)
  end

  test "#build_corporate_information_page assigns the edition document to the corporate information page" do
    cip = @edition.build_corporate_information_page({})

    assert_equal cip.owning_organisation_document, @edition.document
  end

  test "#unused_corporate_information_page_types returns the unused corporate information page type for the document" do
    assert_not_includes @edition.unused_corporate_information_page_types, @corporate_information_page
  end
end
