require "test_helper"

class ContentObjectStore::ValidatesDetailsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "schema" do
    it "returns a schema" do
      content_block_edition = build(:content_block_edition, schema: nil)
      schema = build(:content_block_schema)

      content_block_schema_mock = Minitest::Mock.new
      content_block_schema_mock.expect :call, schema, [content_block_edition.block_type]

      ContentObjectStore::ContentBlockSchema.stub :find_by_block_type, content_block_schema_mock do
        assert_equal content_block_edition.schema, schema
      end

      content_block_schema_mock.verify
    end
  end
end
