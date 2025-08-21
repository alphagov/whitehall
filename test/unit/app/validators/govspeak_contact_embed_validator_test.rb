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

    GovspeakContactEmbedValidator.new.validate(test_model)

    assert_equal 1, test_model.errors.size
    assert_equal [
      "Contact ID #{bad_id} doesn't exist",
    ], test_model.errors.map(&:type)
  end

  test "should be valid if the HTML attachment contains a Contact that exists" do
    contact = create(:contact)
    edition = create(:case_study, body: "[Contact:#{contact.id}]")

    edition.html_attachments = [create(:html_attachment, body: "[Contact:#{contact.id}]")]

    GovspeakContactEmbedValidator.new.validate(edition)

    assert_equal 0, edition.errors.size
    assert_equal 0, edition.html_attachments.first.errors.size
  end

  test "should be invalid if the HTML attachment contains a Contact that has been deleted" do
    contact = create(:contact)
    edition = create(:case_study, html_attachments: [create(:html_attachment, body: "[Contact:#{contact.id}]")])
    contact.destroy!

    GovspeakContactEmbedValidator.new.validate(edition)

    assert_equal 1, edition.errors.where(:html_attachments).size
  end

  test "should add a specific error message if the HTML attachment contains a Contact that doesn't exist" do
    bad_id = "9999999999999"
    html_attachment = build(:html_attachment, title: "Test Doc", body: "[Contact:#{bad_id}]")
    edition = build(:case_study, html_attachments: [html_attachment])

    GovspeakContactEmbedValidator.new.validate(edition)

    error_message = edition.errors[:html_attachments].first
    expected_message = '"Test Doc" - embedded Contact (ID 9999999999999) doesn\'t exist'
    assert_includes error_message, expected_message
  end
end
