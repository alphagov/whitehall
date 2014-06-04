require 'test_helper'

class LinksReportTest < ActiveSupport::TestCase
  test 'LinksReport.from_record returns a link report for the specified record' do
    edition = create(:edition, body: 'Some text with a [link](http://example.com) or [two](http://link.com)')
    links_report = LinksReport.from_record(edition)

    assert links_report.persisted?
    assert_equal edition, links_report.link_reportable
    assert_equal %w(http://example.com http://link.com), links_report.links
  end

  test '#completed? returns true when completed_at timestamp has been set' do
    links_report = LinksReport.new

    refute links_report.completed?

    links_report.completed_at = Time.zone.now
    assert links_report.completed?
  end
end
