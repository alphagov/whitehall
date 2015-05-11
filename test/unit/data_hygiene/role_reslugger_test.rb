require 'test_helper'

class MinisterialRoleResluggerTest < ActiveSupport::TestCase
  self.use_transactional_fixtures = false

  setup do
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
    content_item = PublishingApiPresenters.presenter_for(@ministerial_role).as_json
    old_base_path = @ministerial_role.search_link
    new_base_path = "/government/ministers/corrected-slug"
    content_item[:routes][0][:path] = new_base_path
    redirects = [
      { path: old_base_path, type: "exact", destination: new_base_path },
      { path: (old_base_path + ".atom"), type: "exact", destination: (new_base_path + ".atom") }
    ]
    redirect_item = Whitehall::PublishingApi::Redirect.new(old_base_path, redirects).as_json

    expected_publish_request = stub_publishing_api_put_item(new_base_path, content_item)
    expected_redirect = stub_publishing_api_put_item(old_base_path, redirect_item)

    @reslugger.run!

    assert_requested expected_redirect
    assert_requested expected_publish_request
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
