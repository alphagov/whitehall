require 'test_helper'

class NotificationsFactCheckRequestTest < ActionMailer::TestCase
  enable_url_helpers

  setup do
    @publication = build(:publication, title: "<publication-title>")
    @requestor = build(:fact_check_requestor, name: "<requestor-name>")
    @request = build(
      :fact_check_request,
      email_address: 'fact-checker@example.com',
      edition: @publication,
      requestor: @requestor
    )
    @mail = Notifications.fact_check_request(@request, host: "example.com")
  end

  test "email should be sent to the fact checker email address" do
    assert_equal ['fact-checker@example.com'], @mail.to
  end

  test "email subject should include the name of the requestor and the edition title" do
    assert_equal "Fact checking request from <requestor-name>: <publication-title>", @mail.subject
  end

  test "email body should contain a link to the fact checking comment page" do
    url = edit_admin_fact_check_request_url(@request)
    assert_match Regexp.new(url), @mail.body.to_s
  end

  test "email body should contain the title of the edition to be checked" do
    assert_match %r{<publication-title>}, @mail.body.to_s
  end

  test "email body should contain the type of the edition to be checked" do
    assert_match %r{publication}, @mail.body.to_s
  end

  test "email body should contain unescaped instructions" do
    request = build(:fact_check_request, instructions: %{Don't escape "this" text})
    mail = Notifications.fact_check_request(request, host: "example.com")

    assert_match %r{Don't escape "this" text}, mail.body.to_s
  end

  test "email body should contain unescaped edition title" do
    publication = build(:publication, title: %{Use "double quotes" everywhere})
    request = build(:fact_check_request, edition: publication)
    mail = Notifications.fact_check_request(request, host: "example.com")

    assert_match %r{Use "double quotes" everywhere}, mail.body.to_s
  end
end

class NotificationsFactCheckResponseTest < ActionMailer::TestCase
  enable_url_helpers

  include ActionView::RecordIdentifier
  include Admin::EditionRoutesHelper

  setup do
    @publication = build(:publication, title: "<publication-title>")
    @requestor = build(
      :fact_check_requestor,
      name: "<requestor-name>",
      email: "fact-check-requestor@example.com"
    )
    @request = build(
      :fact_check_request,
      email_address: 'fact-checker@example.com',
      edition: @publication,
      requestor: @requestor
    )
    @mail = Notifications.fact_check_response(@request, host: "example.com")
  end

  test "email should be sent to the requestor email address" do
    assert_equal ['fact-check-requestor@example.com'], @mail.to
  end

  test "email subject should include the name of the requestor and the edition title" do
    assert_equal "Fact check comment added by fact-checker@example.com: <publication-title>", @mail.subject
  end

  test "email body should contain a link to the comment on the edition page" do
    url = admin_edition_url(@request.edition, anchor: dom_id(@request), host: 'example.com')
    assert_match Regexp.new(url), @mail.body.to_s
  end

  test "email body should contain the title of the edition to be checked" do
    assert_match %r{<publication-title>}, @mail.body.to_s
  end

  test "email body should contain the type of the edition to be checked" do
    assert_match %r{publication}, @mail.body.to_s
  end

  test "email body should contain unescaped instructions" do
    request = build(:fact_check_request, instructions: %{Don't escape "this" text})
    mail = Notifications.fact_check_response(request, host: "example.com")

    assert_match %r{Don't escape "this" text}, mail.body.to_s
  end

  test "email body should contain unescaped edition title" do
    publication = build(:publication, title: %{Use "double quotes" everywhere})
    request = build(:fact_check_request, edition: publication)
    mail = Notifications.fact_check_request(request, host: "example.com")

    assert_match %r{Use "double quotes" everywhere}, mail.body.to_s
  end

  test "#broken_link_reports mail includes the supplied file as an attachment" do
    file_path = file_fixture('sample_attachment.zip').path
    receiver  = 'test@gov.co.uk'
    mail      = Notifications.broken_link_reports(file_path, receiver)

    assert_equal ['test@gov.co.uk'], mail.to
    assert_equal 'GOV.UK broken link reports', mail.subject
    assert attachment = mail.attachments.first
    assert_equal 'sample_attachment.zip', attachment.filename
    assert_match %r{bad link reports}, mail.parts.first.body.to_s
  end

  test "#document_list uses the supplied file object as an attachment" do
    file = file_fixture('sample.csv').read
    receiver = 'test@gov.co.uk'
    mail = Notifications.document_list(file, receiver, "Everyone's documents")
    assert_equal 'document_list.csv', mail.attachments.first.filename
    assert_match %r{list of documents}, mail.parts.first.body.to_s
  end

  test "#document_list uses the supplied title in the mail subject" do
    file = file_fixture('sample.csv').read
    receiver = 'test@gov.co.uk'
    mail = Notifications.document_list(file, receiver, "Everyone's documents")
    assert_equal "Everyone's documents from GOV.UK", mail.subject
  end
end
