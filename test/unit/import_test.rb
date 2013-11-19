require 'test_helper'
require 'support/csv_sample_helpers'

class ImportTest < ActiveSupport::TestCase
  include CsvSampleHelpers

  setup do
    @automatic_data_importer = create(:importer, name: "Automatic Data Importer")
  end

  test "valid if known type" do
    i = new_import
    assert i.valid?, i.errors.full_messages.to_s
  end

  test "invalid if unknown type" do
    refute new_import(data_type: "not_valid").valid?
  end

  test "invalid if organisation not specified" do
    refute new_import(organisation_id: nil).valid?
  end

  test "invalid if file not present" do
    refute new_import(csv_data: nil).valid?
  end

  test 'invalid if row is invalid for the given data' do
    Whitehall::Uploader::ConsultationRow.stubs(:heading_validation_errors).with(['a']).returns(["Bad stuff"])
    i = new_import(csv_data: "a\n1")
    refute i.valid?
    assert_includes i.errors[:csv_data], "Bad stuff"
  end

  test 'invalid if any row lacks an old_url' do
    i = new_import(csv_data: consultation_csv_sample("old_url" => ""))
    refute i.valid?, i.errors.full_messages.join(", ")
    assert_equal ["Row 2: old_url is blank"], i.errors[:csv_data]
  end

  test 'invalid if any an old_url is duplicated within the file' do
    i = new_import(csv_data: consultation_csv_sample({"old_url" => "http://example.com"}, [{"old_url" => "http://example.com"}]))
    refute i.valid?, i.errors.full_messages.join(", ")
    assert_equal ["Duplicate old_url 'http://example.com' in rows 2, 3"], i.errors[:csv_data]
  end

  test 'valid if a whole row is completely blank' do
    blank_row = Hash[minimally_valid_consultation_row.map {|k,v| [k,'']}]
    i = new_import(csv_data: consultation_csv_sample(blank_row))
    assert i.valid?, i.errors.full_messages.join(", ")
  end

  test "invalid if file has invalid UTF8 encoding" do
    csv_data = File.open(Rails.root.join("test/fixtures/invalid_encoding.csv"), "r:binary").read
    csv_file = stub("file", read: csv_data, original_filename: "invalid_encoding.csv")
    i = Import.create_from_file(stub_record(:user), csv_file, "consultation", organisation.id)
    refute i.valid?
    assert i.errors[:csv_data].any? {|e| e =~ /Invalid UTF-8 character encoding/}
  end

  test "accepts UTF8 byte order mark" do
    csv_data = File.open(Rails.root.join("test/fixtures/byte_order_mark_test_sample.csv"), "r:binary").read
    csv_file = stub("file", read: csv_data, original_filename: "byte_order_mark_test_sample.csv")
    i = Import.create_from_file(stub_record(:user), csv_file, "consultation", organisation.id)
    assert_equal 'old', i.csv_data[0..2]
  end

  test "doesn't raise if some headings are blank" do
    i = new_import(csv_data: "a,,b\n1,,3")
    begin
      assert i.headers
    rescue => e
      fail e
    end
  end

  test "can have multiple document sources for a given document" do
    import = create(:import)
    document = create(:document)
    document.document_sources.create(import: import, url: "http://example.com/1", row_number: 1)
    document.document_sources.create(import: import, url: "http://example.com/2", row_number: 2)
    assert_equal [document], import.documents
  end

  test "records the start time and total number of rows in the csv" do
    import = perform_import
    assert_equal 1, import.total_rows
    assert_equal Time.zone.now, import.import_started_at
  end

  test "#perform records the document source of successfully imported records" do
    example_url = 'http://example.com/1'
    import = perform_import(csv_data: consultation_csv_sample('old_url' => example_url))
    assert_equal 1, import.document_sources.where(url: example_url).count
  end

  test "#perform records multiple document sources if an imported record has multiple legacy_urls" do
    import = perform_import(csv_data: consultation_csv_sample({'old_url' => 'http://example.com/1'}, ['old_url' => 'http://example.com/2']))
    assert_equal ['http://example.com/1', 'http://example.com/2'], import.document_sources.pluck(:url)
  end

  test '#perform saves translations along with the document' do
    import = perform_import(csv_data: translated_news_article_csv, data_type: "news_article", organisation_id: organisation.id)
    assert_equal 1, import.documents.size
    assert article = import.documents.first.latest_edition

    assert article.is_a?(NewsArticle)
    assert_equal 'Title', article.title
    assert_equal 'Summary', article.summary
    assert_equal 'Body', article.body

    assert article.available_in_locale?(:es)
    translation = LocalisedModel.new(article, :es)
    assert_equal 'Spanish Title', translation.title
    assert_equal 'Spanish Summary', translation.summary
    assert_equal 'Spanish Body', translation.body
  end

  test '#perform saves the translation source, along with its locale' do
    import = perform_import(csv_data: translated_news_article_csv, data_type: "news_article", organisation_id: organisation.id)
    assert_equal 2, import.document_sources.size

    assert translation_source = import.document_sources.first
    assert_equal 'http://example.com/1.es', translation_source.url
    assert_equal 'es', translation_source.locale

    assert legacy_source = import.document_sources.last
    assert_equal 'http://example.com/1', legacy_source.url
    assert_equal 'en', legacy_source.locale
  end

  test '#perform records an error when given incomplete translation data' do
    perform_import_cleanup do
      import = perform_import(csv_data: incomplete_translated_news_article_csv, data_type: "news_article", organisation_id: organisation.id)
      assert_equal 1, import.import_errors.count
      assert_equal "Translated title: can't be blank", import.import_errors.map.first.message
    end
  end

  test '#perform records an error when translation data is present without a locale' do
    perform_import_cleanup do
      import = perform_import(csv_data: translated_news_article_with_missing_locale_csv, data_type: "news_article", organisation_id: organisation.id)
      assert_equal 1 ,import.import_errors.count
      assert_match /Locale not recognised/, import.import_errors.map.first.message
    end
  end

  test '#perform assigns topics to the document' do
    topic = create(:topic)
    data = publication_csv_sample('topic_1' => topic.slug)

    import = perform_import(csv_data: data, data_type: 'publication', organisation_id: organisation.id)
    edition = import.imported_editions.first

    assert_equal [topic], edition.topics
  end

  test '#perform assigns document collection to the document' do
    collection = create(:document_collection, title: 'collection-name')
    import = perform_import(csv_data: publication_with_collection_csv, data_type: "publication", organisation_id: create(:organisation).id)
    edition = import.imported_editions.first

    assert_equal [collection], edition.document.document_collections
  end

  test '#perform rolls back if exception raised during the row import' do
    import = perform_import(csv_data: publication_with_dud_collection_csv, data_type: "publication", organisation_id: create(:organisation).id)
    assert_equal [], import.imported_editions
  end

  test "#peform creates editions in the imported state" do
    perform_import
    assert_equal Edition.count, Edition.imported.count
  end

  test "document version history is recorded in the name of the automatic data importer" do
    i = perform_import
    e = i.document_sources.map {|ds| ds.document.editions}.flatten.first
    assert_equal [@automatic_data_importer], e.authors
    assert_equal @automatic_data_importer.id, e.versions.first.whodunnit.to_i
  end

  test "#perform records an error if a document has already been imported" do
    perform_import(csv_data: consultation_csv_sample({'old_url' => 'http://example.com/1'}))

    import = perform_import(csv_data: consultation_csv_sample({'old_url' => 'http://example.com/1'}))
    assert_equal 1, import.import_errors.count
    assert_match /already imported/, import.import_errors.map(&:message).first
  end

  test "#perform records an error if any old url of a row has already been imported" do
    perform_import(csv_data: consultation_csv_sample({'old_url' => 'http://example.com/2'}))
    i = perform_import(csv_data: consultation_csv_sample("old_url" => ["http://example.com/1", "http://example.com/2"].to_json))
    assert_equal 1, i.import_errors.count
    assert_match /already imported/, i.import_errors.map(&:message).first
    assert_match %r{http://example\.com/2}, i.import_errors.map(&:message).first
  end

  test "#perform skips blank rows" do
    blank_row = Hash[minimally_valid_consultation_row.map {|k,v| [k,'']}]

    perform_import_cleanup do
      i = perform_import(csv_data: consultation_csv_sample({}, [blank_row]))
      assert_equal [], i.import_errors
      assert_equal 1, i.document_sources.count
      assert_match /blank, skipped/, i.log
    end
  end

  test 'logs failure if save unsuccessful' do
    perform_import_cleanup do
      import = perform_import(csv_data: consultation_csv_sample('body' => nil))
      assert import.import_errors.detect {|e| e[:message] =~ /body: can't be blank/}
    end
  end

  test 'logs failure if unable to parse a date' do
    i = perform_import(csv_data: consultation_csv_sample("opening_date" => "31/10/2012"))
    assert i.import_errors.detect {|e| e[:message] =~ /Unable to parse the date/}
  end

  test 'logs failure if unable to find an organisation' do
    i = perform_import(csv_data: consultation_csv_sample("organisation" => "does-not-exist"))
    assert i.import_errors.detect {|e| e[:message] =~ /Unable to find Organisation/}
  end

  test 'logs failures within attachments if save unsuccessful' do
    csv_with_invalid_attachment = consultation_csv_sample("attachment_1_url" => "bad url", "attachment_1_title" => "")
    perform_import_cleanup do
      i = perform_import(csv_data: csv_with_invalid_attachment)
      assert i.import_errors.any? {|e| e[:message] =~ /Unable to fetch attachment 'bad url'/}
    end
  end

  test 'successful rows are imported and failed rows are skipped' do
    two_rows = consultation_csv_sample(
      {"old_url" => "http://example.com/valid"},
      [
        {'title' => '', 'old_url' => 'http://example.com/invalid'}
      ]
    )
    perform_import_cleanup do
      i = perform_import(csv_data: two_rows)
      assert_equal 1, Import.count, "Import wasn't saved correctly"

      assert_includes Consultation.all.map {|c| c.document.document_sources.map(&:url) }.flatten, "http://example.com/valid"
      refute_includes Consultation.all.map {|c| c.document.document_sources.map(&:url) }.flatten, "http://example.com/invalid"
    end
  end

  test 'once run, it has access to the editions that it created via imported_editions' do
    import = perform_import
    assert_equal [Consultation.find_by_title('title')], import.imported_editions.all
  end

  test 'imported_editions lists each imported edition once even when there are multiple document sources per edition' do
    title = 'my consultation'
    csv_data = consultation_csv_sample(
      'title' => title,
      'old_url' => '["http://example.com/1","http://example.com/2"]'
    )
    import = perform_import(csv_data: csv_data)
    assert_equal [Consultation.find_by_title(title)], import.imported_editions.all
  end

  test 'force_publishable_edition_count counts each imported edition once even when there are multiple document sources per edition' do
    title = 'my consultation'
    csv_data = consultation_csv_sample(
      'title' => title,
      'old_url' => '["http://example.com/1","http://example.com/2"]'
    )
    import = perform_import(csv_data: csv_data)
    consultation = Consultation.find_by_title(title)
    consultation.convert_to_draft!
    assert_equal 1, import.force_publishable_edition_count
  end

  test 'if an imported edition is published and re-drafted, imported_editions only contains the original, not the re-draft' do
    import = perform_import
    edition = Consultation.find_by_title('title')
    editor = create(:departmental_editor)
    edition.convert_to_draft!
    force_publish(edition)
    new_draft = edition.create_draft(editor)
    refute import.imported_editions.include?(new_draft)
  end

  test 'force_publishable_editions contains only editions from imported_editions that are draft or submitted' do
    import = perform_import
    edition = Consultation.find_by_title('title')
    refute import.force_publishable_editions.include?(edition)

    edition.convert_to_draft!
    assert import.force_publishable_editions.include?(edition)

    force_publish(edition)
    refute import.force_publishable_editions.include?(edition)

    new_draft = edition.create_draft(create(:departmental_editor))
    refute import.force_publishable_editions.include?(edition)
  end

  test 'it is not force_publishable? if it succeeded but imported no editions' do
    blank_row = Hash[minimally_valid_consultation_row.map {|k,v| [k,'']}]
    import = perform_import(csv_data: consultation_csv_sample(blank_row))
    refute import.force_publishable?
  end

  test 'it is not force_publishable? if it didn\'t succeed' do
    import = perform_import(csv_data: consultation_csv_sample('title' => ''))
    refute import.force_publishable?
  end

  test 'it is considered force_publishable? if it has succeeded, imported some editions, none of them are imported, and some of them are draft or submitted' do
    import = perform_import
    refute import.force_publishable?
    import.imported_editions.map { |e| e.convert_to_draft! }
    assert import.force_publishable?
    import.imported_editions.map { |e| e.submit! }
    assert import.force_publishable?
    import.imported_editions.map { |e| force_publish(e) }
    refute import.force_publishable?
  end

  test 'it is considered force_publishable? if it has succeeded, and has not already attempted a force publish' do
    import = perform_import
    refute import.force_publishable?
    import.imported_editions.map { |e| e.convert_to_draft! }
    import.force_publication_attempts.clear
    assert import.force_publishable?
  end

  test 'it is considered force_publishable? if it has succeeded, and the most recent force publication attempt is not in play' do
    import = perform_import
    refute import.force_publishable?
    import.imported_editions.map { |e| e.convert_to_draft! }

    # not "in play" if it's new...
    fpa = import.force_publication_attempts.create
    refute import.force_publishable?

    # ... or enqueued ...
    fpa.update_column(:enqueued_at, 1.day.ago)
    refute import.force_publishable?

    # ... or started ...
    fpa.update_column(:started_at, 1.day.ago)
    refute import.force_publishable?

    # ... but it is if it's finished successfully...
    fpa.update_column(:finished_at, 1.day.ago)
    fpa.update_column(:total_documents, 1)
    fpa.update_column(:successful_documents, 1)
    assert import.force_publishable?

    # ... or with failures.
    fpa.update_column(:successful_documents, 0)
    assert import.force_publishable?
  end

  test 'force_publish! will create and enqueue a new ForcePublicationAttempt' do
    import = perform_import
    import.imported_editions.map { |e| e.convert_to_draft! }

    import.force_publish!
    attempt = import.force_publication_attempts.first
    assert_not_nil attempt
    assert_equal Time.zone.now, attempt.enqueued_at
  end

  test 'most_recent_force_publication_attempt is the last created ForcePublicationAttempt' do
    import = perform_import
    import.imported_editions.map { |e| e.convert_to_draft! }

    import.force_publish!
    attempt1 = import.force_publication_attempts.first
    import.force_publish!
    attempt2 = import.force_publication_attempts.last
    import.force_publish!
    attempt3 = import.force_publication_attempts.last

    assert_equal attempt3, import.most_recent_force_publication_attempt
  end

  test "#destroy also destroys all imported documents" do
    import = perform_import
    documents = import.documents
    import.destroy
    documents.each do |imported_doc|
      assert_equal nil, Document.find_by_id(imported_doc.id)
    end
  end

  test "#destroy also destroys the import logs" do
    import = perform_import
    logs = import.import_logs
    import.destroy
    logs.each do |import_log|
      assert_equal nil, ImportLog.find_by_id(import_log.id)
    end
  end

  test "#destroy also destroys the import errors" do
    import = perform_import
    import_error = import.import_errors.create!(row_number: 1, message: 'uh oh')
    import.destroy
    assert_equal nil, ImportError.find_by_id(import_error.id)
  end

  test "#destroy also destroys force publication attempts" do
    import = perform_import
    force_attempt = import.force_publication_attempts.create!
    import.destroy
    assert_equal nil, ForcePublicationAttempt.find_by_id(force_attempt.id)
  end

  private

  def organisation
    @organisation ||= create(:organisation)
  end

  def new_import(params = {})
    valid_params = {
      csv_data: consultation_csv_sample,
      data_type: "consultation",
      organisation_id: organisation.id,
      creator: stub_record(:user)
    }

    Import.new(valid_params.merge(params))
  end

  def perform_import(params = {})
    new_import(params).tap do |import|
      import.save!
      import.update_column(:import_enqueued_at, Time.current)
      import.perform
    end
  end

  def perform_import_cleanup(&block)
    Import.use_separate_connection
    yield
  ensure
    Import.destroy_all
    ImportError.destroy_all
    ImportLog.destroy_all
  end

  def translated_news_article_csv
    <<-EOF.strip_heredoc
    old_url,title,summary,body,organisation,policy_1,minister_1,first_published,country_1,news_article_type,locale,translation_url,title_translation,summary_translation,body_translation
    http://example.com/1,Title,Summary,Body,,,,14-Dec-2011,,,es,http://example.com/1.es,Spanish Title,Spanish Summary,Spanish Body
    EOF
  end

  def translated_news_article_with_missing_locale_csv
    <<-EOF.strip_heredoc
    old_url,title,summary,body,organisation,policy_1,minister_1,first_published,country_1,news_article_type,locale,translation_url,title_translation,summary_translation,body_translation
    http://example.com/1,Title,Summary,Body,,,,14-Dec-2011,,,,http://example.com/1.es,Spanish Title,Spanish Summary,Spanish Body
    EOF
  end

  def incomplete_translated_news_article_csv
    <<-EOF.strip_heredoc
    old_url,title,summary,body,organisation,policy_1,minister_1,first_published,country_1,news_article_type,locale,translation_url,title_translation,summary_translation,body_translation
    http://example.com/1,Title,Summary,Body,,,,14-Dec-2011,,,es,http://example.com/1.es,,Spanish Summary,Spanish Body
    EOF
  end

  def publication_with_collection_csv
    <<-EOF.strip_heredoc
    old_url,title,summary,body,publication_type,policy_1,policy_2,document_collection_1,organisation,publication_date,ignore_date,isbn,urn,command_paper_number,ignore_i
    http://example.com/3,Title,Summary,Body,correspondence,,,collection-name,,19-Oct-2012,2012-10-19,,,,175
    EOF
  end

  def publication_with_dud_collection_csv
    <<-EOF.strip_heredoc
    old_url,title,summary,body,publication_type,policy_1,policy_2,document_collection_1,organisation,publication_date,ignore_date,isbn,urn,command_paper_number,ignore_i
    http://example.com/3,Title,Summary,Body,correspondence,,,collection-name-dud,,19-Oct-2012,2012-10-19,,,,175
    EOF
  end
end
