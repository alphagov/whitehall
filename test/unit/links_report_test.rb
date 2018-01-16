require 'test_helper'

class LinksReportTest < ActiveSupport::TestCase
  test 'LinksReport.queue_for! queues a link report job for the specified record' do
    edition = create(:edition, body: 'Some text with a [link](http://example.com) or [two](http://link.com)')

    Sidekiq::Testing.fake! do
      links_report = LinksReport.queue_for!(edition)

      assert links_report.persisted?
      assert_equal edition, links_report.link_reportable
      assert_equal %w(http://example.com http://link.com), links_report.links

      job = LinksReportWorker.jobs.last
      assert_equal links_report.id, job['args'].first
    end
  end

  test '#completed? returns true when completed_at timestamp has been set' do
    links_report = LinksReport.new

    refute links_report.completed?

    links_report.completed_at = Time.zone.now
    assert links_report.completed?
  end
end
