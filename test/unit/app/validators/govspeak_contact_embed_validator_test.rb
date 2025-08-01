require "test_helper"

class GovspeakContactEmbedValidatorTest < ActiveSupport::TestCase
  def setup
    @valid_contact = create(:contact)
    @invalid_contact_id = "9999999999999"
    @validator = GovspeakContactEmbedValidator.new
  end

  test "validates nil body without errors" do
    model = create_edition_with_body(nil)
    @validator.validate(model)

    assert_equal 0, model.errors.size
    assert_equal [], model.errors[:body]
  end

  test "validates empty body without errors" do
    model = create_edition_with_body("")
    @validator.validate(model)

    assert_equal 0, model.errors.size
    assert_equal [], model.errors[:body]
  end

  test "validates body with existing contact without errors" do
    model = create_edition_with_body("[Contact:#{@valid_contact.id}]")
    @validator.validate(model)

    assert_equal 0, model.errors.size
    assert_equal [], model.errors[:body]
  end

  test "validates body with multiple existing contacts without errors" do
    contact2 = create(:contact)
    body = "[Contact:#{@valid_contact.id}] and [Contact:#{contact2.id}]"
    model = create_edition_with_body(body)
    @validator.validate(model)

    assert_equal 0, model.errors.size
    assert_equal [], model.errors[:body]
  end

  test "skips validation when edition is not in publish context" do
    model = create_edition_with_body("[Contact:#{@invalid_contact_id}]")
    model.valid? # No :publish context

    assert_no_contact_errors(model)
  end

  test "validates when edition is in publish context" do
    model = create_edition_with_body("[Contact:#{@invalid_contact_id}]")
    model.valid?(:publish)

    assert_contact_error_present(model)
  end

  test "validates HTML attachment with non-existent contact and shows error" do
    attachment = create_html_attachment_with_body("[Contact:#{@invalid_contact_id}]", id: 12_345, title: nil)
    @validator.validate(attachment)

    assert_html_attachment_error(attachment, attachment.id)
  end

  test "uses HTML attachment title in error message when present" do
    attachment = create_html_attachment_with_body("[Contact:#{@invalid_contact_id}]", title: "Annual Report 2024")
    @validator.validate(attachment)

    assert_html_attachment_error(attachment, "Annual Report 2024")
  end

  test "uses HTML attachment ID in error message when title is blank" do
    attachment = create_html_attachment_with_body("[Contact:#{@invalid_contact_id}]", id: 67_890, title: "")
    @validator.validate(attachment)

    assert_html_attachment_error(attachment, attachment.id)
  end

  test "uses HTML attachment ID in error message when title is nil" do
    attachment = create_html_attachment_with_body("[Contact:#{@invalid_contact_id}]", id: 13_579, title: nil)
    @validator.validate(attachment)

    assert_html_attachment_error(attachment, attachment.id)
  end

  test "skips validation when creating draft with existing invalid HTML attachment" do
    published_edition = create_published_edition_with_attachment

    assert_nothing_raised do
      draft_edition = create_draft_from_published(published_edition)
      assert_equal 2, draft_edition.html_attachments.count
    end
  end

  test "suggests creating contact for new documents" do
    new_edition = create(:draft_publication)
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: new_edition)

    assert_not attachment.valid?
    error_message = attachment.errors.full_messages.first
    assert_includes error_message, "Contact ID #{@invalid_contact_id} doesn't exist"
    assert_includes error_message, "You may need to create this contact first"
  end

  test "indicates inherited issue for existing documents" do
    published_edition = create(:published_publication)
    draft_edition = published_edition.create_draft(create(:user))

    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft_edition)
    attachment.save!(validate: false)

    attachment.title = "Updated title"
    assert_not attachment.valid?

    error_message = attachment.errors.full_messages.first
    assert_includes error_message, "Contact ID #{@invalid_contact_id} doesn't exist"
    assert_includes error_message, "may have been removed since the original publication"
  end

  test "first document creation validates normally" do
    new_edition = create(:draft_publication)
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: new_edition)

    assert_not attachment.valid?
    error_message = attachment.errors.full_messages.first
    assert_includes error_message, "Contact ID #{@invalid_contact_id} doesn't exist"
    assert_includes error_message, "You may need to create this contact first"
  end

  test "draft creation from published document skips validation" do
    published_edition = create(:published_publication)
    draft_edition = published_edition.create_draft(create(:user))

    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft_edition)

    assert attachment.valid?
  end

  test "draft creation with invalid attachments does not raise errors" do
    published_edition = create(:published_publication)
    invalid_attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: published_edition)
    invalid_attachment.save!(validate: false)

    user = create(:user)
    assert_nothing_raised do
      draft_edition = published_edition.create_draft(user)
      assert_equal 2, draft_edition.html_attachments.count
    end
  end

  test "editing existing attachment validates after draft creation" do
    published_edition = create(:published_publication)
    draft_edition = published_edition.create_draft(create(:user))

    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft_edition)
    attachment.save!(validate: false)

    attachment.title = "Updated title"
    assert_not attachment.valid?
    error_message = attachment.errors.full_messages.first
    assert_includes error_message, "Contact ID #{@invalid_contact_id} doesn't exist"
    assert_includes error_message, "may have been removed since the original publication"
  end

  test "complex document history uses published editions check" do
    published_edition = create(:published_publication)
    draft1 = published_edition.create_draft(create(:user))
    draft1.destroy!

    draft2 = published_edition.create_draft(create(:user))
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft2)

    assert attachment.valid?
  end

  test "superseded editions are treated as published content" do
    published_edition = create(:published_publication)

    draft_edition = published_edition.create_draft(create(:user))
    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft_edition)

    assert attachment.valid?
  end

  test "validation during draft creation process is skipped" do
    published_edition = create(:published_publication)

    assert_nothing_raised do
      published_edition.create_draft(create(:user))
    end
  end

  test "new record attachments on drafts from published skip validation" do
    published_edition = create(:published_publication)
    draft_edition = published_edition.create_draft(create(:user))

    attachment = build(:html_attachment, body: "[Contact:#{@invalid_contact_id}]", attachable: draft_edition)
    assert attachment.new_record?
    assert attachment.valid?
  end

  test "complete edit workflow for inherited invalid content" do
    contact = create(:contact)
    published_edition = create(:published_publication)
    valid_attachment = build(:html_attachment, attachable: published_edition)
    valid_attachment.govspeak_content.body = "[Contact:#{contact.id}]"
    valid_attachment.save!

    assert_includes valid_attachment.govspeak_content.body, contact.id.to_s

    contact.destroy!

    user = create(:user)
    draft_edition = nil
    assert_nothing_raised do
      draft_edition = published_edition.create_draft(user)
    end

    assert_not_nil draft_edition, "Draft edition should be created"
    assert draft_edition.html_attachments.count >= 1, "Should have HTML attachments (at least our test one)"

    attachment = draft_edition.html_attachments.first

    attachment.govspeak_content.body = "Fixed content without contact reference"

    assert attachment.valid?, "Attachment with fixed content should be valid"

    new_contact = create(:contact)
    attachment.govspeak_content.body = "[Contact:#{new_contact.id}]"

    assert attachment.valid?, "Attachment with valid contact reference should be valid"
  end

