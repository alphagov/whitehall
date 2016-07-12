require 'test_helper'

class PublishingApi::LinksPresenterTest < ActionView::TestCase
  ALL_LINK_TYPES = PublishingApi::LinksPresenter::LINK_NAMES_TO_METHODS_MAP.keys

  def links_for(item, filter_links = ALL_LINK_TYPES)
    LinksPresenter.new(item).extract(filter_links)
  end

  test 'extracts content_ids from a detailed guide' do
    document = create(:detailed_guide)
    links = links_for(document)

    assert_equal document.organisations.map(&:content_id), links[:organisations]
    assert_equal document.topics.map(&:content_id), links[:policy_areas]
  end

  test 'returns a links hash derived from the edition' do
    edition = create(:edition)
    create(:specialist_sector, tag: "oil-and-gas/onshore", edition: edition, primary: false)
    publishing_api_has_lookups({"/topic/oil-and-gas/offshore" => "content_id_1"})

    links = links_for(edition, [:topics, :parent, :organisations])

    assert_equal({ topics: %w(content_id_1), parent: [], organisations: [] }, links)
  end

  test 'it treats the primary specialist sector of the item as the parent' do
    edition = create(:edition)
    create(:specialist_sector, tag: "oil-and-gas/offshore", edition: edition, primary: true)
    create(:specialist_sector, tag: "oil-and-gas/onshore", edition: edition, primary: false)
    publishing_api_has_lookups({
      "/topic/oil-and-gas/offshore" => "content_id_1",
      "/topic/oil-and-gas/onshore" => "content_id_2",
    })

    links = links_for(edition, [:topics, :parent, :organisations])

    assert_equal(
      {
        topics: %w(content_id_1 content_id_2),
        parent: %w(content_id_1),
        organisations: [],
      },
      links
    )
  end

  test 'parent will not be set if the specialist sector is not found' do
    edition = create(:edition)
    create(:specialist_sector, tag: "oil-and-gas/primary", edition: edition, primary: true)
    create(:specialist_sector, tag: "oil-and-gas/secondary", edition: edition, primary: false)
    publishing_api_has_lookups({
      "/topic/oil-and-gas/secondary" => "content_id_1",
    })

    links = links_for(edition, [:topics, :parent, :organisations])

    assert_equal({ topics: %w(content_id_1), parent: [], organisations: [] }, links)
  end

  test "correctly sets blank topic and parent values if no specialist sectors are specified" do
    edition = create(:edition)
    links = links_for(edition, [:topics, :parent, :organisations])

    assert_equal(
      {
        topics: [],
        parent: [],
        organisations: [],
      },
      links
    )
  end
end
