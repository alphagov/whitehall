require "test_helper"

class ContentBlockManager::Shared::CancelAndDeleteButtonComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:url) { "/url" }

  let(:cancel_and_delete_component) do
    ContentBlockManager::Shared::CancelAndDeleteButtonComponent.new(url:)
  end

  it "renders the delete form with given url" do
    render_inline(cancel_and_delete_component)

    assert_selector "form[action='#{url}']" do
      assert_selector "button[value='delete']", text: "Cancel"
    end
  end
end
