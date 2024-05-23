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
    let(:draft_edition) { create(:edition, :draft, document: ) }
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

    it "marks published and draft editions as political" do
      capture_io { task.invoke(organisation.slug, date) }
      assert published_edition.reload.political
      assert draft_edition.reload.political
    end

  end
end
