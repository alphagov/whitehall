require "test_helper"

class PublishingApi::PayloadBuilder::LinksTest < ActionView::TestCase
  ALL_LINK_TYPES = PublishingApi::PayloadBuilder::Links::LINK_NAMES_TO_METHODS_MAP.keys

  def links_for(item, filter_links = ALL_LINK_TYPES)
    PublishingApi::PayloadBuilder::Links.for(item).extract(filter_links)
  end

  test "extracts content_i'ds from a detailed guide" do
    document = create(:detailed_guide)
    links = links_for(document)

    assert_equal document.organisations.map(&:content_id), links[:organisations]
  end

  test "returns a links hash derived from the edition" do
    edition = create(:edition)
    links = links_for(edition, %i[organisations])

    assert_equal(
      {
        organisations: [],
        primary_publishing_organisation: [],
      },
      links,
    )
  end

  test "adds primary publishing organisation" do
    organisation = create(:organisation)
    edition = create(:detailed_guide, lead_organisations: [organisation])

    links = links_for(edition, [:organisations])

    assert_equal(
      {
        organisations: [organisation.content_id],
        primary_publishing_organisation: [organisation.content_id],
      },
      links,
    )
  end

  test "respects the user-specified ordering of organisations and not their database order" do
    second_lead_organisation = create(:organisation)
    first_lead_organisation = create(:organisation)
    supporting_organisation = create(:organisation)

    edition = create(:document_collection, lead_organisations: [first_lead_organisation, second_lead_organisation], supporting_organisations: [supporting_organisation])

    links = links_for(edition, [:organisations])

    assert_equal(
      {
        organisations: [first_lead_organisation.content_id, second_lead_organisation.content_id, supporting_organisation.content_id],
        primary_publishing_organisation: [first_lead_organisation.content_id],
      },
      links,
    )
  end
end
