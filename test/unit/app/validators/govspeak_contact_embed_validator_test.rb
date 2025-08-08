require "test_helper"

class GovspeakContactEmbedValidatorTest < ActiveSupport::TestCase
  def setup
    @valid_contact = create(:contact)
    @invalid_contact_id = "9999999999999"
    @validator = GovspeakContactEmbedValidator.new
  end

  test "validates nil body without errors" do
    edition = create_edition_with_body(nil)
    @validator.validate(edition)
    assert_empty edition.errors[:body]
  end

  test "validates empty body without errors" do
    edition = create_edition_with_body("")
    @validator.validate(edition)
    assert_empty edition.errors[:body]
  end

  test "validates body with existing contact without errors" do
    edition = create_edition_with_body("[Contact:#{@valid_contact.id}]")
    @validator.validate(edition)
    assert_empty edition.errors[:body]
  end

  test "validates body with multiple existing contacts without errors" do
    contact2 = create(:contact)
    body = "[Contact:#{@valid_contact.id}] and [Contact:#{contact2.id}]"
    edition = create_edition_with_body(body)
    @validator.validate(edition)
    assert_empty edition.errors[:body]
  end

  test "skips validation when edition is not in publish context" do
    edition = create_edition_with_body("[Contact:#{@invalid_contact_id}]")
    edition.valid?
    assert_no_contact_errors(edition)
  end

  test "validates when edition is in publish context" do
    edition = create_edition_with_body("[Contact:#{@invalid_contact_id}]")
    edition.valid?(:publish)
    assert_contact_error_present(edition)
  end

  test "validates HTML attachment with non-existent contact" do
    attachment = create_html_attachment_with_body("[Contact:#{@invalid_contact_id}]", title: "Annual Report 2025")
    @validator.validate(attachment)
    assert_html_attachment_error(attachment, "Annual Report 2025")
  end

  test "skips validation during draft creation and validates during editing" do
    published_edition = create_published_edition_with_attachment

    assert_nothing_raised do
      draft_edition = create_draft_from_published(published_edition)
      assert_equal 2, draft_edition.html_attachments.count
    end

    published_edition = create(:published_publication)
    draft_edition = published_edition.create_draft(create(:user))
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft_edition)

    assert attachment.valid?

    attachment.save!(validate: false)
    attachment.title = "Updated title"

    assert_not attachment.valid?
    error_message = attachment.errors[:base].first
    assert_includes error_message, "Contact ID #{@invalid_contact_id} doesn't exist"
    assert_includes error_message, "may have been removed since the original publication"
  end

  test "provides context-aware error messages for new vs existing documents" do
    new_edition = create(:draft_publication)
    new_attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: new_edition)

    assert_not new_attachment.valid?
    new_error = new_attachment.errors[:base].first
    assert_includes new_error, "Contact ID #{@invalid_contact_id} doesn't exist"
    assert_includes new_error, "You may need to create this contact first"

    published_edition = create(:published_publication)
    draft_edition = published_edition.create_draft(create(:user))
    existing_attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft_edition)
    existing_attachment.save!(validate: false)
    existing_attachment.title = "Updated title"

    assert_not existing_attachment.valid?
    existing_error = existing_attachment.errors[:base].first
    assert_includes existing_error, "Contact ID #{@invalid_contact_id} doesn't exist"
    assert_includes existing_error, "may have been removed since the original publication"
  end

  test "handles complex document workflows and contact recovery" do
    published_edition = create(:published_publication)
    draft1 = published_edition.create_draft(create(:user))
    draft1.destroy!
    draft2 = published_edition.create_draft(create(:user))
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft2)
    assert attachment.valid?

    contact = create(:contact)
    published_edition = create(:published_publication)
    valid_attachment = build(:html_attachment, attachable: published_edition)
    valid_attachment.govspeak_content.body = "[Contact:#{contact.id}]"
    valid_attachment.save!
    contact.destroy!

    draft_edition = nil
    assert_nothing_raised do
      draft_edition = published_edition.create_draft(create(:user))
    end
    assert_not_nil draft_edition

    attachment = draft_edition.html_attachments.first
    attachment.govspeak_content.body = "Fixed content without contact reference"
    assert attachment.valid?

    new_contact = create(:contact)
    attachment.govspeak_content.body = "[Contact:#{new_contact.id}]"
    assert attachment.valid?
  end

  test "handles published document with mixed valid and invalid attachments" do
    contact1 = create(:contact)
    contact2_id = "999999"

    published_edition = create(:published_publication)

    valid_attachment = build(:html_attachment, attachable: published_edition)
    valid_attachment.govspeak_content.body = "[Contact:#{contact1.id}]"
    valid_attachment.save!

    invalid_attachment = build(:html_attachment, attachable: published_edition)
    invalid_attachment.govspeak_content.body = "[Contact:#{contact2_id}]"
    invalid_attachment.save!(validate: false)

    assert_nothing_raised do
      draft = published_edition.create_draft(create(:user))
      assert_equal 3, draft.html_attachments.count
    end
  end

  test "contact replacement workflow succeeds" do
    old_contact = create(:contact)
    published_edition = create(:published_publication)
    attachment = build(:html_attachment, attachable: published_edition)
    attachment.govspeak_content.body = "[Contact:#{old_contact.id}]"
    attachment.save!

    old_contact.destroy!
    draft = published_edition.create_draft(create(:user))

    new_contact = create(:contact)
    draft_attachment = draft.html_attachments.first
    draft_attachment.govspeak_content.body = "[Contact:#{new_contact.id}]"

    assert draft_attachment.valid?
    assert_empty(draft_attachment.errors.full_messages.select { |msg| msg.include?("doesn't exist") })
  end

  test "handles combined body and attachment contact errors" do
    edition = create(:draft_publication)
    edition.body = "[Contact:#{@invalid_contact_id}]"

    attachment = build(:html_attachment, attachable: edition)
    attachment.govspeak_content.body = "[Contact:888888]"
    attachment.save!(validate: false)

    edition.valid?(:publish)
    @validator.validate(attachment)

    edition_errors = edition.errors.full_messages.select { |msg| msg.include?("Contact ID") }
    attachment_errors = attachment.errors.full_messages.select { |msg| msg.include?("Contact ID") }

    assert edition_errors.any? { |e| e.include?(@invalid_contact_id) }, "Should find edition contact error"
    assert attachment_errors.any? { |e| e.include?("888888") }, "Should find attachment contact error"
  end

  test "handles malformed contact references gracefully" do
    malformed_references = [
      "[Contact:abc]",
      "[Contact:]",
      "[Contact:123abc]",
      "[Contact: 123]",
      "[Contact: ]",
      "[contact:123]",
    ]

    malformed_references.each do |reference|
      attachment = create_html_attachment_with_body(reference, title: "Test #{reference}")
      assert_nothing_raised { @validator.validate(attachment) }
    end
  end

