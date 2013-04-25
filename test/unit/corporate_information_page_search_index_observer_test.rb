require 'test_helper'

class CorporateInformationPageSearchIndexObserverTest < ActiveSupport::TestCase
  test 'should add corp info page to search index when its organisation goes live' do
    org = create(:organisation, govuk_status: 'joining')
    corp_page = create(:corporate_information_page, organisation: org)

    Searchable::Index.stubs(:later).with(anything)
    Searchable::Index.expects(:later).with(corp_page)

    org.govuk_status = 'live'
    org.save
  end

  test 'should remove corp info pages from search index when its organisation becomes no longer live' do
    org = create(:organisation, govuk_status: 'live')
    corp_page = create(:corporate_information_page, organisation: org)

    Searchable::Delete.stubs(:later).with(anything)
    Searchable::Delete.expects(:later).with(corp_page)

    org.govuk_status = 'joining'
    org.save
  end

end
