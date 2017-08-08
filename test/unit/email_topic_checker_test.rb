require "test_helper"

class EmailTopicCheckerTest < ActiveSupport::TestCase
  setup do
    response = mock("Response", to_str: "http://example.com?topic_id=TOPIC_123")
    Whitehall.govuk_delivery_client.stubs(:signup_url).returns(response)

    mock_client = mock("EmailAlertApi", topic_matches: { "topics" => ["TOPIC_456"] })
    EmailTopicChecker.any_instance.stubs(email_alert_api: mock_client)

    content_item = { "email_document_supertype" => "foo", "government_document_supertype" => "bar" }
    Whitehall.content_store.stubs(content_item: content_item)

    edition = create(:edition, :published)
    @content_id = edition.document.content_id
  end

  test "lists govuk-delivery topics" do
    assert_output(/^govuk-delivery topics:\nTOPIC_123/m) do
      EmailTopicChecker.check(@content_id)
    end
  end

  test "lists email-alert-api topics" do
    assert_output(/^email-alert-api topics:\nTOPIC_456/m) do
      EmailTopicChecker.check(@content_id)
    end
  end

  test "lists additional govuk-delivery topics" do
    assert_output(/additional govuk-delivery topics:\nTOPIC_123/m) do
      EmailTopicChecker.check(@content_id)
    end
  end

  test "lists additional email-alert-api topics" do
    assert_output(/additional email-alert-api topics:\nTOPIC_456/m) do
      EmailTopicChecker.check(@content_id)
    end
  end

  test "lists email-alert-api params" do
    expected = {
      links: {},
      tags: {},
      document_type: "generic_edition",
      email_document_supertype: "foo",
      government_document_supertype: "bar",
    }

    assert_output(/^email-alert-api params:\n#{expected.to_s}/m) do
      EmailTopicChecker.check(@content_id)
    end
  end

  test "lists govuk-delivery feed urls" do
    expected = "https://www.test.gov.uk/government/feed"
    assert_output(/^govuk-delivery feed urls:\n#{expected}/m) do
      EmailTopicChecker.check(@content_id)
    end
  end
end
