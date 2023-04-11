require "test_helper"
require "rake"

class ClonePublishedHtmlAttachmentToDraftEditionRake < ActiveSupport::TestCase
  STATES = Edition.state_machine.states.map(&:name).map(&:to_s).freeze

  teardown do
    Rake::Task["clone_published_html_attachment_to_draft_edition"].reenable
  end

  test "it deep clones an html attachment from a published edition to a pre-published edition" do
    published_edition = create(:edition, :published)
    html_attachment = create(:html_attachment, attachable: published_edition, body: "test")
    draft_edition = create(:edition, :draft, document: published_edition.document)

    Rake.application.invoke_task("clone_published_html_attachment_to_draft_edition[#{html_attachment.id}]")

    attachment = draft_edition.attachments.first

    assert_equal 1, draft_edition.reload.attachments.count
    assert_equal "test", attachment.body
    assert_equal "test", attachment.govspeak_content.body
  end

  test "it deep clones an html attachment from a superseded edition to a pre-published edition" do
    superseded_edition = create(:edition, :superseded)
    html_attachment = create(:html_attachment, attachable: superseded_edition, body: "test")
    draft_edition = create(:edition, :draft, document: superseded_edition.document)

    Rake.application.invoke_task("clone_published_html_attachment_to_draft_edition[#{html_attachment.id}]")

    attachment = draft_edition.attachments.first

    assert_equal 1, draft_edition.reload.attachments.count
    assert_equal "test", attachment.body
    assert_equal "test", attachment.govspeak_content.body
  end

  (STATES - %w[published superseded]).each do |state|
    test "it raises an error if the html attachments edition is in the #{state} state" do
      edition = create(:edition, state)
      html_attachment = create(:html_attachment, attachable: edition, body: "test")

      assert_raises(StandardError, "The HTML attachment must belong to a published or superseded edition") do
        Rake.application.invoke_task("clone_published_html_attachment_to_draft_edition[#{html_attachment.id}]")
      end
    end
  end

  (STATES - Edition::PRE_PUBLICATION_STATES).each do |state|
    test "it raises an error if latest edition is in the #{state} state" do
      edition = create(:edition, %i[published superseded].sample)
      html_attachment = create(:html_attachment, attachable: edition, body: "test")
      create(
        :edition,
        state:,
        document: edition.document,
        major_change_published_at: state == "published" ? Time.zone.now : nil,
      )

      assert_raises(StandardError, "The HTML attachments associated document must have an edition in a pre-published state.") do
        Rake.application.invoke_task("clone_published_html_attachment_to_draft_edition[#{html_attachment.id}]")
      end
    end
  end
end
