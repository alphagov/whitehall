require "test_helper"

class MailRecipientInterceptorTest < ActiveSupport::TestCase
  setup do
    @mail = Mail.new(
      to: "original-recipient@example.com",
      body: "Hello from Whitehall",
    )

    ClimateControl.modify(EMAIL_ADDRESS_OVERRIDE: "intercepted@example.com") do
      MailRecipientInterceptor.delivering_email(@mail)
    end
  end

  test "intercepts emails and sends to the address specified by the EMAIL_ADDRESS_OVERRIDE env var" do
    assert_equal ["intercepted@example.com"], @mail.to
  end

  test "intercepts emails and prefixes the original recipient to the body" do
    assert_equal "Intended recipient(s): original-recipient@example.com\n\nHello from Whitehall", @mail.body.to_s
  end
end
