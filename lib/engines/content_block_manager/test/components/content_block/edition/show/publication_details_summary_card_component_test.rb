require "test_helper"

class ContentBlockManager::ContentBlockEdition::Show::PublicationDetailsSummaryCardComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:content_block_edition) do
    create(
      :content_block_edition,
      :pension,
      scheduled_publication:,
    )
  end

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Show::PublicationDetailsSummaryCardComponent.new(
      content_block_edition:,
    )
  end

  describe "when the content block is scheduled" do
    let(:scheduled_publication) { 2.days.from_now }

    it "shows the scheduled date time" do
      content_block_edition.schedule!

      render_inline component

      assert_selector ".govuk-summary-card__title", text: "Publication details"

      assert_selector ".govuk-summary-card__action a[href='#{content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :schedule_publishing)}']"

      assert_selector ".govuk-summary-list__key", text: "Scheduled date and time"
      assert_selector ".govuk-summary-list__value", text: I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)
    end
  end

  describe "when the content block is being updated and published immediately" do
    let(:scheduled_publication) { nil }

    it "shows a publish now row" do
      render_inline component

      assert_selector ".govuk-summary-card__title", text: "Publication details"

      assert_selector ".govuk-summary-card__action a[href='#{content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :schedule_publishing)}']"

      assert_selector ".govuk-summary-list__key", text: "Publish date"
      assert_selector ".govuk-summary-list__value", text: I18n.l(Time.zone.today, format: :long_ordinal)
    end
  end
end
