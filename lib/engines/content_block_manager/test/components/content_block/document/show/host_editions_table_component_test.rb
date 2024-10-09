require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  let(:described_class) { ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponent }

  let(:host_content_items) do
    [
      ContentBlockManager::HostContentItem.new(
        "title" => "Some title",
        "base_path" => "/foo",
        "document_type" => "document_type",
        "publishing_app" => "publisher",
        "publishing_organisation" => {
          "content_id" => SecureRandom.uuid,
          "title" => "bar",
          "base_path" => "/bar",
        },
      ),
    ]
  end

  it "renders embedded editions" do
    caption = "Some caption"

    render_inline(
      described_class.new(
        caption:,
        host_content_items:,
      ),
    )

    assert_selector ".govuk-table__caption", text: caption

    assert_selector "tbody .govuk-table__row", count: 1

    assert_selector "tbody .govuk-table__cell", text: host_content_items[0].title
    assert_selector "tbody .govuk-table__cell", text: host_content_items[0].document_type.humanize
    assert_selector "tbody .govuk-table__cell", text: host_content_items[0].publishing_organisation["title"]
  end

  context "when the organisation does NOT exist within Whitehall" do
    it "does not link to the organisation" do
      render_inline(
        described_class.new(
          caption: anything,
          host_content_items:,
        ),
      )
      assert_no_selector "tbody .govuk-table__cell a", text: host_content_items[0].publishing_organisation["title"]
    end
  end

  context "when the organisation DOES exist within Whitehall" do
    it "links to the organisation instead of printing the name" do
      organisation = create(:organisation, content_id: host_content_items[0].publishing_organisation["content_id"], name: host_content_items[0].publishing_organisation["title"])

      expected_href = admin_organisation_path(organisation)

      render_inline(
        described_class.new(
          caption: anything,
          host_content_items:,
        ),
      )
      assert_selector "tbody .govuk-table__cell a",
                      text: host_content_items[0].publishing_organisation["title"]

      assert_link host_content_items[0].publishing_organisation["title"], href: expected_href
    end
  end

  context "when the organisation recieved does not have a title or base_path" do
    let(:host_content_items) do
      [
        ContentBlockManager::HostContentItem.new(
          title: "Some title",
          base_path: "/foo",
          document_type: "document_type",
          publishing_app: "publisher",
          publishing_organisation: {
            "content_id" => SecureRandom.uuid,
            "title" => nil,
            "base_path" => nil,
          },
        ),
      ]
    end

    it "presents 'Not set'" do
      caption = "Some caption"

      render_inline(
        described_class.new(
          caption:,
          host_content_items:,
        ),
      )

      assert_selector "tbody .govuk-table__cell", text: "Not set"
    end
  end
end