private

  def create_edition_with_body(body)
    Edition.new(body: body)
  end

  def create_html_attachment_with_body(body, **options)
    attachment = build(:html_attachment, **options)
    attachment.id = options[:id] if options.key?(:id)
    attachment.govspeak_content.body = body if body
    attachment
  end

  def assert_no_contact_errors(model)
    contact_errors = (model.errors[:body] + model.errors[:base]).select { |error| error.include?("Contact ID") }
    assert_empty contact_errors
  end

  def assert_contact_error_present(model, contact_id = @invalid_contact_id)
    contact_errors = (model.errors[:body] + model.errors[:base]).select { |error| error.include?("Contact ID") }
    assert_equal 1, contact_errors.size, "Expected exactly one contact validation error"
    assert_includes contact_errors.first, contact_id.to_s
  end

  def assert_html_attachment_error(model, expected_identifier, contact_id = @invalid_contact_id)
    assert_equal 1, model.errors[:base].size
    error_message = model.errors[:base].first

    expected_prefix = if expected_identifier.to_s.match?(/^\d+$/)
                        "HTML Attachment #{expected_identifier} contains invalid contact reference"
                      else
                        "HTML Attachment '#{expected_identifier}' contains invalid contact reference"
                      end

    assert_includes error_message, expected_prefix
    assert_includes error_message, "Contact ID #{contact_id} doesn't exist"
  end

  def create_published_edition_with_attachment(body = "[Contact:#{@invalid_contact_id}]")
    published_edition = create(:published_publication)
    attachment = build(:html_attachment, attachable: published_edition)
    attachment.govspeak_content.body = body
    attachment.save!(validate: false)
    published_edition
  end

  def create_draft_from_published(published_edition)
    published_edition.create_draft(create(:user))
  end
end
