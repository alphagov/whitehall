require "test_helper"

class ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  it "it renders instructions to publishers" do
    content_block_edition = create(
      :content_block_edition,
      :email_address,
      instructions_to_publishers: "some instructions",
    )

    render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                    content_block_edition:,
                  ))

    assert_selector ".govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__value", text: "some instructions"
  end

  it "renders a summary list component with the edition details to confirm" do
    organisation = create(:organisation, name: "Department for Example")

    content_block_document = create(:content_block_document, :email_address)
    content_block_document.stubs(:is_new_block?).returns(false)

    content_block_edition = create(
      :content_block_edition,
      :email_address,
      title: "Some edition title",
      details: { "interesting_fact" => "value of fact" },
      organisation:,
      document: content_block_document,
      internal_change_note: "Some internal info",
    )

    render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                    content_block_edition:,
                  ))

    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__key", text: "Email address details"
    assert_selector ".govuk-summary-list__row:nth-child(1) .govuk-summary-list__actions", text: "Edit"

    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__key", text: "Title"
    assert_selector ".govuk-summary-list__row:nth-child(2) .govuk-summary-list__value", text: "Some edition title"

    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__key", text: "New interesting fact"
    assert_selector ".govuk-summary-list__row:nth-child(3) .govuk-summary-list__value", text: "value of fact"

    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__key", text: "Lead organisation"
    assert_selector ".govuk-summary-list__row:nth-child(4) .govuk-summary-list__value", text: "Department for Example"

    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__key", text: "Instructions to publishers"
    assert_selector ".govuk-summary-list__row:nth-child(5) .govuk-summary-list__value", text: "None"

    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Internal note"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: "Some internal info"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions", text: "Edit"
    assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions a[href='#{content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :internal_note)}']"
  end

  describe "when creating a new content block" do
    let(:document) { create(:content_block_document, :email_address) }

    before do
      document.stubs(:is_new_block?).returns(true)
    end

    it "does not show change note information" do
      content_block_edition = create(
        :content_block_edition,
        :email_address,
        instructions_to_publishers: "some instructions",
        document:,
      )

      render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                      content_block_edition:,
                    ))

      assert_no_text "Internal note"
      assert_no_text "Do users have to know the content has changed?"
      assert_no_text "Public change note"
    end
  end

  describe "when editing an existing content block" do
    let(:document) { create(:content_block_document, :email_address) }

    before do
      document.stubs(:is_new_block?).returns(false)
    end

    describe "when the change is major" do
      it "shows the public change note" do
        content_block_edition = create(
          :content_block_edition,
          :email_address,
          instructions_to_publishers: "some instructions",
          major_change: true,
          change_note: "Some change note",
          document:,
        )

        render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                        content_block_edition:,
                      ))

        assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Do users have to know the content has changed?"
        assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: "Yes"
        assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions", text: "Edit"
        assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions a[href='#{content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :change_note)}']"

        assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__key", text: "Public change note"
        assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__value", text: "Some change note"
        assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__actions", text: "Edit"
        assert_selector ".govuk-summary-list__row:nth-child(7) .govuk-summary-list__actions a[href='#{content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :change_note)}']"
      end
    end

    describe "when the change is not major" do
      it "shows the public change note" do
        content_block_edition = create(
          :content_block_edition,
          :email_address,
          instructions_to_publishers: "some instructions",
          major_change: false,
          change_note: "Some change note",
          document:,
        )

        render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                        content_block_edition:,
                      ))

        assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__key", text: "Do users have to know the content has changed?"
        assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__value", text: "No"
        assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions", text: "Edit"
        assert_selector ".govuk-summary-list__row:nth-child(6) .govuk-summary-list__actions a[href='#{content_block_manager_content_block_workflow_path(id: content_block_edition.id, step: :change_note)}']"

        refute_selector ".govuk-summary-list__key", text: "Public change note"
        refute_selector ".govuk-summary-list__value", text: "Some change note"
      end
    end
  end

  describe "when the content block is scheduled" do
    it "shows the scheduled date time" do
      organisation = create(:organisation, name: "Department for Example")

      content_block_document = create(:content_block_document, :email_address)

      content_block_edition = create(
        :content_block_edition,
        :email_address,
        details: { "interesting_fact" => "value of fact" },
        organisation:,
        document: content_block_document,
        scheduled_publication: 2.days.from_now,
      )

      content_block_edition.schedule!

      render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                      content_block_edition:,
                    ))

      assert_selector ".govuk-summary-list__key", text: "Scheduled date and time"
      assert_selector ".govuk-summary-list__value", text: I18n.l(content_block_edition.scheduled_publication, format: :long_ordinal)
    end
  end

  describe "when the content block is being updated and published immediately" do
    it "shows a publish now row" do
      organisation = create(:organisation, name: "Department for Example")

      content_block_document = create(:content_block_document, :email_address)

      _previous_edition = create(
        :content_block_edition,
        :email_address,
        organisation:,
        document: content_block_document,
      )

      content_block_edition = create(
        :content_block_edition,
        :email_address,
        details: { "interesting_fact" => "value of fact" },
        organisation:,
        document: content_block_document,
      )

      render_inline(ContentBlockManager::ContentBlockEdition::Show::ConfirmSummaryListComponent.new(
                      content_block_edition:,
                    ))

      assert_selector ".govuk-summary-list__key", text: "Publish date"
      assert_selector ".govuk-summary-list__value", text: I18n.l(Time.zone.today, format: :long_ordinal)
    end
  end
end
