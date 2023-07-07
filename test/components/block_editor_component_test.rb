require "test_helper"

class BlockEditorComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  it "renders an editorjs div" do
    edition = build(:edition)
    render_inline(BlockEditorComponent.new(edition:))
    assert_selector "div#editorjs", count: 1
  end

  describe "#editor_config" do
    it "passes the Edition body to the Editor as rendered HTML" do
      edition = build(:edition, body: "## My edition body")
      component = BlockEditorComponent.new(edition:)
      render_inline(component)
      assert_equal '<h2 id="my-edition-body">My edition body</h2>', component.editor_config[:html].strip
    end
  end
end
