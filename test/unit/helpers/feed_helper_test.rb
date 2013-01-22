require 'test_helper'

class FeedHelperTest < ActionView::TestCase
  include GovspeakHelper
  # include this just so public_document_url can be stubbed later
  include PublicDocumentRoutesHelper

  def host
    "test.dev.gov.uk"
  end

  def schema_date(_)
    '2005'
  end

  test 'feed_wants_govdelivery_version? is false when there is no govdelivery_version param' do
    stubs(:params).returns({})
    refute feed_wants_govdelivery_version?
  end

  test 'feed_wants_govdelivery_version? is true when there is a govdelivery_version param set to "1"' do
    stubs(:params).returns({govdelivery_version: '1'})
    assert feed_wants_govdelivery_version?
  end

  test 'feed_wants_govdelivery_version? is true when there is a govdelivery_version param set to "yes"' do
    stubs(:params).returns({govdelivery_version: 'yes'})
    assert feed_wants_govdelivery_version?
  end

  test 'feed_wants_govdelivery_version? is true when there is a govdelivery_version param set to "true"' do
    stubs(:params).returns({govdelivery_version: 'true'})
    assert feed_wants_govdelivery_version?
  end

  test 'feed_wants_govdelivery_version? is true when there is a govdelivery_version param set to "on"' do
    stubs(:params).returns({govdelivery_version: 'on'})
    assert feed_wants_govdelivery_version?
  end

  test 'feed_wants_govdelivery_version? is false when there is a govdelivery_version param set to something other than "1", "yes", "true", or "on"' do
    stubs(:params).returns({govdelivery_version: 'monkey'})
    refute feed_wants_govdelivery_version?
  end

  test 'documents_as_feed_entries exposes each document as an entry and calls document_as_feed_entry on it' do
    d1 = Publication.new
    d1.stubs(:id).returns(12)
    d1.stubs(:first_public_at).returns(1.week.ago)
    d1.stubs(:public_timestamp).returns(3.days.ago)
    d2 = Policy.new
    d2.stubs(:id).returns(14)
    d2.stubs(:first_public_at).returns(2.weeks.ago)
    d2.stubs(:public_timestamp).returns(13.days.ago)
    builder = mock('builder')
    entries = sequence('entries')
    builder.stubs(:updated)
    builder.expects(:entry).with(d2, id: 'tag:test.dev.gov.uk,2005:Policy/14', url: '/policy_url', published: 2.weeks.ago, updated: 13.days.ago).yields(builder).in_sequence(entries)
    builder.expects(:entry).with(d1, id: 'tag:test.dev.gov.uk,2005:Publication/12', url: '/publication_url', published: 1.week.ago, updated: 3.days.ago).yields(builder).in_sequence(entries)
    feed_entry = sequence('feed_entry')
    expects(:document_as_feed_entry).with(d2, builder, false).in_sequence(feed_entry)
    expects(:document_as_feed_entry).with(d1, builder, false).in_sequence(feed_entry)

    stubs(:public_document_url).with(d2).returns '/policy_url'
    stubs(:public_document_url).with(d1).returns '/publication_url'

    documents_as_feed_entries([d2,d1], builder, false)
  end

  test 'documents_as_feed_entries sets the updated of the builder to the supplied feed_updated_timestamp if no documents are present' do
    builder = mock('builder')
    builder.expects(:updated).with('it is time')
    documents_as_feed_entries([], builder, false, 'it is time')
  end

  test 'documents_as_feed_entries sets the updated of the builder to the public_timestamp of the first supplied document' do
    d = Publication.new
    d.stubs(:id).returns(12)
    d.stubs(:public_timestamp).returns(3.days.ago)
    d.stubs(:first_public_at).returns(1.week.ago)

    builder = mock('builder')
    builder.expects(:updated).with(3.days.ago)
    builder.stubs(:entry)
    stubs(:public_document_url)
    documents_as_feed_entries([d], builder, false, 'it is time')
  end

  test 'document_as_feed_entry sets the title, category, summary, and content on the builder prefixing the title with the format_name of the document, using the govspoken version of the document as the content when govdelivery_version is false' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    builder = mock('builder')
    builder.expects(:title).with "#{document.display_type}: #{document.title}"
    builder.expects(:category).with( label:  document.display_type, term: document.display_type )
    builder.expects(:summary).with document.summary
    expects(:govspeak_edition_to_html).with(document).returns('govspoken content')
    builder.expects(:content).with('govspoken content', type: 'html')
    document_as_feed_entry(document, builder, false)
  end

  test 'document_as_feed_entry sets the title, category, summary, and content on the builder using the summary as the content when govdelivery_version is true' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    builder = mock('builder')
    builder.stubs(:title)
    builder.expects(:category).with( label:  document.display_type, term: document.display_type )
    builder.expects(:summary).with document.summary
    expects(:govspeak_edition_to_html).never
    builder.expects(:content).with("<p>#{document.summary}</p>", type: 'html')
    document_as_feed_entry(document, builder, true)
  end

  test 'document_as_feed_entry sets the title, category, summary, and content on the builder prefixing the title with the format_name of the document when govdelivery_version is true' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    builder = mock('builder')
    builder.expects(:title).with "#{document.display_type}: #{document.title}"
    builder.stubs(:category)
    builder.stubs(:summary)
    builder.stubs(:content)
    document_as_feed_entry(document, builder, true)
  end

  test 'entry_content returns govspoken version of document when govdelivery_version is false' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    expects(:govspeak_edition_to_html).with(document).returns('govspoken content')
    assert_equal 'govspoken content', entry_content(document)
  end

  test 'entry_content returns summary wrapped in a paragraph when govdelivery_version is true' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    expects(:govspeak_edition_to_html).never
    assert_equal '<p>A thing has happened</p>', entry_content(document, true)
  end

  test 'entry_content appends a change_note to govspoken version of a document when govdelivery_version is false' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    document.expects(:first_published_version?).returns(false)
    document.expects(:minor_change?).returns(false)
    document.expects(:change_note).returns('A change note')
    expects(:govspeak_edition_to_html).with(document).returns('govspoken content')
    assert_equal '<p><em>Updated:</em> A change note</p>govspoken content', entry_content(document)
  end

  test 'entry_content appends a change_note to govspoken version of a document when govdelivery_version is true' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    document.expects(:first_published_version?).returns(false)
    document.expects(:minor_change?).returns(false)
    document.expects(:change_note).returns('A change note')
    expects(:govspeak_edition_to_html).never
    assert_equal '<p><em>Updated:</em> A change note</p><p>A thing has happened</p>', entry_content(document, true)
  end

  test 'document_id sets ID as the original document ID when available' do
    d = Publication.new
    d.stubs(:id).returns('4')
    doc = Document.new
    doc.stubs(:id).returns('33')
    d.stubs(:document).returns(doc)

    assert_equal document_id(d, nil), 'tag:test.dev.gov.uk,2005:Publication/33'
  end
end
