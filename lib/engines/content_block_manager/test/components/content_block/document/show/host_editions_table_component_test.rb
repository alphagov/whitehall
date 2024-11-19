require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers
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
  let(:unique_pageviews) { 1_200_000 }

  let(:host_content_item) do
    ContentBlockManager::HostContentItem.new(
      "title" => "Some title",
      "base_path" => "/foo",
      "document_type" => "document_type",
      "publishing_app" => "publisher",
      "last_edited_by_editor_id" => last_edited_by_editor_id,
      "last_edited_at" => Time.zone.now.to_s,
      "publishing_organisation" => publishing_organisation,
      "unique_pageviews" => unique_pageviews,
      "host_content_id" => SecureRandom.uuid,
      "instances" => 1,
    )
  end
  let(:host_content_items) do
    build(
      :host_content_items,
      items: [host_content_item],
      total: 20,
      total_pages: 2,
    )
  end

  let(:content_block_edition) do
    build(:content_block_edition, :email_address, id: SecureRandom.uuid)
  end

  def self.it_returns_unknown_user
    it "returns Unknown user" do
      render_inline(
        described_class.new(
          caption:,
          host_content_items:,
          content_block_edition:,
        ),
      )

      assert_selector "tbody .govuk-table__cell", text: "#{time_ago_in_words(host_content_item.last_edited_at)} ago by Unknown user"
    end
  end

  around do |test|
    with_request_url content_block_manager_root_path do
      test.call
    end
  end

  describe "table component" do
    it "renders embedded editions" do
      render_inline(
        described_class.new(
          caption:,
          host_content_items:,
          content_block_edition:,
        ),
      )

      assert_selector ".govuk-table__caption", text: caption

      assert_selector "tbody .govuk-table__row", count: 1

      assert_selector ".govuk-link" do |link|
        assert_equal "#{host_content_item.title} (opens in new tab)", link.text
        assert_equal Plek.website_root + host_content_item.base_path, link[:href]
        assert_equal "noopener", link[:rel]
        assert_equal "_blank", link[:target]
      end
      assert_selector "tbody .govuk-table__cell", text: host_content_item.document_type.humanize
      assert_selector "tbody .govuk-table__cell", text: "1.2m"
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
            content_block_edition:,
          ),
        )
        assert_no_selector "tbody .govuk-table__cell a", text: host_content_item.publishing_organisation["title"]
      end
    end

    context "when the organisation DOES exist within Whitehall" do
      it "links to the organisation instead of printing the name" do
        organisation = create(:organisation, content_id: host_content_item.publishing_organisation["content_id"], name: host_content_item.publishing_organisation["title"])

        expected_href = Rails.application.routes.url_helpers.admin_organisation_path(organisation)

        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
            content_block_edition:,
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
            content_block_edition:,
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

    context "when unique pageviews can't be found" do
      let(:unique_pageviews) { nil }

      it "displays not found" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
            content_block_edition:,
          ),
        )

        assert_selector "tbody .govuk-table__cell", text: "Not set"
      end
    end

    context "when previewing" do
      it "returns the draft content store link" do
        render_inline(
          described_class.new(
            is_preview: true,
            caption:,
            host_content_items:,
            content_block_edition:,
          ),
        )

        assert_selector "a[href='#{content_block_manager_content_block_host_content_preview_path(id: content_block_edition.id, host_content_id: host_content_item.host_content_id)}']", text: host_content_item.title
      end
    end

    describe "sorting headers" do
      it "adds the table header as an anchor tag to each header" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
            content_block_edition:,
          ),
        )

        assert_selector "a.app-table__sort-link[href*='##{ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponent::TABLE_ID}']", count: 6
      end

      it "shows all the headers unordered by default" do
        render_inline(
          described_class.new(
            caption:,
            host_content_items:,
            content_block_edition:,
          ),
        )

        assert_selector "a.app-table__sort-link[href*='order=title']", text: "Title"
        assert_selector "a.app-table__sort-link[href*='order=document_type']", text: "Document Type"
        assert_selector "a.app-table__sort-link[href*='order=instances']", text: "Instances"
        assert_selector "a.app-table__sort-link[href*='order=unique_pageviews']", text: "Unique pageviews"
        assert_selector "a.app-table__sort-link[href*='order=primary_publishing_organisation_title']", text: "Publishing organisation"
        assert_selector "a.app-table__sort-link[href*='order=last_edited_at']", text: "Updated"

        assert_selector ".govuk-table__header--active a", text: "Unique pageviews"
      end

      %w[title document_type unique_pageviews primary_publishing_organisation_title last_edited_at instances].each do |order|
        it "shows the link as selected when #{order} is in ascending order" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              order:,
              content_block_edition:,
            ),
          )

          assert_selector ".govuk-table__header--active a.app-table__sort-link.app-table__sort-link--ascending[href*='order=-#{order}']"
        end

        it "shows the link as selected when #{order} is in descending order" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              order: "-#{order}",
              content_block_edition:,
            ),
          )

          assert_selector ".govuk-table__header--active a.app-table__sort-link.app-table__sort-link--descending[href*='order=#{order}']"
        end
      end
    end

    describe "pagination" do
      context "when there is only one page" do
        let(:host_content_items) do
          build(
            :host_content_items,
            items: [host_content_item],
            total: 1,
            total_pages: 1,
          )
        end

        it "does not show pagination" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              content_block_edition:,
            ),
          )

          assert_no_selector ".govuk-pagination__list"
        end
      end

      context "when there is more than one page" do
        let(:host_content_items) do
          build(
            :host_content_items,
            items: [host_content_item],
            total: 20,
            total_pages: 2,
          )
        end

        it "adds the table header as an anchor tag to each pagination link" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              content_block_edition:,
            ),
          )

          assert_selector "ul.govuk-pagination__list a.govuk-pagination__link[href*='##{ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponent::TABLE_ID}']", count: 2
          assert_selector ".govuk-pagination__next a.govuk-pagination__link[href*='##{ContentBlockManager::ContentBlock::Document::Show::HostEditionsTableComponent::TABLE_ID}']"
        end

        it "shows the first page as selected by default" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              content_block_edition:,
            ),
          )

          assert_selector ".govuk-pagination__list"
          assert_selector "a.govuk-pagination__link[aria-current='page']", text: "1"
        end

        it "shows the currently selected page" do
          render_inline(
            described_class.new(
              caption:,
              host_content_items:,
              current_page: 2,
              content_block_edition:,
            ),
          )

          assert_selector "a.govuk-pagination__link[aria-current='page']", text: "2"
        end
      end
    end
  end
end
