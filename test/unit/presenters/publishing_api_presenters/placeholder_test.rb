require 'test_helper'

class PublishingApiPresenters::PlaceholderTest < ActiveSupport::TestCase
  def present(organisation, options = {})
    PublishingApiPresenters::Placeholder.new(organisation, options).as_json
  end

  test 'presents an Organisation ready for adding to the publishing API' do
    organisation = create(:organisation, name: 'Organisation of Things')
    public_path = Whitehall.url_maker.organisation_path(organisation)

    expected_hash = {
      content_id: organisation.content_id,
      title: "Organisation of Things",
      base_path: public_path,
      format: "placeholder",
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: organisation.updated_at,
      routes: [ { path: public_path, type: "exact" } ],
      update_type: "major",
    }

    assert_equal expected_hash, present(organisation)
  end

  test 'update type can be overridden by passing an update_type option' do
    update_type_override = 'republish'
    organisation = create(:organisation)
    presented_hash = present(organisation, update_type: update_type_override)
    assert_equal update_type_override, presented_hash[:update_type]
  end
end
