require "test_helper"
require "rake"

class IdentifyPoliticalContentFor < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  setup do
    Thor::Shell::Basic.any_instance.stubs(:yes?).returns(true)
  end

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
      published_document = create(:document)
      published_edition = create(:publication, :published, document: published_document, first_published_at: "01-01-2023")
      draft_of_published_edition = create(:publication, :draft, document: published_document)
      withdrawn_document = create(:document)
      withdrawn_edition = create(:publication, :withdrawn, document: withdrawn_document, first_published_at: "01-01-2023")
      draft_of_withdrawn_edition = create(:publication, :draft, document: withdrawn_document)
      unpublished_document = create(:document)
      unpublished_edition = create(:publication, :unpublished, document: unpublished_document, first_published_at: "01-01-2023")
      draft_of_unpublished_edition = create(:publication, :draft, document: unpublished_document)
      organisation.editions = [published_edition, draft_of_published_edition, withdrawn_edition, draft_of_withdrawn_edition, unpublished_edition, draft_of_unpublished_edition]
      organisation.save!

      # All editions are "potentially" political by virtue of their type
      assert([published_edition, withdrawn_edition, unpublished_edition].pluck(:publication_type).each { |type| PoliticalContentIdentifier::POLITICAL_PUBLICATION_TYPES.include?(type) })

      capture_io { task.invoke(organisation.slug, date) }

      assert published_edition.reload.political
      assert draft_of_published_edition.reload.political
      # These states are not included
      assert_not withdrawn_edition.reload.political
      assert_not draft_of_withdrawn_edition.reload.political
      assert_not unpublished_edition.reload.political
      assert_not draft_of_unpublished_edition.reload.political
    end

    it "unmarks eligible published editions of documents first published after the specified date as not political" do
      organisation.update!(political: false)
      published_document = create(:document)
      published_edition = create(:publication, :published, document: published_document, first_published_at: "01-01-2023", political: true)
      draft_of_published_edition = create(:publication, :draft, document: published_document, political: true)
      withdrawn_document = create(:document)
      withdrawn_edition = create(:publication, :withdrawn, document: withdrawn_document, first_published_at: "01-01-2023", political: true)
      draft_of_withdrawn_edition = create(:publication, :draft, document: withdrawn_document, political: true)
      unpublished_document = create(:document)
      unpublished_edition = create(:publication, :unpublished, document: unpublished_document, first_published_at: "01-01-2023", political: true)
      draft_of_unpublished_edition = create(:publication, :draft, document: unpublished_document, political: true)
      organisation.editions = [published_edition, draft_of_published_edition, withdrawn_edition, draft_of_withdrawn_edition, unpublished_edition, draft_of_unpublished_edition]
      organisation.save!

      # All editions are "potentially" political by virtue of their type
      assert([published_edition, withdrawn_edition, unpublished_edition].pluck(:publication_type).each { |type| PoliticalContentIdentifier::POLITICAL_PUBLICATION_TYPES.include?(type) })

      capture_io { task.invoke(organisation.slug, date) }

      assert_not published_edition.reload.political
      assert_not draft_of_published_edition.reload.political
      # These states are not included
      assert withdrawn_edition.reload.political
      assert draft_of_withdrawn_edition.reload.political
      assert unpublished_edition.reload.political
      assert draft_of_unpublished_edition.reload.political
    end

    # This is a characterisation test. Ideally, manually set political markers would not be affected by the task.
    it "unmarks political flag set by the user for non-political document types" do
      organisation.update!(political: true)
      published_document = create(:document)
      non_political_publication_type = PublicationType.all.detect { |type| PoliticalContentIdentifier::POLITICAL_PUBLICATION_TYPES.exclude?(type) }
      published_edition = create(:publication, :published, publication_type: non_political_publication_type, document: published_document, first_published_at: "01-01-2023", political: true)
      organisation.editions = [published_edition]
      organisation.save!

      # Confirm that the edition was manually set to political
      assert_not PoliticalContentIdentifier.political?(published_edition)
      assert published_edition.political

      organisation.update!(political: false)
      capture_io { task.invoke(organisation.slug, date) }

      assert_not published_edition.reload.political
    end

    it "does not mark editions unrelated to documents first published before the specified date as political" do
      non_political_document = create(:document)
      published_edition = create(:publication, :published, document: non_political_document, political: false, first_published_at: "30-12-2022")
      draft_edition = create(:publication, :draft, document: non_political_document, political: false)
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
