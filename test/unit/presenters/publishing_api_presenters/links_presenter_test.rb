require 'test_helper'

class PublishingApiPresenters::LinksPresenterTest < ActionView::TestCase
  ALL_LINK_TYPES = [
    :document_collections,
    :lead_organisations,
    :policy_areas,
    :related_policies,
    :statistical_data_set_documents,
    :supporting_organisations,
    :topics,
    :world_locations,
    :worldwide_organisations,
    :worldwide_priorities,
  ]

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
      create(:specialist_sector, tag: 'oil-and-gas/offshore', edition: edition, primary: true)
      create(:specialist_sector, tag: 'oil-and-gas/onshore', edition: edition, primary: false)

      links = links_for(edition)

      assert_equal links[:topics], ["129fb467-afd8-42e5-98c9-4f3294c40bb9", "129fb467-afd8-42e5-98c9-4f3294c40bb9"]
    end
end
