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
    create(:specialist_sector, topic_content_id: "content_id_1", edition: edition, primary: false)

    links = links_for(edition, [:topics, :parent, :organisations])

    assert_equal({ topics: %w(content_id_1), parent: [], organisations: [] }, links)
  end

  test 'rejects invalid specialist sectors' do
    edition = create(:edition)

    create(:specialist_sector, topic_content_id: "content_id_1", edition: edition, primary: true)
    create(:specialist_sector, :invalid, edition: edition, primary: false)
    create(:specialist_sector, topic_content_id: "content_id_3", edition: edition, primary: false)

    assert_equal(
      { topics: %w(content_id_1 content_id_3) },
      links_for(edition, %i(topics))
    )
  end

  test 'it treats the primary specialist sector of the item as the parent' do
    edition = create(:edition)
    create(:specialist_sector, topic_content_id: "content_id_1", edition: edition, primary: true)
    create(:specialist_sector, topic_content_id: "content_id_2", edition: edition, primary: false)

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
