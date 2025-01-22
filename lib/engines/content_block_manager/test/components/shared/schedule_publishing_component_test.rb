require "test_helper"

class ContentBlockManager::Shared::SchedulePublishingComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:content_block_document) { create(:content_block_document, :email_address) }
  let(:content_block_edition) { create(:content_block_edition, :email_address, document: content_block_document) }
  let(:params) { {} }
  let(:context) { "Some context" }
  let(:back_link) { "/back-link" }
  let(:form_url) { "/form-url" }

  let(:rescheduling_component) do
    ContentBlockManager::Shared::SchedulePublishingComponent.new(
      content_block_edition:,
      params:,
      context:,
      back_link:,
      form_url:,
      is_rescheduling: true,
    )
  end

  let(:component) do
    ContentBlockManager::Shared::SchedulePublishingComponent.new(
      content_block_edition:,
      params:,
      context:,
      back_link:,
      form_url:,
      is_rescheduling: false,
    )
  end

  describe "when edition is being rescheduled" do
    it "renders the cancel button with back link" do
      render_inline(rescheduling_component)

      assert_selector "a[href='#{back_link}']", text: "Cancel"
    end
  end

  describe "when edition is not being rescheduled" do
    it "renders the cancel button with delete form" do
      render_inline(component)

      assert_selector ".govuk-button", text: "Cancel"
      assert_selector "form[action='#{content_block_manager_content_block_edition_path(
        content_block_edition,
        redirect_path: content_block_manager_content_block_document_path(content_block_edition.document),
      )}']"
    end
  end
end
