require "test_helper"

class ContentObjectStore::ContentBlockEditionHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  include Rails.application.routes.url_helpers
  include ContentObjectStore::ContentBlockEditionHelper

  describe "link_to_new_block_type" do
    test "it generates a link to create a new block type" do
      schema = ContentObjectStore::ContentBlockSchema.new("email_address", {})

      link = link_to_new_block_type(schema)
      expected = link_to schema.name, "/government/admin/content-object-store/content-block-editions/#{schema.parameter}/new"

      assert_equal link, expected
    end
  end
end
