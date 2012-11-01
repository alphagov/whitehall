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
end

class Whitehall::Uploader::PublicationRow::PublicationDateParserTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the date" do
    assert_equal Date.parse('2012-11-01'), Whitehall::Uploader::PublicationRow::PublicationDateParser.parse('11/01/2012', @log, @line_number)
  end

  test "can parse dates in dd-MMM-yy format" do
    assert_equal Date.parse('2012-05-23'), Whitehall::Uploader::PublicationRow::PublicationDateParser.parse('23-May-12', @log, @line_number)
  end

  test "can parse dates in dd-MMM-yyyy format" do
    assert_equal Date.parse('2013-07-10'), Whitehall::Uploader::PublicationRow::PublicationDateParser.parse('10-Jul-2013', @log, @line_number)
  end

  test "can parse dates in yyyy-mm-dd format" do
    assert_equal Date.parse('2001-10-31'), Whitehall::Uploader::PublicationRow::PublicationDateParser.parse('2001-10-31', @log, @line_number)
  end

  test "logs a warning if the date could'nt be parsed" do
    Whitehall::Uploader::PublicationRow::PublicationDateParser.parse('11/012012', @log, @line_number)
    assert_match /Unable to parse the date '11\/012012'/, @log_buffer.string
  end
end

class Whitehall::Uploader::PublicationRow::PublicationTypeFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the publication type found by the slug" do
    assert_equal PublicationType::CircularLetterOrBulletin, Whitehall::Uploader::PublicationRow::PublicationTypeFinder.find('circulars-letters-and-bulletins', @log, @line_number)
  end

  test "returns nil if the publication type can't be determined" do
    assert_nil Whitehall::Uploader::PublicationRow::PublicationTypeFinder.find('made-up-publication-type', @log, @line_number)
  end

  test "logs a warning if the publication type can't be determined" do
    Whitehall::Uploader::PublicationRow::PublicationTypeFinder.find('made-up-publication-type-slug', @log, @line_number)
    assert_match /Unable to find Publication type with slug 'made-up-publication-type-slug'/, @log_buffer.string
  end
end

class Whitehall::Uploader::PublicationRow::PoliciesFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the published edition of all documents found by the supplied slugs" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_2 = create(:published_policy, title: "Policy 2")
    assert_equal [policy_1, policy_2], Whitehall::Uploader::PublicationRow::PoliciesFinder.find(policy_1.slug, policy_2.slug, @log, @line_number)
  end

  test "returns the draft edition of any documents found by the supplied slugs which have no published editions" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_2 = create(:draft_policy, title: "Policy 2")
    assert_equal [policy_1, policy_2], Whitehall::Uploader::PublicationRow::PoliciesFinder.find(policy_1.slug, policy_2.slug, @log, @line_number)
  end

  test "returns the published edition even if a draft edition exists" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_1_draft = policy_1.create_draft(create(:user))
    assert_equal [policy_1], Whitehall::Uploader::PublicationRow::PoliciesFinder.find(policy_1.slug, @log, @line_number)
  end

  test "ignores blank slugs" do
    assert_equal [], Whitehall::Uploader::PublicationRow::PoliciesFinder.find('', '', @log, @line_number)
  end

  test "returns an empty array if a document can't be found for the given slug" do
    assert_equal [], Whitehall::Uploader::PublicationRow::PoliciesFinder.find('made-up-policy-slug', @log, @line_number)
  end

  test "logs a warning if a document can't be found for the given slug" do
    Whitehall::Uploader::PublicationRow::PoliciesFinder.find('made-up-policy-slug', @log, @line_number)
    assert_match /Unable to find Document with slug 'made-up-policy-slug'/, @log_buffer.string
  end

  test "returns an empty array if the document for the given slug that cannot be found" do
    assert_equal [], Whitehall::Uploader::PublicationRow::PoliciesFinder.find('made-up-policy-slug', @log, @line_number)
  end

  test "ignores duplicate related policies" do
    policy_1 = create(:published_policy, title: "Policy 1")
    assert_equal [policy_1], Whitehall::Uploader::PublicationRow::PoliciesFinder.find(policy_1.slug, policy_1.slug, @log, @line_number)
  end
end

class Whitehall::Uploader::PublicationRow::OrganisationFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns a single element array containing the organisation identified by name" do
    organisation = create(:organisation)
    assert_equal [organisation], Whitehall::Uploader::PublicationRow::OrganisationFinder.find(organisation.name, @log, @line_number)
  end

  test "returns a single element array containing the organisation identified by slug" do
    organisation = create(:organisation)
    assert_equal [organisation], Whitehall::Uploader::PublicationRow::OrganisationFinder.find(organisation.slug, @log, @line_number)
  end

  test "returns an empty array if the name is blank" do
    assert_equal [], Whitehall::Uploader::PublicationRow::OrganisationFinder.find('', @log, @line_number)
  end

  test "doesn't log a warning if name is blank" do
    Whitehall::Uploader::PublicationRow::OrganisationFinder.find('', @log, @line_number)
    assert_equal '', @log_buffer.string
  end

  test "returns an empty array if the organisation can't be found" do
    assert_equal [], Whitehall::Uploader::PublicationRow::OrganisationFinder.find('made-up-organisation-name', @log, @line_number)
  end

  test "logs a warning if the organisation can't be found" do
    Whitehall::Uploader::PublicationRow::OrganisationFinder.find('made-up-organisation-name', @log, @line_number)
    assert_match /Unable to find Organisation named 'made-up-organisation-name'/, @log_buffer.string
  end
