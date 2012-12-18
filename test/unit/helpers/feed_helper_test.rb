require 'test_helper'

class FeedHelperTest < ActionView::TestCase
  include GovspeakHelper
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

  test 'document_as_feed_entry sets the title, category, summary, and content on the builder, using the govspoken version of the document as the content when govdelivery_version is false' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    builder = mock('builder')
    builder.expects(:title).with document.title
    builder.expects(:category).with document.format_name.titleize
    builder.expects(:summary).with document.summary
    expects(:govspeak_edition_to_html).with(document).returns('govspoken content')
    builder.expects(:content).with('govspoken content', type: 'html')
    document_as_feed_entry(document, builder, false)
  end

  test 'document_as_feed_entry sets the title, category, summary, and content on the builder using the summary as the content when govdelivery_version is true' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    builder = mock('builder')
    builder.expects(:title)
    builder.expects(:category).with document.format_name.titleize
    builder.expects(:summary).with document.summary
    expects(:govspeak_edition_to_html).never
    builder.expects(:content).with(document.summary, type: 'text')
    document_as_feed_entry(document, builder, true)
  end

  test 'document_as_feed_entry sets the title, category, summary, and content on the builder prefixing the title with the format_name of the document when govdelivery_version is true' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    builder = mock('builder')
    builder.expects(:title).with "#{document.format_name.titleize}: #{document.title}"
    builder.expects(:category).with document.format_name.titleize
    builder.expects(:summary).with document.summary
    builder.expects(:content)
    document_as_feed_entry(document, builder, true)
  end
end
