require "test_helper"
require "rake"

class MarkDocumentsAsPoliticalFor < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown { task.reenable }

  describe "#mark_as_political" do
    let(:task) { Rake::Task["election:mark_documents_as_political_for"] }
    let(:organisation) { create(:organisation) }
    let(:document) { create(:document) }
    let(:published_edition) { create(:edition, :published, document:, first_published_at: "01-01-2023") }
    let(:draft_edition) { create(:edition, :draft, document:) }
    let(:date) { "31-12-2022" }

    setup do
      organisation.editions = [published_edition, draft_edition]
      organisation.save!
    end

    it "raises an error if organisation does not exist" do
      out, _err = capture_io { task.invoke("non-existent-slug", date) }
      assert_equal 'There is no Organisation with slug ["non-existent-slug"]', out.strip
    end

    it "raises an error if date is not right format" do
      out, _err = capture_io { task.invoke(organisation.slug, "not a date") }
      assert_equal 'The date is not on the right format ["not a date"]', out.strip
    end

    it "marks published editions of documents first published after the specified date and any associated drafts as political" do
      capture_io { task.invoke(organisation.slug, date) }
      assert published_edition.reload.political
      assert draft_edition.reload.political
    end

    it "does not mark editions unrelated to documents first published before the specified date as political" do
      non_political_document = create(:document)
      create(:edition, :published, document: non_political_document, first_published_at: "30-12-2022")
      create(:edition, :draft, document: non_political_document)
      capture_io { task.invoke(organisation.slug, date) }
      assert_not non_political_document.reload.live_edition.political
      assert_not non_political_document.reload.latest_edition.political
    end
  end
end
