require "test_helper"

class ContentBlockManager::PreviewContentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:title) { "Ministry of Example" }
  let(:html) { "<p>Ministry of Example</p>" }
  let(:instances_count) { "2" }
  let(:preview_content) { build(:preview_content, title:, instances_count:, html:) }

  it "returns title, html and instances count" do
    assert_equal preview_content.title, title
    assert_equal preview_content.html, html
    assert_equal preview_content.instances_count, instances_count
  end
end
