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

  describe "when the content_block_edition already has a publish date set" do
    let(:params) do
      {
        "scheduled_at" => {
          "scheduled_publication(1i)" => "2022",
          "scheduled_publication(2i)" => "2",
          "scheduled_publication(3i)" => "3",
          "scheduled_publication(4i)" => "1",
          "scheduled_publication(5i)" => "2",
        },
      }
    end

    it "prepopulates the date fields" do
      render_inline(component)

      assert_selector "input[name='scheduled_at[scheduled_publication(1i)]'][value='#{params['scheduled_at']['scheduled_publication(1i)']}']"
      assert_selector "input[name='scheduled_at[scheduled_publication(2i)]'][value='#{params['scheduled_at']['scheduled_publication(2i)']}']"
      assert_selector "input[name='scheduled_at[scheduled_publication(3i)]'][value='#{params['scheduled_at']['scheduled_publication(3i)']}']"

      assert_selector "select[name='scheduled_at[scheduled_publication(4i)]'] option[value='0#{params['scheduled_at']['scheduled_publication(4i)']}'][selected='selected']"
      assert_selector "select[name='scheduled_at[scheduled_publication(5i)]'] option[value='0#{params['scheduled_at']['scheduled_publication(5i)']}'][selected='selected']"
    end
  end

  describe "when the params have date attributes set" do
    let(:scheduled_publication) { Time.zone.now + 1.month }
    let(:content_block_edition) { create(:content_block_edition, :email_address, document: content_block_document, scheduled_publication:) }

    it "prepopulates the date fields" do
      render_inline(component)

      assert_selector "input[name='scheduled_at[scheduled_publication(1i)]'][value='#{scheduled_publication.year}']"
      assert_selector "input[name='scheduled_at[scheduled_publication(2i)]'][value='#{scheduled_publication.month}']"
      assert_selector "input[name='scheduled_at[scheduled_publication(3i)]'][value='#{scheduled_publication.day}']"

      assert_selector "select[name='scheduled_at[scheduled_publication(4i)]'] option[value='#{scheduled_publication.hour}'][selected='selected']"
      assert_selector "select[name='scheduled_at[scheduled_publication(5i)]'] option[value='#{scheduled_publication.min}'][selected='selected']"
    end
  end
end
