# encoding: UTF-8

require 'test_helper'

class Whitehall::Uploader::PublicationRowTest < ActiveSupport::TestCase
  setup do
    @attachment_cache = stub('attachment cache')
  end

  test "takes title from the title column" do
    row = Whitehall::Uploader::PublicationRow.new({"title" => "a-title"}, 1, @attachment_cache)
    assert_equal "a-title", row.title
  end

  test "takes summary from the summary column" do
    row = Whitehall::Uploader::PublicationRow.new({"summary" => "a-summary"}, 1, @attachment_cache)
    assert_equal "a-summary", row.summary
  end

  test "takes body from the body column" do
    row = Whitehall::Uploader::PublicationRow.new({"body" => "Some body goes here"}, 1, @attachment_cache)
    assert_equal "Some body goes here", row.body
  end

  test "takes legacy url from the old_url column" do
    row = Whitehall::Uploader::PublicationRow.new({"old_url" => "http://example.com/old-url"}, 1, @attachment_cache)
    assert_equal "http://example.com/old-url", row.legacy_url
  end

  test "finds document series by slug in doc_series column" do
    document_series = create(:document_series)
    row = Whitehall::Uploader::PublicationRow.new({"document_series" => document_series.slug}, 1, @attachment_cache)
    assert_equal document_series, row.document_series
  end

  test "finds publication type by slug in the pub type column" do
    row = Whitehall::Uploader::PublicationRow.new({"publication_type" => "guidance"}, 1, @attachment_cache)
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
      "minister_1" => minister_1.slug,
      "minister_2" => minister_2.slug,
      "publication_date" => "11/16/2011"
    }, 1, @attachment_cache)
    assert_equal [role_1, role_2], row.ministerial_roles
  end

  test "finds up to 4 policies specified by slug in columns policy_1, policy_2, policy_3 and policy_4" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_2 = create(:published_policy, title: "Policy 2")
    policy_3 = create(:published_policy, title: "Policy 3")
    policy_4 = create(:published_policy, title: "Policy 4")
    row = Whitehall::Uploader::PublicationRow.new({"policy_1" => policy_1.slug,
      "policy_2" => policy_2.slug,
      "policy_3" => policy_3.slug,
      "policy_4" => policy_4.slug
    }, 1, @attachment_cache)

    assert_equal [policy_1, policy_2, policy_3, policy_4], row.related_policies
  end

  test "finds organisation by name in org column" do
    organisation = create(:organisation)
    row = Whitehall::Uploader::PublicationRow.new({"organisation" => organisation.name}, 1, @attachment_cache)
    assert_equal [organisation], row.organisations
  end

  test "finds up to 42 attachments in columns attachment 1 title, attachement 1 url..." do
    @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf").returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

    row = Whitehall::Uploader::PublicationRow.new({
      "attachment_1_title" => "first title",
      "attachment_1_url" => "http://example.com/attachment.pdf"
    }, 1, @attachment_cache, Logger.new(StringIO.new))

    attachment = Attachment.new(title: "first title")
    assert_equal [attachment.attributes], row.attachments.collect(&:attributes)
    assert_equal "http://example.com/attachment.pdf", row.attachments.first.attachment_source.url
  end

  test "finds any attachments specified in JSON in the json_attachments column" do
    @attachment_cache.stubs(:fetch).with("http://example.com/attachment.pdf").returns(File.open(Rails.root.join("test", "fixtures", "two-pages.pdf")))

    row = Whitehall::Uploader::PublicationRow.new({
      "json_attachments" => ActiveSupport::JSON.encode([{"title" => "first title", "url" => "http://example.com/attachment.pdf"}])
    }, 1, @attachment_cache, Logger.new(StringIO.new))

    attachment = Attachment.new(title: "first title")
    assert_equal [attachment.attributes], row.attachments.collect(&:attributes)
    assert_equal "http://example.com/attachment.pdf", row.attachments.first.attachment_source.url
  end
end

class Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilderTest < ActiveSupport::TestCase
  def setup
    @attachment = stub_everything('attachment')
  end

  test "does nothing if there are no attachments" do
    Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilder.build(nil, "order-url", "isbn", "urn", "command-paper-number")
  end

  test "does nothing if no attributes are set" do
    Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilder.build(@attachment, nil, nil, nil, nil)
  end

  test "sets all attributes if given" do
    @attachment.expects(:order_url=).with("order-url")
    @attachment.expects(:isbn=).with("ISBN")
    @attachment.expects(:unique_reference=).with("unique-reference")
    @attachment.expects(:command_paper_number=).with("command-paper-number")
    Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilder.build(@attachment, "order-url", "ISBN", "unique-reference", "command-paper-number")
  end

  test "sets any subset of attributes that are given" do
    @attachment.expects(:isbn=).with("ISBN")
    @attachment.expects(:command_paper_number=).with("command-paper-number")
    Whitehall::Uploader::PublicationRow::AttachmentMetadataBuilder.build(@attachment, nil, "ISBN", nil, "command-paper-number")
  end
end
