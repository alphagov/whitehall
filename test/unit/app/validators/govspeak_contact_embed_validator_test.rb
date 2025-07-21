require "test_helper"

class GovspeakContactEmbedValidatorTest < ActiveSupport::TestCase
  test "should be valid if the input is nil" do
    test_model = Edition.new(body: nil)

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 0, test_model.errors.size
    assert_equal [], test_model.errors[:body]
  end

  test "should be valid if the input contains a Contact that exists" do
    contact = create(:contact)
    test_model = Edition.new(body: "[Contact:#{contact.id}]")

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 0, test_model.errors.size
    assert_equal [], test_model.errors[:body]
  end

  test "should be invalid if the input contains a Contact that doesn't exist" do
    bad_id = "9999999999999"
    test_model = Edition.new(body: "[Contact:#{bad_id}]")

    test_model.valid?(:publish)

    contact_errors = test_model.errors.select { |error| error.message.include?("Contact ID") }
    assert_equal 1, contact_errors.size
    assert_equal ["Contact ID #{bad_id} doesn't exist"], contact_errors.map(&:message)
  end

  test "should be valid if Edition contains a Contact that doesn't exist but not in publish context" do
    bad_id = "9999999999999"
    test_model = Edition.new(body: "[Contact:#{bad_id}]")

    test_model.valid?

    contact_errors = test_model.errors.select { |error| error.message.include?("Contact ID") }
    assert_empty contact_errors
  end

  test "should be invalid if HTML attachment contains a Contact that doesn't exist" do
    bad_id = "9999999999999"
    test_model = build(:html_attachment, body: "[Contact:#{bad_id}]")
    test_model.id = 12345

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 1, test_model.errors.size
    error_message = test_model.errors.map(&:type).first
    assert_match(/HTML Attachment '.*' invalid: Contact ID #{bad_id} doesn't exist/, error_message)
  end

  test "should use HTML attachment title in error message when title is present" do
    bad_id = "9999999999999"
    test_model = build(:html_attachment, title: "Annual Report 2024", body: "[Contact:#{bad_id}]")

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 1, test_model.errors.size
    assert_equal ["HTML Attachment 'Annual Report 2024' invalid: Contact ID #{bad_id} doesn't exist"], test_model.errors.map(&:type)
  end

  test "should use HTML attachment ID in error message when title is blank" do
    bad_id = "9999999999999"
    test_model = build(:html_attachment, title: "", body: "[Contact:#{bad_id}]")
    test_model.id = 67890

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 1, test_model.errors.size
    assert_equal ["HTML Attachment #{test_model.id} invalid: Contact ID #{bad_id} doesn't exist"], test_model.errors.map(&:type)
  end

  test "should use HTML attachment ID in error message when title is nil" do
    bad_id = "9999999999999"
    test_model = build(:html_attachment, title: nil, body: "[Contact:#{bad_id}]")
    test_model.id = 13579

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 1, test_model.errors.size
    assert_equal ["HTML Attachment #{test_model.id} invalid: Contact ID #{bad_id} doesn't exist"], test_model.errors.map(&:type)
  end

  test "should skip validation when creating a draft with existing invalid HTML attachment" do
    published_edition = create(:published_publication)
    invalid_attachment = build(:html_attachment, body: "[Contact:9999999999999]", attachable: published_edition)
    invalid_attachment.save!(validate: false)
    
    user = create(:user)
    assert_nothing_raised do
      draft_edition = published_edition.create_draft(user)
      assert_equal 2, draft_edition.html_attachments.count
    end
  end
end
