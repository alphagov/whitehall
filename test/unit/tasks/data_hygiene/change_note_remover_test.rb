require "test_helper"

class ChangeNoteRemoverTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe DataHygiene::ChangeNoteRemover do
    let(:document)                { create(:document) }
    let!(:superseded_edition)     { create(:superseded_edition, document: document, change_note: "First change note.", first_published_at: 2.days.ago, created_at: 2.days.ago, major_change_published_at: 2.days.ago) }
    let!(:previous_major_edition) { create(:superseded_edition, document: document, change_note: "Second change note.", created_at: 1.day.ago, major_change_published_at: 1.day.ago) }
    let!(:live_edition)           { create(:published_edition, document: document, change_note: "Third change note.", created_at: Time.zone.now, major_change_published_at: Time.zone.now) }

    let(:query) { nil }

    let(:deleted_edition) do
      call_change_note_remover
    end

    def call_change_note_remover
      DataHygiene::ChangeNoteRemover.call(document.content_id, "en", query, dry_run: dry_run)
    end

    context "during a dry run" do
      let(:dry_run) { true }

      context "the query matches a change note" do
        let(:query) { "third" }

        it "doesn't delete the change note" do
          call_change_note_remover
          assert_not_nil(superseded_edition.reload.change_note)
          assert_not_nil(live_edition.reload.change_note)
        end

        it "doesn't change the major published at time" do
          call_change_note_remover
          assert_equal(live_edition.reload.major_change_published_at, deleted_edition.major_change_published_at)
        end

        it "returns the change note" do
          assert_equal(live_edition, deleted_edition)
        end
      end
    end

    context "during a real run" do
      let(:dry_run) { false }

      context "the query doesn't match a change note" do
        let(:query) { "nonexistent" }

        it "raises an exception" do
          assert_raises DataHygiene::ChangeNoteNotFound do
            call_change_note_remover
          end
        end
      end

      context "the query matches a change note" do
        let(:query) { "third" }

        it "deletes the change note" do
          call_change_note_remover
          assert_not_nil(superseded_edition.reload.change_note)
          assert_nil(live_edition.reload.change_note)
        end

        it "removes change_history from the edition" do
          call_change_note_remover
          assert_equal(
            document.change_history.changes,
            [
              DocumentHistory::Change.new(previous_major_edition.public_timestamp, previous_major_edition.change_note),
              DocumentHistory::Change.new(superseded_edition.public_timestamp, superseded_edition.change_note),
            ],
          )
        end

        it "changes the major published at time to the previous major update" do
          call_change_note_remover
          assert_equal(live_edition.reload.major_change_published_at, previous_major_edition.major_change_published_at)
        end

        it "represents to the content store" do
          PublishingApiDocumentRepublishingWorker
            .any_instance
            .expects(:perform)
            .with(document.id)

          call_change_note_remover
        end

        it "returns the edition" do
          assert_equal(deleted_edition, live_edition)
        end
      end
    end
  end
end
