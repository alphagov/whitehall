require 'test_helper'

class PublishingApi::WorldwideOrganisationPresenterTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApi::WorldwideOrganisationPresenter.new(model_instance, options)
  end

  test 'presents a Worldwide Organisation ready for adding to the publishing API' do
    worldwide_org = create(:worldwide_organisation, name: 'Locationia Embassy', analytics_identifier: 'WO123')
    public_path = Whitehall.url_maker.worldwide_organisation_path(worldwide_org)

    expected_hash = {
      base_path: public_path,
      title: "Locationia Embassy",
      description: nil,
      schema_name: "placeholder",
      document_type: "worldwide_organisation",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: worldwide_org.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {},
      analytics_identifier: "WO123",
    }
    expected_links = {}

    presented_item = present(worldwide_org)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal worldwide_org.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end
end
