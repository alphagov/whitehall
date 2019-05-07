require 'test_helper'

class FeedHelperTest < ActionView::TestCase
  include GovspeakHelper
  # include this just so public_document_url can be stubbed later
  include PublicDocumentRoutesHelper

  def host
    Whitehall.public_host
  end

  def schema_date(_builder)
    '2005'
  end

  test '#atom_feed_url_for generates an atom feed url for a given resource that matches the public protocol and host' do
    topic = create(:topic)
    assert_equal "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/topics/#{topic.slug}.atom",
                 atom_feed_url_for(topic)

    role = create(:ministerial_role)
    assert_equal "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/ministers/#{role.slug}.atom",
                 atom_feed_url_for(role)
  end

  test 'documents_as_feed_entries exposes each document as an entry and calls document_as_feed_entry on it' do
    document_1 = Publication.new
    document_1.stubs(:id).returns(12)
    document_1.stubs(:first_public_at).returns(1.week.ago)
    document_1.stubs(:public_timestamp).returns(3.days.ago)
    document_2 = NewsArticle.new
    document_2.stubs(:id).returns(14)
    document_2.stubs(:first_public_at).returns(2.weeks.ago)
    document_2.stubs(:public_timestamp).returns(13.days.ago)
    builder = mock('builder')
    entries = sequence('entries')
    builder.stubs(:updated)
    builder.expects(:entry).with(document_2, id: "tag:#{host},2005:NewsArticle/14", url: '/news_article_url', published: 2.weeks.ago, updated: 13.days.ago).yields(builder).in_sequence(entries)
    builder.expects(:entry).with(document_1, id: "tag:#{host},2005:Publication/12", url: '/publication_url', published: 1.week.ago, updated: 3.days.ago).yields(builder).in_sequence(entries)
    feed_entry = sequence('feed_entry')
    expects(:document_as_feed_entry).with(document_2, builder).in_sequence(feed_entry)
    expects(:document_as_feed_entry).with(document_1, builder).in_sequence(feed_entry)

    stubs(:public_document_url).with(document_2).returns '/news_article_url'
    stubs(:public_document_url).with(document_1).returns '/publication_url'

    documents_as_feed_entries([document_2, document_1], builder)
  end

  test 'documents_as_feed_entries sets the updated of the builder to the supplied feed_updated_timestamp if no documents are present' do
    builder = mock('builder')
    builder.expects(:updated).with('it is time')
    documents_as_feed_entries([], builder, 'it is time')
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
    documents_as_feed_entries([d], builder, 'it is time')
  end

  test 'documents_as_feed_entries calls document_as_feed_entry' do
    document = Publication.new
    document.stubs(:id).returns(12)
    document.stubs(:public_timestamp).returns(3.days.ago)
    document.stubs(:first_public_at).returns(1.week.ago)

    builder = mock('builder')
    entries = sequence('entries')

    builder.expects(:updated).with(3.days.ago)
    stubs(:public_document_url).with(document).returns '/publication_url'
    builder.expects(:entry).with(document, id: "tag:#{host},2005:Publication/12", url: '/publication_url', published: 1.week.ago, updated: 3.days.ago).yields(builder).in_sequence(entries)
    expects(:document_as_feed_entry).with(document, builder).returns('govspoken content')
    documents_as_feed_entries([document], builder)
  end

  test 'document_as_feed_entry sets the title, category, summary, and content on the builder prefixing the title with the format_name of the document, using the govspoken version of the document as the content' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    builder = mock('builder')
    builder.expects(:title).with "#{document.display_type}: #{document.title}"
    builder.expects(:category).with(label: document.display_type, term: document.display_type)
    builder.expects(:summary).with document.summary
    expects(:govspeak_edition_to_html).with(document).returns('govspoken content')
    builder.expects(:content).with('govspoken content', type: 'html')
    document_as_feed_entry(document, builder)
  end

  test 'document_as_feed_entry converts world location news article to "News story" in title' do
    document = WorldLocationNewsArticle.new(title: 'A thing!', summary: 'summary')
    builder = mock('builder')
    builder.expects(:title).with "News story: A thing!"
    builder.stubs(:category)
    builder.stubs(:summary)
    builder.stubs(:content)
    expects(:govspeak_edition_to_html).with(document).returns('govspoken content')
    document_as_feed_entry(document, builder)
  end

  test 'entry_content returns govspoken version of document' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    expects(:govspeak_edition_to_html).with(document).returns('govspoken content')
    assert_equal 'govspoken content', entry_content(document)
  end

  test 'entry_content appends a change_note to govspoken version of a document' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    document.expects(:first_published_version?).returns(false)
    document.expects(:minor_change?).returns(false)
    document.expects(:change_note).returns('A change note')
    expects(:govspeak_edition_to_html).with(document).returns('govspoken content')
    assert_equal '<p><em>Updated:</em> A change note</p>govspoken content', entry_content(document)
  end

  test 'document_id sets ID as the original document ID when available' do
    d = Publication.new
    d.stubs(:id).returns('4')
    doc = Document.new
    doc.stubs(:id).returns('33')
    d.stubs(:document).returns(doc)

    assert_equal document_id(d, nil), "tag:#{host},2005:Publication/33"
  end

  test 'document_id sets ID as link and updated date when record is from rummager' do
    rummager_result = {
      "link": "/foo/news_story",
      "title": "PM attends summit on topical events",
      "public_timestamp": "2018-10-07T22:18:32Z",
      "display_type": "news_article",
      "description": "Description of document...",
      "content_id": "1234-C",
      "content_store_document_type": "news_article"
    }.with_indifferent_access

    document = RummagerDocumentPresenter.new(rummager_result)

    expected_date = rummager_result["public_timestamp"].to_date.rfc3339
    assert_equal "#{Whitehall.public_root}/foo/news_story##{expected_date}", document_id(document, nil)
  end
end
