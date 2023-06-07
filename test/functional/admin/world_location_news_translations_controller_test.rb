require "test_helper"

class Admin::WorldLocationNewsTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as_preview_design_system_user :writer
    @world_location_news = build(:world_location_news, mission_statement: "Teaching the people how to brew tea")
    @world_location = create(:world_location, name: "Afrolasia", world_location_news: @world_location_news)

    Locale.stubs(:non_english).returns([
      Locale.new(:fr), Locale.new(:es)
    ])
  end

  should_be_an_admin_controller
  should_render_bootstrap_implementation_with_preview_next_release

  view_test "index shows a form to create missing translations" do
    get :index, params: { world_location_news_id: @world_location }
    translations_path = admin_world_location_news_translations_path(@world_location)
    assert_select "form[action=?]", translations_path do
      assert_select "select[name=translation_locale]" do
        assert_select "option[value=fr]", text: "Français (French)"
        assert_select "option[value=es]", text: "Español (Spanish)"
      end

      assert_select "button[type=submit]"
    end
  end

  view_test "index does not list the english translation" do
    get :index, params: { world_location_news_id: @world_location_news }
    edit_translation_path = edit_admin_world_location_news_translation_path(@world_location, "en")
    assert_select "a[href=?]", edit_translation_path, text: "en", count: 0
  end

  test "create redirects to edit for the chosen language" do
    post :create, params: { world_location_news_id: @world_location_news, translation_locale: "fr" }
    assert_redirected_to edit_admin_world_location_news_translation_path(@world_location, id: "fr")
  end

  view_test "edit indicates which language is being translated to" do
    world_location_news = build(:world_location_news, translated_into: [:fr])
    create(:world_location, translated_into: [:fr], world_location_news:)
    get :edit, params: { world_location_news_id: @world_location_news, id: "fr" }
    assert_select "title", text: "Edit Français (French) translation for: Afrolasia - GOV.UK Whitehall Publisher"
  end

  view_test "edit presents a form to update an existing translation" do
    world_location_news = build(:world_location_news, translated_into: { fr: { mission_statement: "Enseigner aux gens comment infuser le thé" } })
    location = create(:world_location, translated_into: { fr: { name: "Afrolasie" } }, world_location_news:)

    get :edit, params: { world_location_news_id: location.world_location_news, id: "fr" }

    translation_path = admin_world_location_news_translation_path(location, "fr")
    assert_select "form[action=?]", translation_path do
      assert_select "input[name='world_location_news[world_location_attributes][name]'][value='Afrolasie']"
      assert_select "textarea[name='world_location_news[mission_statement]']", text: "Enseigner aux gens comment infuser le thé"
      assert_select "button[type=submit]"
    end
  end

  view_test "the 'View on website' link on the show page goes to the news page" do
    location = create(:world_location, translated_into: [:fr], name: "France")
    get :index, params: { world_location_news_id: location }

    assert_select "a" do |links|
      view_links = links.select { |link| link.text =~ /View on website/ }
      assert_match(/#{Regexp.escape("https://www.test.gov.uk/world/france/news")}/, view_links.first["href"])
    end
  end

  view_test "the view buttons for translations link to the new page on the live site" do
    world_location_news = build(:world_location_news, translated_into: [:fr])
    location = create(:world_location, translated_into: [:fr], name: "France", world_location_news:)
    get :index, params: { world_location_news_id: location }

    assert_select "a" do |links|
      view_links = links.select { |link| link.text =~ /View/ }
      # Selects all and selects by REGEX of 'View' third index is for the view on the table.
      assert_match(/#{Regexp.escape("https://www.test.gov.uk/world/france/news.fr")}/, view_links.third["href"])
    end
  end

  view_test "update updates translation and redirects back to the index" do
    put :update,
        params: { world_location_news_id: @world_location_news,
                  id: "fr",
                  world_location_news: {
                    mission_statement: "Enseigner aux gens comment infuser le thé",
                    world_location_attributes: {
                      id: @world_location.id,
                      name: "Afrolasie",
                    },
                  } }

    @world_location.reload
    @world_location_news.reload

    with_locale :fr do
      assert_equal "Afrolasie", @world_location.name
      assert_equal "Enseigner aux gens comment infuser le thé", @world_location_news.mission_statement
    end

    assert_redirected_to admin_world_location_news_translations_path(@world_location)
  end

  view_test "update re-renders form if translation is invalid" do
    put :update,
        params: { world_location_news_id: @world_location_news,
                  id: "fr",
                  world_location_news: {
                    mission_statement: "Enseigner aux gens comment infuser le thé",
                    world_location_attributes: {
                      id: @world_location.id,
                      name: "",
                    },
                  } }

    translation_path = admin_world_location_news_translation_path(@world_location_news, "fr")

    assert_select "form[action=?]", translation_path do
      assert_select "textarea[name='world_location_news[mission_statement]']", text: "Enseigner aux gens comment infuser le thé"
    end
  end

  test "destroy removes translation and redirects to list of translations" do
    world_location_news = build(:world_location_news, translated_into: [:fr])
    location = create(:world_location, translated_into: [:fr], world_location_news:)

    delete :destroy, params: { world_location_news_id: location.world_location_news, id: "fr" }

    location.reload
    world_location_news.reload
    assert_not location.translated_locales.include?(:fr)
    assert_not world_location_news.translated_locales.include?(:fr)
    assert_redirected_to admin_world_location_news_translations_path(location)
  end
end
