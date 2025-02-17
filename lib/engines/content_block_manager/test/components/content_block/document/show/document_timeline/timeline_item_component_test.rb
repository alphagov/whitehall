require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::TimelineItemComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper
  extend Minitest::Spec::DSL

  let(:user) { create(:user) }
  let(:schema) { build(:content_block_schema) }

  let(:content_block_edition) { build(:content_block_edition, :email_address, change_note: nil, internal_change_note: nil) }
  let(:version) do
    build(
      :content_block_version,
      event: "created",
      whodunnit: user.id,
      state: "published",
      created_at: 4.days.ago,
      item: content_block_edition,
    )
  end

  let(:is_latest) { false }
  let(:is_first_published_version) { false }

  let(:table_stub) { stub("table_component") }

  let(:component) do
    ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::TimelineItemComponent.new(
      version:,
      schema:,
      is_first_published_version:,
      is_latest:,
    )
  end

  describe "when not the latest or first published" do
    before do
      render_inline component
    end

    it "renders a timeline item component" do
      assert_selector ".timeline__title", text: "Published"
      page.find ".timeline__byline" do |byline|
        assert_includes byline.native.to_s, "by #{linked_author(user, { class: 'govuk-link' })}"
      end
      assert_selector "time[datetime='#{version.created_at.iso8601}']", text: version.created_at.to_fs(:long_ordinal_with_at)
    end

    it "does not show the latest tag" do
      refute_selector ".timeline__latest", text: "Latest"
    end

    it "does not show the table component" do
      refute_selector ".timeline__diff-table"
    end
  end

  describe "when the version is the first published version" do
    let(:is_latest) { false }
    let(:is_first_published_version) { true }

    before do
      render_inline component
    end

    it "returns a created title" do
      assert_selector ".timeline__title", text: "Email address created"
    end
  end

  describe "when the version is the latest version" do
    let(:is_latest) { true }
    let(:is_first_published_version) { false }

    before do
      render_inline component
    end

    it "shows the latest tag" do
      assert_selector ".timeline__latest", text: "Latest"
    end
  end

  describe "when external changenotes are present" do
    let(:content_block_edition) { build(:content_block_edition, :email_address, change_note: "changed a to b", internal_change_note: nil) }

    before do
      render_inline component
    end

    it "shows the change note" do
      assert_selector ".timeline__note--public p", text: "changed a to b"
    end
  end

  describe "when internal changenotes are present" do
    let(:content_block_edition) { build(:content_block_edition, :email_address, change_note: nil, internal_change_note: "changed x to y") }

    before do
      render_inline component
    end

    it "shows the change note" do
      assert_selector ".timeline__note--internal p", text: "changed x to y"
    end
  end

  describe "when field diffs are present" do
    let(:field_diffs) { [{ "something" => "here" }] }
    let(:version) do
      build(
        :content_block_version,
        event: "created",
        whodunnit: user.id,
        state: "published",
        created_at: 4.days.ago,
        item: content_block_edition,
        field_diffs:,
      )
    end

    it "renders the table component" do
      table_component = ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponent.new(
        version: build(:content_block_version, field_diffs: []),
        schema:,
      )

      ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponent
        .expects(:new)
        .with(version:, schema:)
        .returns(table_component)

      component
        .expects(:render)
        .with("govuk_publishing_components/components/details", { title: "Details of changes", open: false })
        .with_block_given
        .yields

      component
        .expects(:render)
        .with(table_component)
        .once

      render_inline component
    end

    describe "when the version is the latest version" do
      let(:is_latest) { true }

      it "renders the details as open" do
        component
          .expects(:render)
          .with("govuk_publishing_components/components/details", { title: "Details of changes", open: true })

        render_inline component
      end
    end
  end
end
