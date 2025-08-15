require "test_helper"

class HtmlAttachmentContactValidationTest < ActiveSupport::TestCase
  def setup
    @valid_contact = create(:contact)
    @invalid_contact_id = "99999"
  end

  test "validates HTML attachment with valid contact" do
    attachment = build(:html_attachment, body: "[Contact:#{@valid_contact.id}]")
    assert attachment.valid?
  end

  test "validates HTML attachment with invalid contact shows contextual error" do
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", title: "Test Document")

    assert_not attachment.valid?

    assert attachment.errors.details[:base].present?
    error_details = attachment.errors.details[:base].first
    assert_equal :invalid_contact, error_details[:error]
    assert_equal @invalid_contact_id, error_details[:contact_id]
  end

  test "skips validation for attachments created during draft process" do
    published_edition = create(:published_publication)
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: published_edition)
    attachment.instance_variable_set(:@created_during_draft, true)

    assert attachment.valid?
  end

  test "skips validation for new attachments on drafts of previously published documents" do
    published_edition = create(:published_publication)
    draft_edition = published_edition.create_draft(create(:user))
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft_edition)

    assert attachment.valid?
  end

  test "validates new attachments on first-time drafts" do
    draft_edition = create(:draft_publication)
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft_edition)

    assert_not attachment.valid?

    assert attachment.errors.details[:base].present?
    error_details = attachment.errors.details[:base].first
    assert_equal :invalid_contact, error_details[:error]
  end

  test "edition bubbles up HTML attachment contact errors on publish validation" do
    edition = create(:draft_publication)
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", title: "Invalid Doc", attachable: edition)
    attachment.save!(validate: false)

    assert_not edition.valid?(:publish)

    assert edition.errors.present?
    assert edition.errors[:base].present?

    error_message = edition.errors[:base].first
    assert_includes error_message, "HTML Attachment 'Invalid Doc' contains invalid contact reference"
    assert_includes error_message, "Contact #{@invalid_contact_id} doesn't exist"

    assert_not(edition.errors.full_messages.any? { |msg| msg == "Html attachments is invalid" })
  end
end
