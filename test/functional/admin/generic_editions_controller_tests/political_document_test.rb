require 'test_helper'

class Admin::GenericEditionsController::PolticalDocumentsTest < ActionController::TestCase
  tests Admin::NewsArticlesController

  setup do
    login_as :writer
  end

  view_test "displays the political checkbox for privileged users " do
    create(:current_government)
    login_as :managing_editor
    published_edition = create(:published_news_article, first_published_at: 2.days.ago)
    new_draft = create(:news_article, document: published_edition.document, first_published_at: 2.days.ago)
    get :edit, params: { id: new_draft }
    assert_select '.political-status', count: 1
  end

  view_test "doesn't display the political checkbox for non-privileged users " do
    published_edition = create(:published_news_article)
    new_draft = create(:news_article, document: published_edition.document)
    get :edit, params: { id: new_draft }
    assert_select '.political-status', count: 0
  end

  view_test "doesn't display the political checkbox on creation" do
    login_as :managing_editor
    get :new
    assert_select '.political-status', count: 0
  end

  view_test "doesn't let non-gds users edit historic documents" do
    create(:previous_government, name: 'old')
    create(:current_government, name: 'new')

    login_as :managing_editor

    published_edition = create(:published_news_article, first_published_at: 3.years.ago)
    new_draft = create(:news_article, political: true, first_published_at: 3.years.ago, document: published_edition.document)

    get :edit, params: { id: new_draft }

    assert_response :redirect
  end

  view_test "lets gds users edit historic documents" do
    create(:previous_government, name: 'old')
    create(:current_government, name: 'new')

    login_as :gds_editor

    published_edition = create(:published_news_article)
    new_draft = create(:news_article, political: true, first_published_at: 3.years.ago, document: published_edition.document)

    get :edit, params: { id: new_draft }

    assert_response :success
  end
end
