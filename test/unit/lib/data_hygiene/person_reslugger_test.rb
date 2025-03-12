require "test_helper"
require "gds_api/test_helpers/search"

class PersonSlugChangerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Search

  setup do
    stub_any_publishing_api_call
    @person = create(:person, forename: "old", surname: "slug", biography: "Biog")
    @reslugger = DataHygiene::PersonReslugger.new(@person, "updated-slug")
  end

  test "re-slugs the person" do
    @reslugger.run!
    assert_equal "updated-slug", @person.slug
  end

  test "publishes to Publishing API with the new slug and redirects the old" do
    WebMock.reset!

    redirect_uuid = SecureRandom.uuid
    SecureRandom.stubs(uuid: redirect_uuid)
    new_base_path = "/government/people/updated-slug"

    content_item = PublishingApiPresenters.presenter_for(@person)
    content = content_item.content
    content[:base_path] = new_base_path
    content[:routes][0][:path] = new_base_path
    content_item.stubs(content:)

    expected_publish_requests = [
      stub_publishing_api_put_content(content_item.content_id, content_item.content),
      stub_publishing_api_patch_links(content_item.content_id, links: content_item.links),
      stub_publishing_api_publish(content_item.content_id, locale: "en", update_type: nil),
    ]

    Sidekiq::Testing.inline! do
      @reslugger.run!
    end

    assert_all_requested(expected_publish_requests)
  end
end
