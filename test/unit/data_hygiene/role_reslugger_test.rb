require 'test_helper'

class MinisterialRoleResluggerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    stub_any_publishing_api_call
    DatabaseCleaner.clean_with :truncation
    @ministerial_role = create(:ministerial_role, name: "Misspelt role")
    @reslugger = DataHygiene::RoleReslugger.new(@ministerial_role, 'corrected-slug')
  end

  teardown do
    DatabaseCleaner.clean_with :truncation
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

    expected_publish_requests = [
      stub_publishing_api_put_content(content_item.content_id, content_item.content),
      stub_publishing_api_patch_links(content_item.content_id, links: content_item.links),
      stub_publishing_api_publish(content_item.content_id, locale: 'en', update_type: 'major')
    ]

    @reslugger.run!

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
