require "test_helper"

class ContentBlockManager::HostContentItemsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:items) { build_list(:host_content_item, 5) }
  let(:total) { 12 }
  let(:total_pages) { 2 }
  let(:rollup) { build(:rollup) }
  let(:host_content_items) { build(:host_content_items, items:, total:, total_pages:, rollup:) }

  it "delegates array methods to items" do
    ([].methods - Object.methods).each do |method|
      assert host_content_items.respond_to?(method)
    end

    host_content_items.each_with_index do |item, i|
      assert_equal item, items[i]
    end
  end

  it "returns page count values" do
    assert_equal host_content_items.total, total
    assert_equal host_content_items.total_pages, total_pages
  end
end
