require 'test_helper'

class BrokenLinkReporterTest < ActiveSupport::TestCase

  class EditionCheckerTest < ActiveSupport::TestCase
    test '#page_url returns the production public page URL of the document' do
      detailed_guide = create(:detailed_guide)
      checker = Whitehall::BrokenLinkReporter::EditionChecker.new(detailed_guide)
      assert_equal "https://www.gov.uk#{Whitehall.url_maker.detailed_guide_path(detailed_guide.slug)}", checker.public_url
    end

    test '#admin_url returns the production admin URL of the document' do
      detailed_guide = create(:detailed_guide)
      checker = Whitehall::BrokenLinkReporter::EditionChecker.new(detailed_guide)

      assert_equal "https://whitehall-admin.production.alphagov.co.uk/government/admin/detailed-guides/#{detailed_guide.id}",
        checker.admin_url
    end

    test '#organisation returns the lead organisation of the document' do
      organisation   = create(:organisation)
      detailed_guide = create(:detailed_guide, lead_organisations: [organisation])
      checker        = Whitehall::BrokenLinkReporter::EditionChecker.new(detailed_guide)

      assert_equal organisation, checker.lead_organisation
    end

    test '#organisation returns a worldwide organisation for documents that have them' do
      worldwide_organisation = create(:worldwide_organisation)
      world_news_article     = create(:world_location_news_article, worldwide_organisations: [worldwide_organisation])
      checker                = Whitehall::BrokenLinkReporter::EditionChecker.new(world_news_article)

      assert_equal worldwide_organisation, checker.lead_organisation
    end

    test '#check_links creates and runs a LinksReport for the edition' do
      detailed_guide = create(:detailed_guide,
                              body: "[good](https://www.gov.uk/good-link)")
      stub_request(:any, 'https://www.gov.uk/good-link').to_return(status: 200)

      checker = Whitehall::BrokenLinkReporter::EditionChecker.new(detailed_guide)
      checker.check_links

      assert links_report = detailed_guide.links_reports.last
      assert links_report.completed?
    end

    test '#broken_links returns any bad links on the link report for the edition' do
      detailed_guide = create(:detailed_guide,
                              body: "[good](https://www.gov.uk/good-link), [bad](https://www.gov.uk/bad-link), [ugly](https://www.gov.uk/missing-link)")
      stub_request(:any, 'https://www.gov.uk/good-link').to_return(status: 200)
      stub_request(:any, 'https://www.gov.uk/bad-link').to_return(status: 500)
      stub_request(:any, 'https://www.gov.uk/missing-link').to_return(status: 404)

      checker = Whitehall::BrokenLinkReporter::EditionChecker.new(detailed_guide)
      checker.check_links

      expected_broken_links = ['https://www.gov.uk/bad-link',
                             'https://www.gov.uk/missing-link']

      assert_equal expected_broken_links, checker.broken_links
    end
  end
end
