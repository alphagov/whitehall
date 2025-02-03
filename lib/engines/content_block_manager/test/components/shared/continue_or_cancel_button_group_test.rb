require "test_helper"

class ContentBlockManager::Shared::ContinueOrCancelButtonGroupTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:form_id) { "my_form_id" }
  let(:content_block_edition) { build_stubbed(:content_block_edition, document: build_stubbed(:content_block_document)) }

  let(:component) do
    ContentBlockManager::Shared::ContinueOrCancelButtonGroup.new(form_id:, content_block_edition:)
  end

  describe "when an edition is for a brand new document" do
    before do
      content_block_edition.document.stubs(:editions).returns([content_block_edition])
    end

    it "renders with the correct form ID and URLs" do
      render_inline component

      assert_selector "button[form='my_form_id']", text: "Save and continue"
      assert_selector "form[action='#{content_block_manager_content_block_edition_path(
        content_block_edition,
        redirect_path: content_block_manager_content_block_documents_path,
      )}']"
    end

    describe "when custom button text is provided" do
      let(:button_text) { "My custom text" }
      let(:component) do
        ContentBlockManager::Shared::ContinueOrCancelButtonGroup.new(form_id:, content_block_edition:, button_text:)
      end

      it "renders with custom button text" do
        render_inline component

        assert_selector "button[form='my_form_id']", text: button_text
      end
    end
  end

  describe "when an edition is for an existing document" do
    before do
      content_block_edition.document.stubs(:editions).returns([*content_block_edition, build_stubbed_list(:content_block_edition, 2)])
    end

    it "renders with a link to the cancel page" do
      render_inline component

      assert_selector "button[form='my_form_id']", text: "Save and continue"
      assert_selector "a[href='#{cancel_content_block_manager_content_block_workflow_index_path(content_block_edition)}']"
    end
  end
end
