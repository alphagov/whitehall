require "test_helper"

class ChangeNoteRake < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable # without this, calling `invoke` does nothing after first test
  end

  describe "#list" do
    let(:task) { Rake::Task["change_note:list"] }

    test "Lists major change history" do
      edition = create(:edition, :published, :with_document)

      expected_output = "#{edition.id}\t#{edition.major_change_published_at}\t#{edition.change_note}\n"

      assert_output(expected_output) { task.invoke(edition.content_id) }
    end

    test "Returns an appropriate message if no history found" do
      edition = create(:edition, :draft, :with_document)

      assert_output("No change notes found\n") { task.invoke(edition.content_id) }
    end
  end

  describe "#amend" do
    let(:task) { Rake::Task["change_note:amend"] }

    test "Changes a change note" do
      edition = create(:edition, :published, :with_document)
      user = create(:user)

      PublishingApiDocumentRepublishingWorker.expects(:perform_async).with(edition.document.id)

      task.invoke(edition.id, "New change note", user.email)

      edition.reload
      assert_equal(edition.change_note, "New change note")
      assert_equal(edition.editorial_remarks.pluck(:body), ["Updated change note from change-note to New change note"])
    end

    test "aborts early if user not found" do
      edition = create(:edition, :published, :with_document)

      assert_output("User with email not-a-user@gov.uk not found\n") { task.invoke(edition.id, "New change note", "not-a-user@gov.uk") }

      edition.reload
      assert_equal(edition.change_note, "change-note")
    end
  end
end
