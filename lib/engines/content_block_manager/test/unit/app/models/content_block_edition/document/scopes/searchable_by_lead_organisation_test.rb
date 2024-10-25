require "test_helper"

class ContentBlockManager::SearchableByLeadOrganisationTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe ".with_lead_organisation" do
    test "finds documents with lead organisation on latest edition" do
      matching_organisation = create(:organisation, id: "1234")
      document_with_org = create(:content_block_document, :email_address)
      _edition_with_org = create(:content_block_edition,
                                 :email_address,
                                 document: document_with_org,
                                 organisation: matching_organisation)
      document_without_org = create(:content_block_document, :email_address)
      _edition_without_org = create(:content_block_edition, :email_address, document: document_without_org)
      _document_without_latest_edition = create(:content_block_document, :email_address)
      assert_equal [document_with_org], ContentBlockManager::ContentBlock::Document.with_lead_organisation("1234")
    end
  end
end
