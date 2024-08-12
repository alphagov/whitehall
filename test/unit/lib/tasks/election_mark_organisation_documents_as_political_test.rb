require "test_helper"
require "rake"

class IdentifyPoliticalContentFor < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#identify_political_content" do
    let(:task) { Rake::Task["election:identify_political_content_for"] }
    let(:organisation) { create(:organisation, political: true) }
    let(:date) { 6.weeks.ago.to_s }

    it "raises an error if organisation does not exist" do
      out, _err = capture_io { task.invoke("non-existent-slug", date) }
      assert_equal 'There is no Organisation with slug ["non-existent-slug"]', out.strip
    end

    it "raises an error if date is not right format" do
      out, _err = capture_io { task.invoke(organisation.slug, "not a date") }
      assert_equal 'The date is not on the right format ["not a date"]', out.strip
    end

    it "marks eligible published editions of documents first published after the specified date and any associated drafts as political" do
      create(:government, start_date: 4.weeks.ago, end_date: 2.weeks.ago)
      document = create(:document)
      published_edition = create(:news_article, :published, document:, first_published_at: 3.weeks.ago)
      draft_edition = create(:news_article, :draft, document:, first_published_at: 3.weeks.ago)
      organisation.editions = [published_edition, draft_edition]
      organisation.save!

      capture_io { task.invoke(organisation.slug, date) }
      assert published_edition.reload.political?
      assert draft_edition.reload.political?
    end

    it "does not mark editions unrelated to documents first published before the specified date as political" do
      non_political_document = create(:document)
      published_edition = create(:news_article, :published, document: non_political_document, first_published_at: 8.weeks.ago)
      draft_edition = create(:news_article, :draft, document: non_political_document, first_published_at: 8.weeks.ago)
      organisation.editions = [published_edition, draft_edition]
      organisation.save!

      capture_io { task.invoke(organisation.slug, date) }
      assert_not non_political_document.reload.live_edition.political?
      assert_not non_political_document.reload.latest_edition.political?
    end

    it "does not mark editions that are ineligible as political content as political" do
      fatality_notice = create(:fatality_notice, :published)
      organisation.editions = [fatality_notice]
      organisation.save!

      capture_io { task.invoke(organisation.slug, date) }
      assert_not fatality_notice.reload.political?
    end
  end
end
