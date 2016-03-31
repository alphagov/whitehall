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

  test 'extracts content_ids from a tagged edition' do
    edition = create(:edition)
    create(:specialist_sector, tag: "oil-and-gas/offshore", edition: edition, primary: true)
    create(:specialist_sector, tag: "oil-and-gas/onshore", edition: edition, primary: false)

    publishing_api_has_lookups({
      "/topic/oil-and-gas/offshore" => "content_id_1",
      "/topic/oil-and-gas/onshore" => "content_id_2",
    })

    links = links_for(edition)

    assert_equal links[:topics], %w(content_id_1 content_id_2)
  end

  test 'treats the primary specialist sector as the parent link of the item' do
    edition = create(:edition)
    create(:specialist_sector, tag: "oil-and-gas/offshore", edition: edition, primary: true)
    create(:specialist_sector, tag: "oil-and-gas/onshore", edition: edition, primary: false)

    publishing_api_has_lookups({
      "/topic/oil-and-gas/offshore" => "content_id_1",
      "/topic/oil-and-gas/onshore" => "content_id_2",
    })

    assert_equal links_for(edition)[:parent], %w(content_id_1)
  end
end
