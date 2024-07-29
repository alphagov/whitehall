require "test_helper"

class ContentObjectStore::ContentBlock::EditionHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  include Rails.application.routes.url_helpers
  include ContentObjectStore::ContentBlock::EditionHelper

  describe "link_to_new_block_type" do
    test "it generates a link to create a new block type" do
      schema = build(:content_block_schema, :email_address, body: {})

      link = link_to_new_block_type(schema)
      expected = link_to schema.name, "/government/admin/content-object-store/content-block/editions/#{schema.parameter}/new"

      assert_equal link, expected
    end
  end
end
