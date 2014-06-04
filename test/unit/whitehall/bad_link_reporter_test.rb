require 'test_helper'

class BadLinkReporterTest < ActiveSupport::TestCase

  class PageCheckerTest < ActiveSupport::TestCase
    test 'identifies if the page is for an existing whitehall document' do
      detailed_guide = create(:detailed_guide, id: '99999999')
      checker        = Whitehall::BadLinkReporter::PageChecker.new(detailed_guide_page, result_cache)

      assert checker.is_edition?
      assert_equal detailed_guide, checker.edition
    end

    test 'identifies if the page is not for an existing whitehall document' do
      news_article = create(:news_article, id: '99999999')
      checker      = Whitehall::BadLinkReporter::PageChecker.new(detailed_guide_page, result_cache)

      refute checker.is_edition?
      assert_nil checker.edition
    end

    test '#page_url returns the public page URL of the document' do
      checker = Whitehall::BadLinkReporter::PageChecker.new(detailed_guide_page, result_cache)
      assert_equal 'https://www.gov.uk/detailed_guide', checker.page_url
    end

    test '#admin_url returns the admin url for the matching edition' do
      detailed_guide = create(:detailed_guide, id: '99999999')
      checker = Whitehall::BadLinkReporter::PageChecker.new(detailed_guide_page, result_cache)

      assert_equal 'https://whitehall-admin.production.alphagov.co.uk/government/admin/detailed-guides/99999999',
                   checker.admin_url
    end

    test '#organisation returns the lead organisation of the document' do
      organisation   = create(:organisation)
      detailed_guide = create(:detailed_guide, id: '99999999', lead_organisations: [organisation])
      checker        = Whitehall::BadLinkReporter::PageChecker.new(detailed_guide_page, result_cache)

      assert_equal organisation, checker.lead_organisation
    end

    test '#organisation returns a worldwide organisation for documents that have them' do
      worldwide_organisation = create(:worldwide_organisation)
      world_news_article     = create(:world_location_news_article, worldwide_organisations: [worldwide_organisation], id: '99999998')
      checker                = Whitehall::BadLinkReporter::PageChecker.new(world_location_news_article_page, result_cache)

      assert_equal worldwide_organisation, checker.lead_organisation
    end

    test '#raw_bad_links returns an array of bad links found on the page' do
      stub_request(:any, 'https://www.gov.uk/good-link').to_return(status: 200)
      stub_request(:any, 'https://www.gov.uk/bad-link').to_return(status: 500)
      stub_request(:any, 'https://www.gov.uk/missing-link').to_return(status: 404)

      checker = Whitehall::BadLinkReporter::PageChecker.new(detailed_guide_page, result_cache)

      expected_bad_links = ['https://www.gov.uk/bad-link',
                            'https://www.gov.uk/missing-link']

      assert_equal expected_bad_links, checker.raw_bad_links
    end

  private

    def result_cache
      @result_cache ||= ::BadLinkFinder::ResultCache.new
    end

    def detailed_guide_page
      BadLinkFinder::Page.new(mirror_fixture_root, 'detailed_guide.html')
    end

    def world_location_news_article_page
      BadLinkFinder::Page.new(mirror_fixture_root, 'news.html')
    end

    def mirror_fixture_root
      Rails.root.join('test/fixtures/mirror/').to_s
    end
  end
end
