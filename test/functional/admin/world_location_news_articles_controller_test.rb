require 'test_helper'

class Admin::WorldLocationNewsArticlesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @world_location = create(:world_location)
    @worldwide_organisation = create(:worldwide_organisation)
  end

  should_be_an_admin_controller

  test 'POST :create for a non-English edition saves it as a non-English edition' do
    post :create, edition: {  lock_version: 0,
                              title: 'French title',
                              summary: 'Summary',
                              body: 'Body',
                              primary_locale: 'fr',
                              world_location_ids: [@world_location.id],
                              worldwide_organisation_ids: [@worldwide_organisation.id]
                            }
    edition = Edition.last
    assert_redirected_to admin_world_location_news_article_path(edition)

    assert_equal 'fr', edition.primary_locale
    assert edition.available_in_locale?(:fr)
    refute edition.available_in_locale?(:en)
    assert_equal edition.document.id.to_s, edition.document.slug

    translation = edition.translation_for(:fr)
    assert_equal 'French title', translation.title
    assert_equal 'Summary', translation.summary
    assert_equal 'Body', translation.body
  end

  test 'PUT :update for non-English edition does not save any additional translations' do
    edition = I18n.with_locale(:fr) { create(:world_location_news_article, title: 'French Title', body: 'French Body', primary_locale: :fr) }

    put :update, id: edition, edition: { title: 'New French title', world_location_ids: [@world_location.id], worldwide_organisation_ids: [@worldwide_organisation.id]}
    assert_redirected_to admin_world_location_news_article_path(edition)

    assert_equal 'fr', edition.reload.primary_locale
    refute edition.available_in_locale?(:en)
  end
end
