require "test_helper"

class CountriesControllerTest < ActionController::TestCase

  def self.should_show_associated_published(plural)
    singular = plural.to_s.singularize
    test "shows only published #{plural.to_s.humanize}" do
      published_document = create("published_#{singular}")
      draft_document = create("draft_#{singular}")
      country = create(:country, documents: [published_document, draft_document])

      get :show, id: country

      assert_select "##{plural}" do
        assert_select_object(published_document)
        refute_select_object(draft_document)
      end
    end

    test "shows only #{plural.to_s.humanize} associated with country" do
      published_document = create("published_#{singular}")
      another_published_document = create("published_#{singular}")
      country = create(:country, documents: [published_document])

      get :show, id: country

      assert_select "##{plural}" do
        assert_select_object(published_document)
        refute_select_object(another_published_document)
      end
    end

    test "shows most recent #{plural.to_s.humanize} at the top" do
      later_document = create("published_#{singular}", published_at: 1.hour.ago)
      earlier_document = create("published_#{singular}", published_at: 2.hours.ago)
      country = create(:country, documents: [earlier_document, later_document])

      get :show, id: country

      assert_equal [later_document, earlier_document], assigns[plural]
    end

    test "should not display an empty published #{plural.to_s.humanize} section" do
      country = create(:country, documents: [])

      get :show, id: country

      refute_select "##{plural}"
    end
  end

  should_show_associated_published :news_articles
  should_show_associated_published :policies
  should_show_associated_published :speeches
  should_show_associated_published :publications
  should_show_associated_published :international_priorities

  test "index should display a list of countries" do
    bat = create(:country, name: "British Antarctic Territory")
    png = create(:country, name: "Papua New Guinea")

    get :index

    assert_select ".countries" do
      assert_select_object bat
      assert_select_object png
    end
  end
end
