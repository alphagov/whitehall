require 'test_helper'

class Admin::WorldLocationNewsArticlesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    edition = create(:world_location_news_article, :with_document, primary_locale: :fr)
    edition.document.update_attribute(:slug, '')
    edition2 = create(:world_location_news_article, :with_document, primary_locale: :fr)
  end

  should_be_an_admin_controller

  test 'POST :create for a non-English edition saves it as a non-English edition' do
    world_location = create(:world_location)
    worldwide_organisation = create(:worldwide_organisation)
    post :create, edition: {  lock_version: 0,
                              title: 'French title',
                              summary: 'Summary',
                              body: 'Body',
                              primary_locale: 'fr',
                              world_location_ids: [world_location.id],
                              worldwide_organisation_ids: [worldwide_organisation.id]
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
end
