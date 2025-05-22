require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::TimelineItemComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper
  extend Minitest::Spec::DSL

  let(:user) { create(:user) }
  let(:schema) { stub(:schema, subschemas: []) }

  let(:content_block_edition) { build(:content_block_edition, :pension, change_note: nil, internal_change_note: nil) }
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
      assert_selector ".timeline__title", text: "Pension created"
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
    let(:content_block_edition) { build(:content_block_edition, :pension, change_note: "changed a to b", internal_change_note: nil) }

    before do
      render_inline component
    end

    it "shows the change note" do
      assert_selector ".timeline__note--public p", text: "changed a to b"
    end
  end

  describe "when internal changenotes are present" do
    let(:content_block_edition) { build(:content_block_edition, :pension, change_note: nil, internal_change_note: "changed x to y") }

    before do
      render_inline component
    end

    it "shows the change note" do
      assert_selector ".timeline__note--internal p", text: "changed x to y"
    end
  end

  describe "when field diffs are present" do
    let(:field_diffs) { { "foo" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "previous value", new_value: "new value") } }
    let(:version) do
      build_stubbed(
        :content_block_version,
        event: "created",
        whodunnit: user.id,
        state: "published",
        created_at: 4.days.ago,
        item: content_block_edition,
        field_diffs:,
      )
    end

    let!(:table_component) do
      ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponent.new(
        version:,
        schema:,
      )
    end

    before do
      ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponent
        .expects(:new)
        .with(version:, schema:)
        .returns(table_component)

      component
        .expects(:render)
        .with(table_component)
        .once
        .returns("TABLE COMPONENT")
    end

    it "renders the table component unopened" do
      component
        .expects(:render)
        .with("govuk_publishing_components/components/details", { title: "Details of changes", open: false })
        .with_block_given
        .yields

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

  describe "when there are embedded objects" do
    let(:subschema1) { stub(:subschema, id: "embedded_schema") }
    let(:subschema2) { stub(:subschema, id: "other_embedded_schema") }
    let(:schema) { stub(:schema, subschemas: [subschema1, subschema2]) }

    describe "when there are field diffs" do
      let(:field_diffs) do
        {
          "details" => {
            "embedded_schema" => {
              "something" => {
                "field1" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "before", new_value: "after"),
                "field2" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "before", new_value: "after"),
              },
            },
          },
        }
      end

      let(:version) do
        build_stubbed(
          :content_block_version,
          event: "created",
          whodunnit: user.id,
          state: "published",
          created_at: 4.days.ago,
          item: content_block_edition,
          field_diffs:,
        )
      end

      it "renders the embedded table component" do
        table_component = stub("table_component")

        ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::EmbeddedObject::FieldChangesTableComponent
          .expects(:new)
          .with(
            object_id: "something",
            field_diff: {
              "field1" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "before", new_value: "after"),
              "field2" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "before", new_value: "after"),
            },
            subschema_id: "embedded_schema",
            content_block_edition:,
          )
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
          .returns("TABLE COMPONENT 1")

        component
          .expects(:render)
          .with(anything)
          .once
          .returns("TABLE COMPONENT 2")

        render_inline component
      end
    end

    describe "when there are no field diffs for the embedded object" do
      let(:field_diffs) { { "foo" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: "previous value", new_value: "new value") } }

      let(:version) do
        build_stubbed(
          :content_block_version,
          event: "created",
          whodunnit: user.id,
          state: "published",
          created_at: 4.days.ago,
          item: content_block_edition,
          field_diffs:,
        )
      end

      let!(:table_component) do
        ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponent.new(
          version:,
          schema:,
        )
      end

      it "renders the table component" do
        ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::FieldChangesTableComponent
          .expects(:new)
          .with(version:, schema:)
          .returns(table_component)

        component
          .expects(:render)
          .with(table_component)
          .once
          .returns("TABLE COMPONENT")

        component
          .expects(:render)
          .with("govuk_publishing_components/components/details", { title: "Details of changes", open: false })
          .with_block_given
          .yields

        render_inline component
      end
    end
  end

  describe "when the version is an embedded update" do
    let(:subschema) { stub(:subschema, id: "embedded_schema", name: "Embedded schema") }
    let(:schema) { stub(:schema, subschemas: [subschema]) }

    let(:field_diffs) do
      {
        "details" => {
          "embedded_schema" => {
            "something" => {
              "field1" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: nil, new_value: "Field 1 value"),
              "field2" => ContentBlockManager::ContentBlock::DiffItem.new(previous_value: nil, new_value: "Field 2 value"),
            },
          },
        },
      }
    end

    let(:version) do
      build_stubbed(
        :content_block_version,
        event: "created",
        whodunnit: user.id,
        state: "published",
        created_at: 4.days.ago,
        item: content_block_edition,
        field_diffs:,
        updated_embedded_object_type: "embedded_schema",
        updated_embedded_object_title: "something",
      )
    end

    before do
      schema.stubs(:subschema).with("embedded_schema").returns(subschema)
    end

    it "renders the correct title" do
      render_inline component

      assert_selector ".timeline__title", text: "Embedded schema added"
    end

    it "renders the details of the updated object" do
      render_inline component

      assert_selector ".timeline__embedded-item-list__item", count: 1
      assert_no_selector "summary"
      assert_selector ".timeline__embedded-item-list .timeline__embedded-item-list__item:nth-child(1) .timeline__embedded-item-list__key", text: "Field1:"
      assert_selector ".timeline__embedded-item-list .timeline__embedded-item-list__item:nth-child(1) .timeline__embedded-item-list__value", text: "Field 1 value"
    end
  end
end
