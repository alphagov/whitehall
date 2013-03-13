require 'test_helper'

class CorporateInformationPageSearchIndexObserverTest < ActiveSupport::TestCase
  test 'should add corp info page to search index when its organisation goes live' do
    org = create(:organisation, govuk_status: 'joining')
    corp_page = create(:corporate_information_page, organisation: org)

    Rummageable.stubs(:index).with(anything, Whitehall.government_search_index_path)
    Rummageable.expects(:index).with(corp_page.search_index, Whitehall.government_search_index_path)

    org.govuk_status = 'live'
    org.save
  end

  test 'should remove corp info pages from search index when its organisation becomes no longer live' do
    org = create(:organisation, govuk_status: 'live')
    corp_page = create(:corporate_information_page, organisation: org)

    Rummageable.stubs(:delete).with(anything, Whitehall.government_search_index_path)
    Rummageable.expects(:delete).with(corp_page.search_index['link'], Whitehall.government_search_index_path)

    org.govuk_status = 'joining'
    org.save
  end

end
