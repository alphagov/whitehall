require "test_helper"

class Admin::WorldLocationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test 'should allow modification of existing world location data' do
    world_location = create(:world_location)

    get :edit, id: world_location

    assert_template 'world_locations/edit'
    assert_select "textarea[name='world_location[description]']"
    assert_select "textarea[name='world_location[about]'].previewable"
    assert_select '#govspeak_help'
  end

  test 'updating should modify the world location' do
    world_location = create(:world_location)

    put :update, id: world_location, world_location: { description: 'country-description', about: 'country-about' }

    world_location.reload
    assert_equal 'country-description', world_location.description
    assert_equal 'country-about', world_location.about
  end

  test "editing should display published news articles related to the world location" do
    published_news_article = create(:published_news_article)
    draft_news_article = create(:draft_news_article)
    another_news_article = create(:published_news_article)
    world_location = create(:world_location, editions: [published_news_article, draft_news_article])

    get :edit, id: world_location

    assert_select_object(published_news_article)
    refute_select_object(draft_news_article)
    refute_select_object(another_news_article)
  end

  test "editing should display news articles most recently published first" do
    earlier_news_article = create(:published_news_article, first_published_at: 2.days.ago)
    later_news_article = create(:published_news_article, first_published_at: 1.days.ago)
    world_location = create(:world_location, editions: [earlier_news_article, later_news_article])

    get :edit, id: world_location

    assert_equal [later_news_article, earlier_news_article], assigns(:news_articles)
  end

  test "editing should allow non-featured published news articles to be featured" do
    published_news_article = create(:published_news_article)
    world_location = create(:world_location)
    edition_world_location = create(:edition_world_location, world_location: world_location, edition: published_news_article)

    get :edit, id: world_location

    assert_select "form[action=#{admin_edition_world_location_path(edition_world_location)}]" do
      assert_select "input[name='edition_world_location[featured]'][value='true']"
    end
  end

  test "editing should allow featured published news articles to be unfeatured" do
    published_news_article = create(:published_news_article)
    world_location = create(:world_location)
    edition_world_location = create(:edition_world_location, world_location: world_location, edition: published_news_article, featured: true)

    get :edit, id: world_location

    assert_select "form[action=#{admin_edition_world_location_path(edition_world_location)}]" do
      assert_select "input[name='edition_world_location[featured]'][value='false']"
    end
  end
end