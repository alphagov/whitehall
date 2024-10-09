require "test_helper"

class ContentBlockManager::OrganisationValidatorTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  test "it validates presence of a lead organisation" do
    content_block_edition = build(:content_block_edition, organisation: nil)

    assert_equal false, content_block_edition.valid?
    assert_equal ["cannot be blank"], content_block_edition.errors.messages[:lead_organisation]
  end
end
