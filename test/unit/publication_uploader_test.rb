# encoding: UTF-8

require 'test_helper'

class PublicationUploaderTest < ActiveSupport::TestCase
  setup do
    @log_buffer = StringIO.new
    @logger = Logger.new(@log_buffer)
  end

  test "should log a warning if the publication couldn't be saved" do
    uploader = PublicationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "body" => ""
      ),
      logger: @logger
    )

    uploader.upload

    assert_match /couldn't be saved for the following reasons/, @log_buffer.string
  end

  test "a minimally valid publication is created and the document_source is recorded" do
    importer = create(:user)
    csv_data = csv_sample(
      "old_url"          => "http://example.com",
      "title"            => "title",
      "summary"          => "summary",
      "body"             => "body",
      'publication_date' => '11/16/2011',
      'pub type'         => 'foi-releases'
    )
    uploader = PublicationUploader.new(
      import_as: importer,
      csv_data: csv_data,
      logger: @logger
    )

    uploader.upload

    assert publication = Publication.first
    assert_equal importer, publication.creator
    assert_equal "title", publication.title
    assert_equal "summary", publication.summary
    assert_equal "body", publication.body
    assert_equal Date.parse('2011-11-16'), publication.publication_date
    assert_equal PublicationType::FoiRelease, publication.publication_type
    assert_equal "http://example.com", publication.document.document_source.url
  end

  test "up to 3 policies specified by slug are associated with the edition" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_2 = create(:published_policy, title: "Policy 2")
    policy_3 = create(:published_policy, title: "Policy 3")
    uploader = PublicationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "policy 1" => policy_1.slug,
        "policy 2" => policy_2.slug,
        "policy 3" => policy_3.slug
      ),
      logger: @logger
    )

    uploader.upload

    assert publication = Publication.first
    assert_equal [policy_1, policy_2, policy_3], publication.related_policies
  end

  test "organisation specified by name is associated with the edition" do
    organisation = create(:organisation)
    uploader = PublicationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample("org" => organisation.name),
      logger: @logger
    )

    uploader.upload

    assert publication = Publication.first
    assert_equal [organisation], publication.organisations
  end

  test "document series specified by slug is associated with the edition" do
    document_series = create(:document_series)
    uploader = PublicationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample("doc series" => document_series.slug),
      logger: @logger
    )

    uploader.upload

    assert publication = Publication.first
    assert_equal document_series, publication.document_series
  end

  test "up to 2 ministers specified by slug are used to find the roles to associate the publication to" do
    minister_1 = create(:person)
    minister_2 = create(:person)
    role_1 = create(:ministerial_role)
    role_2 = create(:ministerial_role)
    create(:role_appointment, role: role_1, person: minister_1)
    create(:role_appointment, role: role_2, person: minister_2)
    uploader = PublicationUploader.new(
      import_as: create(:user),
      csv_data: csv_sample(
        "minister 1" => minister_1.slug,
        "minister 2" => minister_2.slug
      ),
      logger: @logger
    )

    uploader.upload

    assert publication = Publication.first
    assert_equal [role_1, role_2], publication.ministerial_roles
  end

private
  def csv_sample(additional_fields = {}, extra_rows = [])
    data = minimally_valid_row.merge(additional_fields)
    lines = []
    lines << CSV.generate_line(data.keys, encoding: "UTF-8")
    lines << CSV.generate_line(data.values, encoding: "UTF-8")
    extra_rows.each do |row|
      lines << CSV.generate_line(default_row.merge(row).values, encoding: "UTF-8")
    end
    lines.join
  end

  def minimally_valid_row
    {
      "old_url"          => "http://example.com",
      "title"            => "title",
      "summary"          => "summary",
      "body"             => "body",
      "publication_date" => "11/16/2011",
      "pub type"         => "foi-releases"
    }
  end
end

class PublicationUploaderTest::PublicationDateParserTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the date" do
    assert_equal Date.parse('2012-11-01'), PublicationUploader::PublicationDateParser.parse('11/01/2012', @log, @line_number)
  end

  test "logs a warning if the date could'nt be parsed" do
    PublicationUploader::PublicationDateParser.parse('11/012012', @log, @line_number)
    assert_match /Unable to parse the date '11\/012012'/, @log_buffer.string
  end
end

class PublicationUploaderTest::PublicationTypeFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the publication type found by the slug" do
    assert_equal PublicationType::CircularLetterOrBulletin, PublicationUploader::PublicationTypeFinder.find('circulars-letters-and-bulletins', @log, @line_number)
  end

  test "returns nil if the publication type can't be determined" do
    assert_nil PublicationUploader::PublicationTypeFinder.find('made-up-publication-type', @log, @line_number)
  end

  test "logs a warning if the publication type can't be determined" do
    PublicationUploader::PublicationTypeFinder.find('made-up-publication-type-slug', @log, @line_number)
    assert_match /Unable to find Publication type with slug 'made-up-publication-type-slug'/, @log_buffer.string
  end
