require "test_helper"

class ContentBlockManager::ValidatesDetailsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "schema" do
    it "returns a schema" do
      content_block_edition = build(:content_block_edition, schema: nil)
      schema = build(:content_block_schema)

      content_block_schema_mock = Minitest::Mock.new
      content_block_schema_mock.expect :call, schema, [content_block_edition.block_type]

      ContentBlockManager::ContentBlock::Schema.stub :find_by_block_type, content_block_schema_mock do
        assert_equal content_block_edition.schema, schema
      end

      content_block_schema_mock.verify
    end
  end

  describe "read_attribute_for_validation" do
    it "reads from the details hash if prefixed with `details_`" do
      content_block_edition = build(:content_block_edition, details: { "foo" => "bar" })

      assert_equal content_block_edition.read_attribute_for_validation(:details_foo), "bar"
    end

    it "reads the attribute directly if not prefixed with `details_`" do
      content_block_edition = build(:content_block_edition)

      assert_equal content_block_edition.read_attribute_for_validation(:created_at), content_block_edition.created_at
    end
  end

  describe "human_attribute_name" do
    it "returns the human readable label for a field prefixed with `details_`" do
      assert_equal ContentBlockManager::ContentBlock::Edition.human_attribute_name("details_foo"), "Foo"
    end
  end
end
