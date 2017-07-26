require 'test_helper'

class PublishingApi::MinisterialRolePresenterTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApi::MinisterialRolePresenter.new(model_instance, options)
  end

  test 'presents a Ministerial Role ready for adding to the publishing API' do
    ministerial_role = create(:ministerial_role, name: "Secretary of State for Silly Walks")
    public_path = Whitehall.url_maker.ministerial_role_path(ministerial_role)

    expected_hash = {
      base_path: public_path,
      title: "Secretary of State for Silly Walks",
      description: nil,
      schema_name: "placeholder",
      document_type: "ministerial_role",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: ministerial_role.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {},
      update_type: "major",
    }
    expected_links = {
      organisations: ministerial_role.organisations.map(&:content_id)
    }

    presented_item = present(ministerial_role)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal ministerial_role.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end
end
