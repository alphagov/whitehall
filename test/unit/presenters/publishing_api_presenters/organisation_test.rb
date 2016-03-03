require 'test_helper'

class PublishingApiPresenters::OrganisationTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApiPresenters::Organisation.new(model_instance, options)
  end

  test 'presents an organisation with a brand colour' do
    organisation = create(:organisation, organisation_brand_colour_id: 1)
    presented_item = present(organisation)

    assert_equal presented_item.content[:details][:brand], organisation.organisation_brand_colour.class_name
  end

  test 'presents an Organisation ready for adding to the publishing API' do
    organisation = create(:organisation, name: 'Organisation of Things', analytics_identifier: 'O123')
    public_path = Whitehall.url_maker.organisation_path(organisation)

    expected_hash = {
      base_path: public_path,
      title: "Organisation of Things",
      description: nil,
      format: "placeholder_organisation",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: organisation.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {
        brand: nil,
        logo: {
          formatted_title: "Organisation<br/>of<br/>Things",
          crest: "single-identity",
        },
      },
      analytics_identifier: "O123",
    }
    expected_links = { topics: [] }

    presented_item = present(organisation)

    assert_equal expected_hash, presented_item.content
    assert_equal expected_links, presented_item.links
    assert_equal "major", presented_item.update_type
    assert_equal organisation.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end
end
