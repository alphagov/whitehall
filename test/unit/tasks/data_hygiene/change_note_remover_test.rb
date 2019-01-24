require "test_helper"

class ChangeNoteRemoverTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:document)            { create(:document) }
  let!(:superseded_edition) { create(:superseded_edition, document: document, change_note: "First change note.") }
  let!(:live_edition)       { create(:published_edition, document: document, change_note: "Second change note.") }

  let(:query) { nil }

  let(:deleted_edition) do
    call_change_note_remover
  end

  def call_change_note_remover
    DataHygiene::ChangeNoteRemover.call(document.content_id, 'en', query, dry_run: dry_run)
  end

  context "during a dry run" do
    let(:dry_run) { true }

    context "the query matches a change note" do
      let(:query) { "second" }

      it "doesn't delete the change note" do
        call_change_note_remover
        assert_not_nil(superseded_edition.reload.change_note)
        assert_not_nil(live_edition.reload.change_note)
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
      let(:query) { "second" }

      it "deletes the change note" do
        call_change_note_remover
        assert_not_nil(superseded_edition.reload.change_note)
        assert_nil(live_edition.reload.change_note)
      end

      it "removes change_history from the edition" do
        call_change_note_remover
        assert_equal(
          document.change_history.changes,
          [DocumentHistory::Change.new(nil, superseded_edition.change_note)]
        )
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
