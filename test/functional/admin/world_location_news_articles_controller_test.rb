require 'test_helper'

class Admin::WorldLocationNewsArticlesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @world_location = create(:world_location)
    @worldwide_organisation = create(:worldwide_organisation)
  end

  should_be_an_admin_controller

  test 'PUT :update for non-English edition does not save any additional translations' do
    edition = I18n.with_locale(:fr) { create(:world_location_news_article, title: 'French Title', body: 'French Body', primary_locale: :fr) }

    put :update, id: edition, edition: { title: 'New French title', world_location_ids: [@world_location.id], worldwide_organisation_ids: [@worldwide_organisation.id]}
    assert_redirected_to admin_world_location_news_article_path(edition)

    assert_equal 'fr', edition.reload.primary_locale
    refute edition.available_in_locale?(:en)
  end
end
