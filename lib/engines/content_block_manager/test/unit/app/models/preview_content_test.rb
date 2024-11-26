require "test_helper"

class ContentBlockManager::PreviewContentTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:title) { "Ministry of Example" }
  let(:html) { "<p>Ministry of Example</p>" }
  let(:preview_content) { build(:preview_content, title:, html:) }

  it "returns title and html" do
    assert_equal preview_content.title, title
    assert_equal preview_content.html, html
  end
end
