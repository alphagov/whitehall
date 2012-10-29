# encoding: UTF-8

require 'test_helper'

class Whitehall::Uploader::PublicationRowTest < ActiveSupport::TestCase
  test "takes title from the title column" do
    row = Whitehall::Uploader::PublicationRow.new({"title" => "a-title"}, 1)
    assert_equal "a-title", row.title
  end

  test "takes summary from the summary column" do
    row = Whitehall::Uploader::PublicationRow.new({"summary" => "a-summary"}, 1)
    assert_equal "a-summary", row.summary
  end

  test "takes body from the body column" do
    row = Whitehall::Uploader::PublicationRow.new({"body" => "Some body goes here"}, 1)
    assert_equal "Some body goes here", row.body
  end

  test "takes legacy url from the old_url column" do
    row = Whitehall::Uploader::PublicationRow.new({"old_url" => "http://example.com/old-url"}, 1)
    assert_equal "http://example.com/old-url", row.legacy_url
  end

  test "finds document series by slug in doc_series column" do
    document_series = create(:document_series)
    row = Whitehall::Uploader::PublicationRow.new({"doc series" => document_series.slug}, 1)
    assert_equal document_series, row.document_series
  end

  test "finds publication type by slug in the pub type column" do
    row = Whitehall::Uploader::PublicationRow.new({"pub type" => "guidance"}, 1)
    assert_equal PublicationType::Guidance, row.publication_type
  end

  test "finds ministers specified by slug in minister 1 and minister 2 columns" do
    minister_1 = create(:person)
    minister_2 = create(:person)
    role_1 = create(:ministerial_role)
    role_2 = create(:ministerial_role)
    create(:role_appointment, role: role_1, person: minister_1)
    create(:role_appointment, role: role_2, person: minister_2)
    row = Whitehall::Uploader::PublicationRow.new({
      "minister 1" => minister_1.slug,
      "minister 2" => minister_2.slug,
      "publication_date" => "11/16/2011"
    }, 1)
    assert_equal [role_1, role_2], row.ministerial_roles
  end

  test "finds up to 3 policies specified by slug in columns policy 1, policy 2 and policy 3" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_2 = create(:published_policy, title: "Policy 2")
    policy_3 = create(:published_policy, title: "Policy 3")
    row = Whitehall::Uploader::PublicationRow.new({"policy 1" => policy_1.slug,
      "policy 2" => policy_2.slug,
      "policy 3" => policy_3.slug
    }, 1)

    assert_equal [policy_1, policy_2, policy_3], row.related_policies
  end

  test "finds organisation by name in org column" do
    organisation = create(:organisation)
    row = Whitehall::Uploader::PublicationRow.new({"org" => organisation.name}, 1)
    assert_equal [organisation], row.organisations
  end

  test "finds up to 42 attachments in columns attachment 1 title, attachement 1 url..." do
    row = Whitehall::Uploader::PublicationRow.new({
      "attachment 1 title" => "first title",
      "attachment 1 url" => "http://example.com/attachment.pdf"
    }, 1)

    attachment = Attachment.new(title: "first title")
    assert_equal [attachment.attributes], row.attachments.collect(&:attributes)
    assert_equal "http://example.com/attachment.pdf", row.attachments.first.attachment_source.url
  end
end