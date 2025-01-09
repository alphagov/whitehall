require "test_helper"

class ContentBlockManager::OrganisationValidatorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  test "it validates presence of a lead organisation" do
    content_block_edition = build(:content_block_edition, organisation: nil, document: build(:content_block_document, :email_address))

    assert_equal false, content_block_edition.valid?

    assert_equal [I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.blank", attribute: "Lead organisation")], content_block_edition.errors.full_messages
  end
end
