require 'test_helper'

class PublishingApi::PersonPresenterTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApi::PersonPresenter.new(model_instance, options)
  end

  test 'presents a Person ready for adding to the publishing API' do
    person = create(:person, forename: "Winston")
    public_path = Whitehall.url_maker.person_path(person)

    expected_hash = {
      base_path: public_path,
      title: "Winston",
      description: nil,
      schema_name: "placeholder",
      document_type: "person",
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: person.updated_at,
      routes: [{ path: public_path, type: "exact" }],
      redirects: [],
      need_ids: [],
      details: {},
    }
    expected_links = {}

    presented_item = present(person)

    assert_equal expected_hash, presented_item.content
    assert_hash_includes presented_item.links, expected_links
    assert_equal "major", presented_item.update_type
    assert_equal person.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end
end
