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
      description: nil,
      schema_name: "generic",
      document_type: "services_and_information",
      locale: "en",
      publishing_app: "whitehall",
      rendering_app: "collections",
      public_updated_at: organisation.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {},
      update_type: "minor",
    }
    expected_links = {
      parent: [
        organisation.content_id
      ],
      organisations: [
        organisation.content_id
      ],
    }
    expected_update_type = "minor"

    presented_item = present(organisation)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal expected_update_type, presented_item.update_type

    assert_valid_against_schema(presented_item.content, "generic")
  end
end
