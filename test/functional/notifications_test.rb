require 'test_helper'

class NotificationsFactCheckRequestTest < ActionMailer::TestCase
  enable_url_helpers

  setup do
    @policy = create(:policy, title: "<policy-title>")
    @requestor = create(:fact_check_requestor, name: "<requestor-name>")
    @request = create(:fact_check_request,
      email_address: 'fact-checker@example.com',
      document: @policy,
      requestor: @requestor
    )
    @mail = Notifications.fact_check_request(@request, host: "example.com")
  end

  test "email should be sent to the fact checker email address" do
    assert_equal ['fact-checker@example.com'], @mail.to
  end

  test "email should be sent from a generic email address" do
    assert_equal ["fact-checking@example.com"], @mail.from
  end

  test "email subject should include the name of the requestor and the document title" do
    assert_equal "Fact checking request from <requestor-name>: <policy-title>", @mail.subject
  end

  test "email body should contain a link to the fact checking comment page" do
    url = edit_admin_fact_check_request_url(@request)
    assert_match Regexp.new(url), @mail.body.to_s
  end

  test "email body should contain the title of the document to be checked" do
    assert_match %r{<policy-title>}, @mail.body.to_s
  end

  test "email body should contain the type of the document to be checked" do
    assert_match %r{policy}, @mail.body.to_s
  end

  test "email body should contain unescaped instructions" do
    request = create(:fact_check_request, instructions: %{Don't escape "this" text})
    mail = Notifications.fact_check_request(request, host: "example.com")

    assert_match %r{Don't escape "this" text}, mail.body.to_s
  end

  test "email body should contain unescaped document title" do
    policy = create(:policy, title: %{Use "double quotes" everywhere})
    request = create(:fact_check_request, document: policy)
    mail = Notifications.fact_check_request(request, host: "example.com")

    assert_match %r{Use "double quotes" everywhere}, mail.body.to_s
  end
end

class NotificationsFactCheckResponseTest < ActionMailer::TestCase
  enable_url_helpers

  include ActionController::RecordIdentifier
  include AdminDocumentRoutesHelper

  setup do
    @policy = create(:policy, title: "<policy-title>")
    @requestor = create(:fact_check_requestor,
      name: "<requestor-name>",
      email_address: "fact-check-requestor@example.com"
    )
    @request = create(:fact_check_request,
      email_address: 'fact-checker@example.com',
      document: @policy,
      requestor: @requestor
    )
    @mail = Notifications.fact_check_response(@request, host: "example.com")
  end

  test "email should be sent to the requestor email address" do
    assert_equal ['fact-check-requestor@example.com'], @mail.to
  end

  test "email should be sent from a generic email address" do
    assert_equal ["fact-checking@example.com"], @mail.from
  end

  test "email subject should include the name of the requestor and the document title" do
    assert_equal "Fact check comment added by fact-checker@example.com: <policy-title>", @mail.subject
  end

  test "email body should contain a link to the comment on the document page" do
    url = admin_document_url(@request.document, anchor: dom_id(@request))
    assert_match Regexp.new(url), @mail.body.to_s
  end

  test "email body should contain the title of the document to be checked" do
    assert_match %r{<policy-title>}, @mail.body.to_s
  end

  test "email body should contain the type of the document to be checked" do
    assert_match %r{policy}, @mail.body.to_s
  end

  test "email body should contain unescaped instructions" do
    request = create(:fact_check_request, instructions: %{Don't escape "this" text})
    mail = Notifications.fact_check_response(request, host: "example.com")

    assert_match %r{Don't escape "this" text}, mail.body.to_s
  end

  test "email body should contain unescaped document title" do
    policy = create(:policy, title: %{Use "double quotes" everywhere})
    request = create(:fact_check_request, document: policy)
    mail = Notifications.fact_check_request(request, host: "example.com")

    assert_match %r{Use "double quotes" everywhere}, mail.body.to_s
  end
end