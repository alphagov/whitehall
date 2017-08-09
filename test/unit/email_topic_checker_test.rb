require "test_helper"

class EmailTopicCheckerTest < ActiveSupport::TestCase
  setup do
    response = stub("Response", to_str: "http://example.com?topic_id=TOPIC_123")
    Whitehall.govuk_delivery_client.stubs(:signup_url).returns(response)

    mock_client = stub("EmailAlertApi", topic_matches: { "topics" => ["TOPIC_456"] })
    EmailTopicChecker.any_instance.stubs(email_alert_api: mock_client)

    edition = create(:edition, :published)
    @document = edition.document

    content_item = {
      "content_id" => @document.content_id,
      "email_document_supertype" => "foo",
      "government_document_supertype" => "bar"
    }
    Whitehall.content_store.stubs(content_item: content_item)
  end

  test "lists govuk-delivery topics" do
    assert_match(
      /^govuk-delivery topics:\nTOPIC_123/,
      EmailTopicChecker.check(@document)
    )
  end

  test "lists email-alert-api topics" do
    assert_match(
      /^email-alert-api topics:\nTOPIC_456/,
      EmailTopicChecker.check(@document)
    )
  end

  test "lists additional govuk-delivery topics" do
    assert_match(
      /additional govuk-delivery topics:\nTOPIC_123/,
      EmailTopicChecker.check(@document)
    )
  end

  test "lists additional email-alert-api topics" do
    assert_match(
      /additional email-alert-api topics:\nTOPIC_456/,
      EmailTopicChecker.check(@document)
    )
  end

  test "lists email-alert-api params" do
    expected = {
      links: {},
      tags: {},
      document_type: "generic_edition",
      email_document_supertype: "foo",
      government_document_supertype: "bar",
    }

    assert_match(
      /^email-alert-api params:\n#{expected.to_s}/m,
      EmailTopicChecker.check(@document)
    )
  end

  test "lists govuk-delivery feed urls" do
    expected = "https://www.test.gov.uk/government/feed"
    assert_match(
      /^govuk-delivery feed urls:\n#{expected}/m,
      EmailTopicChecker.check(@document)
    )
  end

  test "raises if content store returns an item with a different content id" do
    @document.content_id = SecureRandom.uuid
    assert_raises do
      EmailTopicChecker.check(@document)
    end
  end
end
