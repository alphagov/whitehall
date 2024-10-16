require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::DateHelper

  let(:described_class) { ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponent }
  let(:user) { create(:user) }
  let(:caption) { "Some caption" }
  let(:publishing_organisation) do
    {
      "content_id" => SecureRandom.uuid,
      "title" => "bar",
      "base_path" => "/bar",
    }
  end
  let(:last_edited_by_editor_id) { user.uid }

  let(:host_content_item) do
    ContentBlockManager::HostContentItem.new(
      "title" => "Some title",
      "base_path" => "/foo",
      "document_type" => "document_type",
      "publishing_app" => "publisher",
      "last_edited_by_editor_id" => last_edited_by_editor_id,
      "last_edited_at" => Time.zone.now.to_s,
      "publishing_organisation" => publishing_organisation,
    )
  end
  let(:host_content_items) { [host_content_item] }

  def self.it_returns_unknown_user
    it "returns Unknown user" do
      render_inline(
        described_class.new(
          caption:,
          host_content_items:,
        ),
      )

      assert_selector "tbody .govuk-table__cell", text: "#{time_ago_in_words(host_content_item.last_edited_at)} ago by Unknown user"
    end
  end

  describe "table component" do
    it "renders embedded editions" do
      render_inline(
        described_class.new(
          caption:,
          host_content_items:,
        ),
      )

      assert_selector ".govuk-table__caption", text: caption

      assert_selector "tbody .govuk-table__row", count: 1

      assert_selector "tbody .govuk-table__cell", text: host_content_item.title
      assert_selector "tbody .govuk-table__cell", text: host_content_item.document_type.humanize
      assert_selector "tbody .govuk-table__cell", text: host_content_item.publishing_organisation["title"]
      assert_selector "tbody .govuk-table__cell", text: "#{time_ago_in_words(host_content_item.last_edited_at)} ago by #{user.name}"
      assert_link user.name, { href: "mailto:#{user.email}" }
    end

    context "when the organisation does NOT exist within Whitehall" do
      it "does not link to the organisation" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
          ),
        )
        assert_no_selector "tbody .govuk-table__cell a", text: host_content_item.publishing_organisation["title"]
      end
    end

    context "when the organisation DOES exist within Whitehall" do
      it "links to the organisation instead of printing the name" do
        organisation = create(:organisation, content_id: host_content_item.publishing_organisation["content_id"], name: host_content_item.publishing_organisation["title"])

        expected_href = admin_organisation_path(organisation)

        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
          ),
        )
        assert_selector "tbody .govuk-table__cell a",
                        text: host_content_item.publishing_organisation["title"]

        assert_link host_content_item.publishing_organisation["title"], href: expected_href
      end
    end

    context "when the organisation received does not have a title or base_path" do
      let(:publishing_organisation) do
        {
          "content_id" => SecureRandom.uuid,
          "title" => nil,
          "base_path" => nil,
        }
      end

      it "presents 'Not set'" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
          ),
        )

        assert_selector "tbody .govuk-table__cell", text: "Not set"
      end
    end

    context "when last_edited_by_editor_id is nil" do
      let(:last_edited_by_editor_id) { nil }

      it_returns_unknown_user

      context "and a user exists with a nil uuid" do
        before do
          create(:user, uid: nil)
        end

        it_returns_unknown_user
      end
    end

    context "when last_edited_by_editor_id refers to a user id which is not present in Whitehall" do
      let(:last_edited_by_editor_id) { SecureRandom.uuid }

      it_returns_unknown_user
    end
  end
end
