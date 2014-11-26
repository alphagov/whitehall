require 'test_helper'

class PublishingApiPresenters::OrganisationTest < ActiveSupport::TestCase
  def present(organisation)
    PublishingApiPresenters::Organisation.new(organisation).as_json
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
end
