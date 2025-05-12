require "test_helper"

class ContentBlockManager::ContentBlock::Schema::FieldTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:schema) { build(:content_block_schema) }

  it "returns the name when cast as a string" do
    field = ContentBlockManager::ContentBlock::Schema::Field.new("something", schema)

    assert_equal "something", field.to_s
  end
end
