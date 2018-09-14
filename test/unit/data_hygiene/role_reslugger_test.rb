require 'test_helper'

class MinisterialRoleResluggerTest < ActiveSupport::TestCase
  setup do
    stub_any_publishing_api_call
    @organisation = create(:organisation)
    @ministerial_role = create(:ministerial_role, organisations: [@organisation], name: "Misspelt role")
    @reslugger = DataHygiene::RoleReslugger.new(@ministerial_role, 'corrected-slug')
  end

  test "re-slugs the role" do
    @reslugger.run!
    assert_equal 'corrected-slug', @ministerial_role.slug
  end

  test "publishes to Publishing API with the new slug and redirects the old" do
    WebMock.reset! # reset the stubs after Publishing API calls caused by `create(:ministerial_role, name: "Misspelt role")`

    redirect_uuid = SecureRandom.uuid
    SecureRandom.stubs(uuid: redirect_uuid)
    new_base_path = "/government/ministers/corrected-slug"

    content_item = PublishingApiPresenters.presenter_for(@ministerial_role)
    content = content_item.content
    content[:base_path] = new_base_path
    content[:routes][0][:path] = new_base_path
    content_item.stubs(content: content)

    organisation_content_item = PublishingApiPresenters.presenter_for(
      @organisation,
      update_type: 'republish'
    )

    expected_publish_requests = [
      stub_publishing_api_put_content(content_item.content_id, content_item.content),
      stub_publishing_api_patch_links(content_item.content_id, links: content_item.links),
      stub_publishing_api_publish(content_item.content_id, locale: 'en', update_type: nil),
      stub_publishing_api_put_content(organisation_content_item.content_id, organisation_content_item.content),
      stub_publishing_api_patch_links(organisation_content_item.content_id, links: organisation_content_item.links),
      stub_publishing_api_publish(organisation_content_item.content_id, locale: 'en', update_type: nil)
    ]

    Sidekiq::Testing.inline! do
      @reslugger.run!
    end

    assert_all_requested(expected_publish_requests)
  end

  test "deletes the old slug from the search index" do
    Whitehall::SearchIndex.expects(:delete).with { |minister| minister.slug == 'misspelt-role' }
    @reslugger.run!
  end

  test "adds the new slug from the search index" do
    Whitehall::SearchIndex.expects(:add).with { |minister| minister.slug == 'corrected-slug' }
    @reslugger.run!
  end
end
