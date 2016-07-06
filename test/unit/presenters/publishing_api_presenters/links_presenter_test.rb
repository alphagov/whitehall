require 'test_helper'

class PublishingApiPresenters::LinksPresenterTest < ActionView::TestCase
  ALL_LINK_TYPES = PublishingApiPresenters::LinksPresenter::LINK_NAMES_TO_METHODS_MAP.keys

  def links_for(item, filter_links = ALL_LINK_TYPES)
    LinksPresenter.new(item).extract(filter_links)
  end
  test 'extracts content_ids from a detailed guide' do
    document = create(:detailed_guide)
    links = links_for(document)

    assert_equal document.organisations.map(&:content_id), links[:organisations]
    # whitehall names and publishing api names don't necessarily match...
    assert_equal document.topics.map(&:content_id), links[:policy_areas]
  end
end
