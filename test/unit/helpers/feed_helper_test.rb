require 'test_helper'

class FeedHelperTest < ActionView::TestCase
  include GovspeakHelper
  test 'feed_wants_summaries_only? is false when there is no summaries_only param' do
    stubs(:params).returns({})
    refute feed_wants_summaries_only?
  end

  test 'feed_wants_summaries_only? is true when there is a summaries_only param set to "1"' do
    stubs(:params).returns({summaries_only: '1'})
    assert feed_wants_summaries_only?
  end

  test 'feed_wants_summaries_only? is true when there is a summaries_only param set to "yes"' do
    stubs(:params).returns({summaries_only: 'yes'})
    assert feed_wants_summaries_only?
  end

  test 'feed_wants_summaries_only? is true when there is a summaries_only param set to "true"' do
    stubs(:params).returns({summaries_only: 'true'})
    assert feed_wants_summaries_only?
  end

  test 'feed_wants_summaries_only? is true when there is a summaries_only param set to "on"' do
    stubs(:params).returns({summaries_only: 'on'})
    assert feed_wants_summaries_only?
  end

  test 'feed_wants_summaries_only? is false when there is a summaries_only param set to something other than "1", "yes", "true", or "on"' do
    stubs(:params).returns({summaries_only: 'monkey'})
    refute feed_wants_summaries_only?
  end

  test 'document_as_feed_entry sets the title, category, summary, and content on the builder, using the govspoken version of the document as the content when summaries_only is false' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    builder = mock('builder')
    builder.expects(:title).with document.title
    builder.expects(:category).with document.format_name.titleize
    builder.expects(:summary).with document.summary
    expects(:govspeak_edition_to_html).with(document).returns('govspoken content')
    builder.expects(:content).with('govspoken content', type: 'html')
    document_as_feed_entry(document, builder, false)
  end

  test 'document_as_feed_entry sets the title, category, summary, and content on the builder using the summary as the content when summaries_only is true' do
    document = Edition.new(title: 'A thing!', summary: 'A thing has happened')
    builder = mock('builder')
    builder.expects(:title).with document.title
    builder.expects(:category).with document.format_name.titleize
    builder.expects(:summary).with document.summary
    expects(:govspeak_edition_to_html).never
    builder.expects(:content).with(document.summary, type: 'text')
    document_as_feed_entry(document, builder, true)
  end
end
