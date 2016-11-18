require 'test_helper'

class PublishingApi::ServicesAndInformationPresenterTest < ActionView::TestCase
  def present(model_instance)
    PublishingApi::ServicesAndInformationPresenter.new(model_instance)
  end

  test 'presents a Services and Information page ready for adding to the publishing API' do
    organisation = create(:organisation, name: "Organisation of Things")
    public_path = Whitehall.url_maker.organisation_path(organisation) + "/services-information"

    expected_hash = {
      base_path: public_path,
      title: "Services and information - Organisation of Things",
      description: "",
      schema_name: "special_route",
      document_type: "special_route",
      publishing_app: "whitehall",
      rendering_app: "whitehall-frontend",
      public_updated_at: organisation.updated_at,
      routes: [{ path: public_path, type: "exact" }],
    }
    expected_links = {
      parent: [
        organisation.content_id
      ]
    }
    expected_update_type = "minor"

    presented_item = present(organisation)

    assert_equal expected_hash, presented_item.content
    assert_equal expected_links, presented_item.links
    assert_equal expected_update_type, presented_item.update_type

    assert_valid_against_schema(presented_item.content, "special_route")
  end
end
