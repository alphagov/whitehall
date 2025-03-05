require "test_helper"
require "rake"

class IdentifyPoliticalContentFor < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#identify_political_content" do
    let(:task) { Rake::Task["election:identify_political_content_for"] }
    let(:organisation) { create(:organisation, political: true) }
    let(:date) { "31-12-2022" }

    it "raises an error if organisation does not exist" do
      out, _err = capture_io { task.invoke("non-existent-slug", date) }
      assert_includes out, 'There is no Organisation with slug ["non-existent-slug"]'
    end

    it "raises an error if date is not right format" do
      out, _err = capture_io { task.invoke(organisation.slug, "not a date") }
      assert_includes out, 'The date is not on the right format ["not a date"]'
    end

    it "marks eligible published editions of documents first published after the specified date and any associated drafts as political" do
      document = create(:document)
      published_edition = create(:news_article, :published, document:, first_published_at: "01-01-2023")
      draft_edition = create(:news_article, :draft, document:)
      organisation.editions = [published_edition, draft_edition]
      organisation.save!

      capture_io { task.invoke(organisation.slug, date) }
      assert published_edition.reload.political
      assert draft_edition.reload.political
    end

    it "does not mark editions unrelated to documents first published before the specified date as political" do
      non_political_document = create(:document)
      published_edition = create(:news_article, :published, document: non_political_document, political: false, first_published_at: "30-12-2022")
      draft_edition = create(:news_article, :draft, document: non_political_document, political: false)
      organisation.editions = [published_edition, draft_edition]
      organisation.save!

      capture_io { task.invoke(organisation.slug, date) }
      assert_not non_political_document.reload.live_edition.political
      assert_not non_political_document.reload.latest_edition.political
    end

    it "does not mark editions that are ineligible as political content as political" do
      fatality_notice = create(:fatality_notice, :published)
      organisation.editions = [fatality_notice]
      organisation.save!

      capture_io { task.invoke(organisation.slug, date) }
      assert_not fatality_notice.reload.political
    end
  end
end