end

class PublicationUploaderTest::PoliciesFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the published edition of all documents found by the supplied slugs" do
    policy_1 = create(:published_policy, title: "Policy 1")
    policy_2 = create(:published_policy, title: "Policy 1")
    assert_equal [policy_1, policy_2], PublicationUploader::PoliciesFinder.find(policy_1.slug, policy_2.slug, @log, @line_number)
  end

  test "ignores blank slugs" do
    assert_equal [], PublicationUploader::PoliciesFinder.find('', '', @log, @line_number)
  end

  test "returns an empty array if a document can't be found for the given slug" do
    assert_equal [], PublicationUploader::PoliciesFinder.find('made-up-policy-slug', @log, @line_number)
  end

  test "logs a warning if a document can't be found for the given slug" do
    PublicationUploader::PoliciesFinder.find('made-up-policy-slug', @log, @line_number)
    assert_match /Unable to find Document with slug 'made-up-policy-slug'/, @log_buffer.string
  end

  test "returns an empty array if the document for the given slug doesn't have a published edition" do
    draft_policy = create(:draft_policy)
    assert_equal [], PublicationUploader::PoliciesFinder.find(draft_policy.slug, @log, @line_number)
  end

  test "logs a warning if the document for the given slug doesn't have a published edition" do
    draft_policy = create(:draft_policy)
    PublicationUploader::PoliciesFinder.find(draft_policy.slug, @log, @line_number)
    assert_match /Unable to find a published edition for the Document with slug '#{draft_policy.slug}'/, @log_buffer.string
  end
end

class PublicationUploaderTest::OrganisationFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns a single element array containing the organisation identified by name" do
    organisation = create(:organisation)
    assert_equal [organisation], PublicationUploader::OrganisationFinder.find(organisation.name, @log, @line_number)
  end

  test "returns an empty array if the name is blank" do
    assert_equal [], PublicationUploader::OrganisationFinder.find('', @log, @line_number)
  end

  test "doesn't log a warning if name is blank" do
    PublicationUploader::OrganisationFinder.find('', @log, @line_number)
    assert_equal '', @log_buffer.string
  end

  test "returns an empty array if the organisation can't be found" do
    assert_equal [], PublicationUploader::OrganisationFinder.find('made-up-organisation-name', @log, @line_number)
  end

  test "logs a warning if the organisation can't be found" do
    PublicationUploader::OrganisationFinder.find('made-up-organisation-name', @log, @line_number)
    assert_match /Unable to find Organisation named 'made-up-organisation-name'/, @log_buffer.string
  end
end

class PublicationUploaderTest::DocumentSeriesFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the document series identified by slug" do
    document_series = create(:document_series)
    assert_equal document_series, PublicationUploader::DocumentSeriesFinder.find(document_series.slug, @log, @line_number)
  end

  test "returns nil if the slug is blank" do
    assert_equal nil, PublicationUploader::DocumentSeriesFinder.find('', @log, @line_number)
  end

  test "does not add an error if the slug is blank" do
    PublicationUploader::DocumentSeriesFinder.find('', @log, @line_number)
    assert_equal '', @log_buffer.string
  end

  test "returns nil if the document series can't be found" do
    assert_equal nil, PublicationUploader::DocumentSeriesFinder.find('made-up-document-series-slug', @log, @line_number)
  end

  test "logs a warning if the document series can't be found" do
    PublicationUploader::DocumentSeriesFinder.find('made-up-document-series-slug', @log, @line_number)
    assert_match /Unable to find Document series with slug 'made-up-document-series-slug'/, @log_buffer.string
  end
end

class PublicationUploaderTest::MinisterialRoleFinderTest < ActiveSupport::TestCase
  def setup
    @log_buffer = StringIO.new
    @log = Logger.new(@log_buffer)
    @line_number = 1
  end

  test "returns the ministerial roles occupied by the ministers identified by slug at the date specified" do
    minister = create(:person)
    role = create(:ministerial_role)
    create(:role_appointment, role: role, person: minister, started_at: 6.months.ago)
    assert_equal [role], PublicationUploader::MinisterialRoleFinder.find(1.month.ago, minister.slug, @log, @line_number)
  end

  test "ignores blank slugs" do
    assert_equal [], PublicationUploader::MinisterialRoleFinder.find(1.day.ago, '', @log, @line_number)
  end

  test "logs a warning if a person can't be found for the given slug" do
    PublicationUploader::MinisterialRoleFinder.find(1.day.ago, 'made-up-person-slug', @log, @line_number)
    assert_match /Unable to find Person with slug 'made-up-person-slug'/, @log_buffer.string
  end

  test "logs a warning if the person we find didn't have a role on the date specified" do
    person = create(:person)
    PublicationUploader::MinisterialRoleFinder.find(Date.today, person.slug, @log, @line_number)
    assert_match /Unable to find a Role for '#{person.slug}' at '#{Date.today}'/, @log_buffer.string
  end
end