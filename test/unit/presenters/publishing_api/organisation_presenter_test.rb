require 'test_helper'

class PublishingApi::OrganisationPresenterTest < ActionView::TestCase
  def present(model_instance, options = {})
    PublishingApi::OrganisationPresenter.new(model_instance, options)
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
      schema_name: 'placeholder',
      document_type: 'organisation',
      links: { featured_policies: [] },
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
    expected_links = {}

    presented_item = present(organisation)

    assert_equal expected_hash, presented_item.content
    assert_equal expected_links, presented_item.links
    assert_equal "major", presented_item.update_type
    assert_equal organisation.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end

  test 'presents an organisation with a custom logo with a nil crest' do
    organisation = create(
      :organisation,
      name: 'Organisation of Things',
      organisation_logo_type_id: 14,
      logo: fixture_file_upload('images/960x640_jpeg.jpg', 'image/jpeg')
    )
    presented_item = present(organisation)

    assert_equal presented_item.content[:details][:logo][:crest], nil
  end

  test 'presents an organisation with no identity with a nil crest' do
    organisation = create(
      :organisation,
      name: 'Organisation of Things',
      organisation_logo_type_id: 1
    )
    presented_item = present(organisation)

    assert_equal presented_item.content[:details][:logo][:crest], nil
  end
end
