require 'test_helper'
require 'gds_api/test_helpers/rummager'

class PersonSlugChangerTest < ActiveSupport::TestCase
  include GdsApi::TestHelpers::Rummager
  self.use_transactional_fixtures = false

  setup do
    DatabaseCleaner.clean_with :truncation
    @person = create(:person, forename: 'old', surname: 'slug', biography: 'Biog')
    @reslugger = DataHygiene::PersonReslugger.new(@person, 'updated-slug')
  end

  teardown do
    DatabaseCleaner.clean_with :truncation
  end

  test "re-slugs the person" do
    @reslugger.run!
    assert_equal 'updated-slug', @person.slug
  end

  test "publishes to Publishing API with the new slug and redirects the old" do
    SecureRandom.stubs(:uuid).returns("a-uuid")
    content_item = PublishingApiPresenters.presenter_for(@person).as_json
    old_base_path = @person.search_link
    new_base_path = "/government/people/updated-slug"
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
    Whitehall::SearchIndex.expects(:delete).with { |person| person.slug == 'old-slug' }
    @reslugger.run!

  end

  test "adds the new slug from the search index" do
    Whitehall::SearchIndex.expects(:add).with { |person| person.slug == 'updated-slug' }
    @reslugger.run!
  end

  test "re-indexes all the published dependent documents" do
    published_news = create(:published_news_article)
    draft_news = create(:draft_news_article)
    role_appointment = create(:role_appointment,
                        person: @person,
                        editions: [published_news, draft_news])

    published_speech = create(:published_speech, role_appointment: role_appointment)
    draft_speech = create(:draft_speech, role_appointment: role_appointment)

    Whitehall::SearchIndex.stubs(:add)
    Whitehall::SearchIndex.expects(:add).with(published_news)
    Whitehall::SearchIndex.expects(:add).with(published_speech)
    Whitehall::SearchIndex.expects(:add).with(draft_news).never
    Whitehall::SearchIndex.expects(:add).with(draft_speech).never
    @reslugger.run!
  end
end
