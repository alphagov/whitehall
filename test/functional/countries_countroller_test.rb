require "test_helper"

class CountriesControllerTest < ActionController::TestCase
  test "index should display a list of countries" do
    bat = create(:country, name: "British Antarctic Territory")
    png = create(:country, name: "Papua New Guinea")

    get :index

    assert_select ".countries" do
      assert_select_object bat
      assert_select_object png
    end
  end

  test "shows only published news articles" do
    published_document = create(:published_news_article)
    draft_document = create(:draft_news_article)
    country = create(:country, documents: [published_document, draft_document])

    get :show, id: country

    assert_select "#news_articles" do
      assert_select_object(published_document)
      refute_select_object(draft_document)
    end
  end

  test "shows only news articles associated with country" do
    published_document = create(:published_news_article)
    another_published_document = create(:published_news_article)
    country = create(:country, documents: [published_document])

    get :show, id: country

    assert_select "#news_articles" do
      assert_select_object(published_document)
      refute_select_object(another_published_document)
    end
  end

  test "shows most recent news articles at the top" do
    later_document = create(:published_news_article, published_at: 1.hour.ago)
    earlier_document = create(:published_news_article, published_at: 2.hours.ago)
    country = create(:country, documents: [earlier_document, later_document])

    get :show, id: country

    assert_equal [later_document, earlier_document], assigns[:news_articles]
  end

  test "should not display an empty published news articles section" do
    country = create(:country, documents: [])

    get :show, id: country

    refute_select "#news_articles"
  end

  test "shows only published policies" do
    published_document = create(:published_policy)
    draft_document = create(:draft_policy)
    country = create(:country, documents: [published_document, draft_document])

    get :show, id: country

    assert_select "#policies" do
      assert_select_object(published_document)
      refute_select_object(draft_document)
    end
  end

  test "shows only policies associated with country" do
    published_document = create(:published_policy)
    another_published_document = create(:published_policy)
    country = create(:country, documents: [published_document])

    get :show, id: country

    assert_select "#policies" do
      assert_select_object(published_document)
      refute_select_object(another_published_document)
    end
  end

  test "shows most recent policies at the top" do
    later_document = create(:published_policy, published_at: 1.hour.ago)
    earlier_document = create(:published_policy, published_at: 2.hours.ago)
    country = create(:country, documents: [earlier_document, later_document])

    get :show, id: country

    assert_equal [later_document, earlier_document], assigns[:policies]
  end

  test "should not display an empty published policies section" do
    country = create(:country, documents: [])

    get :show, id: country

    refute_select "#policies"
  end

  test "shows only published speeches" do
    published_document = create(:published_speech)
    draft_document = create(:draft_speech)
    country = create(:country, documents: [published_document, draft_document])

    get :show, id: country

    assert_select "#speeches" do
      assert_select_object(published_document)
      refute_select_object(draft_document)
    end
  end

  test "shows only speeches associated with country" do
    published_document = create(:published_speech)
    another_published_document = create(:published_speech)
    country = create(:country, documents: [published_document])

    get :show, id: country

    assert_select "#speeches" do
      assert_select_object(published_document)
      refute_select_object(another_published_document)
    end
  end

  test "shows most recent speeches at the top" do
    later_document = create(:published_speech, published_at: 1.hour.ago)
    earlier_document = create(:published_speech, published_at: 2.hours.ago)
    country = create(:country, documents: [earlier_document, later_document])

    get :show, id: country

    assert_equal [later_document, earlier_document], assigns[:speeches]
  end

  test "should not display an empty published speeches section" do
    country = create(:country, documents: [])

    get :show, id: country

    refute_select "#speeches"
  end

  test "shows only published publications" do
    published_document = create(:published_publication)
    draft_document = create(:draft_publication)
    country = create(:country, documents: [published_document, draft_document])

    get :show, id: country

    assert_select "#publications" do
      assert_select_object(published_document)
      refute_select_object(draft_document)
    end
  end

  test "shows only publications associated with country" do
    published_document = create(:published_publication)
    another_published_document = create(:published_publication)
    country = create(:country, documents: [published_document])

    get :show, id: country

    assert_select "#publications" do
      assert_select_object(published_document)
      refute_select_object(another_published_document)
    end
  end

  test "shows most recent publications at the top" do
    later_document = create(:published_publication, published_at: 1.hour.ago)
    earlier_document = create(:published_publication, published_at: 2.hours.ago)
    country = create(:country, documents: [earlier_document, later_document])

    get :show, id: country

    assert_equal [later_document, earlier_document], assigns[:publications]
  end

  test "should not display an empty published publications section" do
    country = create(:country, documents: [])

    get :show, id: country

    refute_select "#publications"
  end
end