end

class Whitehall::Uploader::PublicationRow::DocumentSeriesFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the document series identified by slug" do
    document_series = create(:document_series)
    assert_equal document_series, Whitehall::Uploader::PublicationRow::DocumentSeriesFinder.find(document_series.slug, @log, @line_number)
  end

  test "returns nil if the slug is blank" do
    assert_equal nil, Whitehall::Uploader::PublicationRow::DocumentSeriesFinder.find('', @log, @line_number)
  end

  test "does not add an error if the slug is blank" do
    Whitehall::Uploader::PublicationRow::DocumentSeriesFinder.find('', @log, @line_number)
    assert_equal '', @log_buffer.string
  end

  test "returns nil if the document series can't be found" do
    assert_equal nil, Whitehall::Uploader::PublicationRow::DocumentSeriesFinder.find('made-up-document-series-slug', @log, @line_number)
  end

  test "logs a warning if the document series can't be found" do
    Whitehall::Uploader::PublicationRow::DocumentSeriesFinder.find('made-up-document-series-slug', @log, @line_number)
    assert_match /Unable to find Document series with slug 'made-up-document-series-slug'/, @log_buffer.string
  end
end

class Whitehall::Uploader::PublicationRow::MinisterialRoleFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the ministerial roles occupied by the ministers identified by slug at the date specified" do
    minister = create(:person)
    role = create(:ministerial_role)
    create(:role_appointment, role: role, person: minister, started_at: 6.months.ago)
    assert_equal [role], Whitehall::Uploader::PublicationRow::MinisterialRoleFinder.find(1.month.ago, minister.slug, @log, @line_number)
  end

  test "ignores blank slugs" do
    assert_equal [], Whitehall::Uploader::PublicationRow::MinisterialRoleFinder.find(1.day.ago, '', @log, @line_number)
  end

  test "logs a warning if a person can't be found for the given slug" do
    Whitehall::Uploader::PublicationRow::MinisterialRoleFinder.find(1.day.ago, 'made-up-person-slug', @log, @line_number)
    assert_match /Unable to find Person with slug 'made-up-person-slug'/, @log_buffer.string
  end

  test "logs a warning if the person we find didn't have a role on the date specified" do
    person = create(:person)
    Whitehall::Uploader::PublicationRow::MinisterialRoleFinder.find(Date.today, person.slug, @log, @line_number)
    assert_match /Unable to find a Role for '#{person.slug}' at '#{Date.today}'/, @log_buffer.string
  end
end

class Whitehall::Uploader::PublicationRow::AttachmentDownloaderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1

    @cache = stub(:attachment_cache)
    tmp_attachment_path = Rails.root.join("test", "fixtures", "two-pages.pdf")
    @cache.stubs(:fetch).returns(File.open(tmp_attachment_path))

    @url = "http://example.com/attachment.pdf"
    stub_request(:get, @url).to_return(body: "some-data".force_encoding("ASCII-8BIT"), status: 200)
    @title = "attachment title"
  end

  test "downloads an attachment from the URL given" do
    attachment = Whitehall::Uploader::PublicationRow::AttachmentDownloader.build(@title, @url, @cache, @log, @line_number)
    assert attachment.file.present?
  end

  test "stores the attachment title" do
    attachment = Whitehall::Uploader::PublicationRow::AttachmentDownloader.build(@title, @url, @cache, @log, @line_number)
    assert_equal "attachment title", attachment.title
  end

  test "ignores rows with blank URLs" do
    assert_equal nil, Whitehall::Uploader::PublicationRow::AttachmentDownloader.build(@title, nil, @cache, @log, @line_number)
  end

  test "ignores rows with blank titles" do
    assert_equal nil, Whitehall::Uploader::PublicationRow::AttachmentDownloader.build(nil, @url, @cache, @log, @line_number)
  end

  test "stores the original URL against the attachment source" do
    attachment = Whitehall::Uploader::PublicationRow::AttachmentDownloader.build(@title, @url, @cache, @log, @line_number)
    assert_equal @url, attachment.attachment_source.url
  end

  test "logs a warning and returns nil if cache couldn't find the attachment" do
    @cache.stubs(:fetch).raises(Whitehall::Uploader::AttachmentCache::RetrievalError.new("some error to do with attachment retrieval"))
    assert_equal nil, Whitehall::Uploader::PublicationRow::AttachmentDownloader.build(@title, @url, @cache, @log, @line_number)
    assert_match /Row 1: Unable to fetch attachment .* some error to do with attachment retrieval/, @log_buffer.string
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
