require "test_helper"

class EmailTopicCheckerTest < ActiveSupport::TestCase
  setup do
    response = mock("Response", to_str: "http://example.com?topic_id=TOPIC_123")
    Whitehall.govuk_delivery_client.stubs(:signup_url).returns(response)

    mock_client = mock("EmailAlertApi", find_subscriber_list: {
      "subscriber_list" => { "gov_delivery_id" => "TOPIC_456" }
    });
    EmailTopicChecker.any_instance.stubs(email_alert_api: mock_client)

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
end
