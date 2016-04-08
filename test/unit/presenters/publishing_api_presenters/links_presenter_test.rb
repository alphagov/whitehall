require 'test_helper'

class PublishingApiPresenters::LinksPresenterTest < ActionView::TestCase
  ALL_LINK_TYPES = PublishingApiPresenters::LinksPresenter::LINK_NAMES_TO_METHODS_MAP.keys

  def links_for(item, filter_links = ALL_LINK_TYPES)
    LinksPresenter.new(item).extract(filter_links)
  end

  test 'nil returns a set of tags that are defaulted to []' do
    links = links_for(nil)

    ALL_LINK_TYPES.each do |link_type|
      assert_equal links[link_type], []
    end
  end

  test 'extracts content_ids from a detailed guide' do
    document = create(:detailed_guide)
    links = links_for(document)

    assert_equal document.lead_organisations.map(&:content_id), links[:lead_organisations]
    # whitehall names and publishing api names don't necessarily match...
    assert_equal document.topics.map(&:content_id), links[:policy_areas]
  end
end
