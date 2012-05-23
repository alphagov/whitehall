require "test_helper"

class Admin::CountriesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test 'should allow modification of existing country data' do
    country = create(:country)

    get :edit, id: country

    assert_template 'countries/edit'
    assert_select "textarea[name='country[description]']"
    assert_select "textarea[name='country[about]'].previewable.govspeak"
    assert_select '#govspeak_help'
  end

  test 'updating should modify the country' do
    country = create(:country)

    put :update, id: country, country: { description: 'country-description', about: 'country-about' }

    country.reload
    assert_equal 'country-description', country.description
    assert_equal 'country-about', country.about
  end

  test "editing should display published news articles related to the country" do
    published_news_article = create(:published_news_article)
    draft_news_article = create(:draft_news_article)
    another_news_article = create(:published_news_article)
    country = create(:country, editions: [published_news_article, draft_news_article])

    get :edit, id: country

    assert_select_object(published_news_article)
    refute_select_object(draft_news_article)
    refute_select_object(another_news_article)
  end

  test "editing should display news articles most recently published first" do
    earlier_news_article = create(:published_news_article, first_published_at: 2.days.ago)
    later_news_article = create(:published_news_article, first_published_at: 1.days.ago)
    country = create(:country, editions: [earlier_news_article, later_news_article])

    get :edit, id: country

    assert_equal [later_news_article, earlier_news_article], assigns[:news_articles]
  end

  test "editing should allow non-featured published news articles to be featured" do
    published_news_article = create(:published_news_article)
    country = create(:country)
    document_country = create(:document_country, country: country, edition: published_news_article)

    get :edit, id: country

    assert_select "form[action=#{admin_document_country_path(document_country)}]" do
      assert_select "input[name='document_country[featured]'][value='true']"
    end
  end

  test "editing should allow featured published news articles to be unfeatured" do
    published_news_article = create(:published_news_article)
    country = create(:country)
    document_country = create(:document_country, country: country, edition: published_news_article, featured: true)

    get :edit, id: country

    assert_select "form[action=#{admin_document_country_path(document_country)}]" do
      assert_select "input[name='document_country[featured]'][value='false']"
    end
  end
end