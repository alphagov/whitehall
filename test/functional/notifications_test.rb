require 'test_helper'

class NotificationsTest < ActionMailer::TestCase
  enable_url_helpers

  setup do
    @policy = create(:policy, title: "<policy-title>")
    @requestor = create(:fact_check_requestor, name: "<requestor-name>")
    @request = create(:fact_check_request,
      email_address: 'fact-check@example.com',
      document: @policy,
      requestor: @requestor
    )
    @mail = Notifications.fact_check(@request, host: "example.com")
  end

  test "fact check should be sent to the specified email address" do
    assert_equal ['fact-check@example.com'], @mail.to
  end

  test "fact check should be sent from a generic email address" do
    assert_equal ["fact-check-request@example.com"], @mail.from
  end

  test "fact check subject contains the name of the requestor and document title" do
    assert_equal "Fact checking request from <requestor-name>: <policy-title>", @mail.subject
  end

  test "fact check email should contain a policy link containing a token" do
    url = edit_admin_fact_check_request_url(@request)
    assert_match Regexp.new(url), @mail.body.to_s
  end

  test "fact check body contains the title of the document to be checked" do
    assert_match %r{<policy-title>}, @mail.body.to_s
  end

  test "fact check body contains the type of the document to be checked" do
    assert_match %r{policy}, @mail.body.to_s
  end

  test "fact check request instructions shouldn't be escaped in the body" do
    request = create(:fact_check_request, instructions: %{Don't escape "this" text})
    mail = Notifications.fact_check(request, host: "example.com")

    assert_match %r{Don't escape "this" text}, mail.body.to_s
  end

  test "document titles shouldn't be escaped in the body" do
    policy = create(:policy, title: %{Use "double quotes" everywhere})
    request = create(:fact_check_request, document: policy)
    mail = Notifications.fact_check(request, host: "example.com")

    assert_match %r{Use "double quotes" everywhere}, mail.body.to_s
  end
end