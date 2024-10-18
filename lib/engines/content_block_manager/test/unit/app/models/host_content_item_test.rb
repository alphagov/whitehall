require "test_helper"

class ContentBlockManager::SchemaTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "#last_edited_at" do
    it "translates to a TimeWithZone object" do
      last_edited_at = 4.days.ago
      host_content_item = build(:host_content_item, last_edited_at: last_edited_at.to_s)

      assert host_content_item.last_edited_at.is_a?(ActiveSupport::TimeWithZone)
      assert_equal host_content_item.last_edited_at, last_edited_at
    end
  end
end
