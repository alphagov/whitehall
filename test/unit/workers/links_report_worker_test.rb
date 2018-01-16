require 'test_helper'

class LinksReportWorkerTest < ActiveSupport::TestCase
  test '#perform checks links and updates the report with the results' do
    links_report = create(:links_report, links: %w(good_link bad_link))


    stub_request(:get, 'good_link').to_return(status: 200)
    stub_request(:get, 'bad_link').to_return(status: 404)

    LinksReportWorker.new.perform(links_report.id)

    assert links_report.reload.completed?
    assert_equal ['bad_link'], links_report.broken_links
  end
end
