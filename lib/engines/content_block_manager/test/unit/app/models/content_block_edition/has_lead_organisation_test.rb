require "test_helper"

class ContentBlockManager::HasLeadOrganisationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    @organisation = create(:organisation)
    @edition = create(
      :content_block_edition,
      organisation: @organisation,
      document: create(:content_block_document, :email_address),
    )
  end

  it "creates an edition_organisation for a new edition" do
    edition_organisation = @edition.edition_organisation

    assert_equal @organisation.id, edition_organisation.organisation_id
  end

  it "returns the lead organisation from the edition_organisation" do
    assert_equal @organisation, @edition.lead_organisation
  end
end