private

  def create_edition_with_body(body)
    Edition.new(body: body)
  end

  def create_html_attachment_with_body(body, **options)
    attachment = build(:html_attachment, **options)
    attachment.id = options[:id] if options[:id]
    attachment.govspeak_content.body = body if body
    attachment
  end

  def assert_no_contact_errors(model)
    contact_errors = model.errors.select { |error| error.message.include?("Contact ID") }
    assert_empty contact_errors, "Expected no contact validation errors"
  end

  def assert_contact_error_present(model, contact_id = @invalid_contact_id)
    contact_errors = model.errors.select { |error| error.message.include?("Contact ID") }
    assert_equal 1, contact_errors.size, "Expected exactly one contact validation error"
    assert_includes contact_errors.first.message, contact_id.to_s
  end

  def assert_html_attachment_error(model, expected_identifier, contact_id = @invalid_contact_id)
    assert_equal 1, model.errors.size
    error_message = model.errors.map(&:type).first

    if expected_identifier.is_a?(Numeric) || expected_identifier.to_s.match?(/^\d+$/)
      assert_includes error_message, "HTML Attachment #{expected_identifier} invalid"
    else
      assert_includes error_message, "HTML Attachment '#{expected_identifier}' invalid"
    end

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
    user = create(:user)
    published_edition.create_draft(user)
  end
end
