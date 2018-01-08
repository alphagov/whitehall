require 'test_helper'

class PublishingApi::PolicyAreaPlaceholderPresenterTest < ActionView::TestCase
  def present(model_instance, options = {})
    PublishingApi::PolicyAreaPlaceholderPresenter.new(model_instance, options)
  end

  test 'presents a policy area ready for adding to the publishing API' do
    policy_area = create(:topic, name: 'Policy Area of Things')
    public_path = Whitehall.url_maker.polymorphic_path(policy_area)

    expected_hash = {
      base_path: public_path,
      title: "Policy Area of Things",
      description: nil,
      schema_name: 'placeholder',
      document_type: 'policy_area',
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: policy_area.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      details: {},
      update_type: "major",
    }
    expected_links = { organisations: [] }

    presented_item = present(policy_area)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal policy_area.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end
end
