require 'test_helper'

class BadLinkReporterTest < ActiveSupport::TestCase
  teardown do
    FileUtils.rm Dir.glob(reports_dir.join('*_bad_links.csv'))
  end

  test 'generates CSV reports for bad links grouped by lead organisation' do
    stub_request(:any, 'https://www.gov.uk/good-link').to_return(status: 200)
    stub_request(:any, 'https://www.gov.uk/another-good-link').to_return(status: 200)
    stub_request(:any, 'https://www.gov.uk/bad-link').to_return(status: 500)
    stub_request(:any, 'https://www.gov.uk/missing-link').to_return(status: 404)

    hmrc = create(:organisation, name: 'HM Revenue & Customs')
    embassy_paris = create(:worldwide_organisation, name: 'British Embassy Paris')

    publication    = create(:publication, lead_organisations: [hmrc], id: '99999997')
    news_article   = create(:world_location_news_article, worldwide_organisations: [embassy_paris], id: '99999998')
    detailed_guide = create(:detailed_guide, lead_organisations: [hmrc], id: '99999999')

    Dir.mkdir(reports_dir) unless File.directory?(reports_dir)
    Whitehall::BadLinkReporter.new(mirror_dir.to_s, reports_dir.to_s).generate_reports

    embassy_csv = CSV.read(reports_dir.join('british-embassy-paris_bad_links.csv'))
    assert_equal 2, embassy_csv.size
    assert_equal ['page', 'admin link', 'format', 'bad link count', 'bad links'], embassy_csv[0]
    assert_equal ['https://www.gov.uk/news',
                  'https://whitehall-admin.production.alphagov.co.uk/government/admin/world-location-news/99999998',
                  'WorldLocationNewsArticle',
                  '1',
                  'https://www.gov.uk/missing-link'], embassy_csv[1]

    hmrc_csv = CSV.read(reports_dir.join('hm-revenue-customs_bad_links.csv'))
    assert_equal 3, hmrc_csv.size
    assert_equal ['page', 'admin link', 'format', 'bad link count', 'bad links'], hmrc_csv[0]
    assert_equal ['https://www.gov.uk/detailed_guide',
                  'https://whitehall-admin.production.alphagov.co.uk/government/admin/detailed-guides/99999999',
                  'DetailedGuide',
                  '2',
                  "https://www.gov.uk/bad-link\r\nhttps://www.gov.uk/missing-link"], hmrc_csv[1]
    assert_equal ['https://www.gov.uk/publication',
                  'https://whitehall-admin.production.alphagov.co.uk/government/admin/publications/99999997',
                  'Publication',
                  '1',
                  "https://www.gov.uk/bad-link"], hmrc_csv[2]
  end

private

  def mirror_dir
    Rails.root.join('test/fixtures/mirror')
  end

  def reports_dir
    Rails.root.join('tmp/bad_link_reports')
  end
end
