require 'test_helper'

class BrokenLinkReporterTest < ActiveSupport::TestCase

  teardown do
    if File.directory?(reports_dir)
      FileUtils.rm Dir.glob(reports_dir.join('*_broken_links.csv'))
    end
  end

  test 'generates CSV reports detailing broken links on public documents grouped by lead organisation' do
    stub_request(:any, 'https://www.gov.uk/good-link').to_return(status: 200)
    stub_request(:any, 'https://www.gov.uk/another-good-link').to_return(status: 200)
    stub_request(:any, 'https://www.gov.uk/bad-link').to_return(status: 500)
    stub_request(:any, 'https://www.gov.uk/missing-link').to_return(status: 404)

    hmrc = create(:organisation, name: 'HM Revenue & Customs')
    embassy_paris = create(:worldwide_organisation, name: 'British Embassy Paris')

    publication    = create(:published_publication,
                            lead_organisations: [hmrc],
                            body: "[A broken page](https://www.gov.uk/bad-link)\n[A good link](https://www.gov.uk/another-good-link)")

    news_article   = create(:world_location_news_article,
                            :withdrawn,
                            worldwide_organisations: [embassy_paris],
                            body: "[Good link](https://www.gov.uk/good-link)\n[Missing page](https://www.gov.uk/missing-link)")

    detailed_guide = create(:published_detailed_guide,
                            lead_organisations: [hmrc],
                            body: "[Good](https://www.gov.uk/good-link)\n[broken link](https://www.gov.uk/bad-link)\n[Missing page](https://www.gov.uk/missing-link)")
    draft_document = create(:draft_publication,
                            lead_organisations: [hmrc],
                            body: "[Missing page](https://www.gov.uk/missing-link)")

    Dir.mkdir(reports_dir) unless File.directory?(reports_dir)
    Whitehall::BrokenLinkReporter.new(reports_dir.to_s, NullLogger.instance).generate_reports

    embassy_csv = CSV.read(reports_dir.join('british-embassy-paris_broken_links.csv'))
    assert_equal 2, embassy_csv.size
    assert_equal ['page', 'admin link', 'public timestamp', 'format', 'broken link count', 'broken links'], embassy_csv[0]
    assert_equal ["https://www.gov.uk#{Whitehall.url_maker.world_location_news_article_path(news_article.slug)}",
                  "https://whitehall-admin.publishing.service.gov.uk#{Whitehall.url_maker.admin_world_location_news_article_path(news_article)}",
                  news_article.public_timestamp.to_s,
                  'WorldLocationNewsArticle',
                  '1',
                  'https://www.gov.uk/missing-link'], embassy_csv[1]

    hmrc_csv = CSV.read(reports_dir.join('hm-revenue-customs_broken_links.csv'))
    assert_equal 3, hmrc_csv.size
    assert_equal ['page', 'admin link', 'public timestamp', 'format', 'broken link count', 'broken links'], hmrc_csv[0]
    assert_equal ["https://www.gov.uk#{Whitehall.url_maker.publication_path(publication.slug)}",
                  "https://whitehall-admin.publishing.service.gov.uk#{Whitehall.url_maker.admin_publication_path(publication)}",
                  publication.public_timestamp.to_s,
                  'Publication',
                  '1',
                  "https://www.gov.uk/bad-link"], hmrc_csv[1]
    assert_equal ["https://www.gov.uk#{Whitehall.url_maker.detailed_guide_path(detailed_guide.slug)}",
                  "https://whitehall-admin.publishing.service.gov.uk#{Whitehall.url_maker.admin_detailed_guide_path(detailed_guide)}",
                  detailed_guide.public_timestamp.to_s,
                  'DetailedGuide',
                  '2',
                  "https://www.gov.uk/bad-link\r\nhttps://www.gov.uk/missing-link"], hmrc_csv[2]
  end

  test 'generates CSV reports detailing broken links on public documents tagged to a defined organisation' do
    stub_request(:any, 'https://www.gov.uk/good-link').to_return(status: 200)
    stub_request(:any, 'https://www.gov.uk/another-good-link').to_return(status: 200)
    stub_request(:any, 'https://www.gov.uk/bad-link').to_return(status: 500)
    stub_request(:any, 'https://www.gov.uk/missing-link').to_return(status: 404)

    hmrc = create(:organisation, name: 'HM Revenue & Customs')
    embassy_paris = create(:worldwide_organisation, name: 'British Embassy Paris')

    publication    = create(:published_publication,
                            lead_organisations: [hmrc],
                            body: "[A broken page](https://www.gov.uk/bad-link)\n[A good link](https://www.gov.uk/another-good-link)")

    detailed_guide = create(:published_detailed_guide,
                            lead_organisations: [hmrc],
                            body: "[Good](https://www.gov.uk/good-link)\n[broken link](https://www.gov.uk/bad-link)\n[Missing page](https://www.gov.uk/missing-link)")

    create(:world_location_news_article,
           :withdrawn,
           worldwide_organisations: [embassy_paris],
           body: "[Good link](https://www.gov.uk/good-link)\n[Missing page](https://www.gov.uk/missing-link)")

    Dir.mkdir(reports_dir) unless File.directory?(reports_dir)
    Whitehall::BrokenLinkReporter.new(reports_dir.to_s, NullLogger.instance, hmrc).generate_reports

    refute File.file?(reports_dir.join('british-embassy-paris_broken_links.csv'))

    hmrc_csv = CSV.read(reports_dir.join('hm-revenue-customs_broken_links.csv'))
    assert_equal 3, hmrc_csv.size
    assert_equal ['page', 'admin link', 'public timestamp', 'format', 'broken link count', 'broken links'], hmrc_csv[0]
    assert_equal ["https://www.gov.uk#{Whitehall.url_maker.publication_path(publication.slug)}",
                  "https://whitehall-admin.publishing.service.gov.uk#{Whitehall.url_maker.admin_publication_path(publication)}",
                  publication.public_timestamp.to_s,
                  'Publication',
                  '1',
                  "https://www.gov.uk/bad-link"], hmrc_csv[1]
    assert_equal ["https://www.gov.uk#{Whitehall.url_maker.detailed_guide_path(detailed_guide.slug)}",
                  "https://whitehall-admin.publishing.service.gov.uk#{Whitehall.url_maker.admin_detailed_guide_path(detailed_guide)}",
                  detailed_guide.public_timestamp.to_s,
                  'DetailedGuide',
                  '2',
                  "https://www.gov.uk/bad-link\r\nhttps://www.gov.uk/missing-link"], hmrc_csv[2]
  end

  test 'does not blow up if a document does not have any organisations' do
    stub_request(:any, 'https://www.gov.uk/good-link').to_return(status: 200)
    stub_request(:any, 'https://www.gov.uk/missing-link').to_return(status: 404)

    speech = create(:published_speech,
                    person_override: "The Queen",
                    body: "[Good link](https://www.gov.uk/good-link)\n[Missing page](https://www.gov.uk/missing-link)",
                    role_appointment: nil,
                    create_default_organisation: false)

    Dir.mkdir(reports_dir) unless File.directory?(reports_dir)
    Whitehall::BrokenLinkReporter.new(reports_dir.to_s, NullLogger.instance).generate_reports

    csv = CSV.read(reports_dir.join('no-organisation_broken_links.csv'))
    assert_equal 2, csv.size
    assert_equal ['page', 'admin link', 'public timestamp', 'format', 'broken link count', 'broken links'], csv[0]
    assert_equal ["https://www.gov.uk#{Whitehall.url_maker.speech_path(speech.slug)}",
                  "https://whitehall-admin.publishing.service.gov.uk#{Whitehall.url_maker.admin_speech_path(speech)}",
                  speech.public_timestamp.to_s,
                  'Speech',
                  '1',
                  'https://www.gov.uk/missing-link'], csv[1]
  end

private

  def reports_dir
    Rails.root.join('tmp/broken_link_reports')
  end
end
