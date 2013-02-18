# encoding: UTF-8
require "test_helper"

class Admin::WorldwideOfficesTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @worldwide_office = create(:worldwide_office)

    Locale.stubs(:non_english).returns([
      Locale.new(:fr), Locale.new(:es)
    ])
  end

  should_be_an_admin_controller

  view_test 'index shows a form to create missing translations' do
    get :index, worldwide_office_id: @worldwide_office
    translations_path = admin_worldwide_office_translations_path(@worldwide_office)
    assert_select "form[action=#{CGI::escapeHTML(translations_path)}]" do
      assert_select "select[name=translation_locale]" do
        assert_select "option[value=fr]", text: 'Français (French)'
        assert_select "option[value=es]", text: 'Español (Spanish)'
      end

      assert_select "input[type=submit]"
    end
  end

  view_test 'index omits existing translations from create select' do
    worldwide_office = create(:worldwide_office, translated_into: [:fr])
    get :index, worldwide_office_id: worldwide_office
    assert_select "select[name=translation_locale]" do
      assert_select "option[value=fr]", count: 0
    end
  end

  view_test 'index omits create form if no missing translations' do
    worldwide_office = create(:worldwide_office, translated_into: [:fr, :es])
    get :index, worldwide_office_id: worldwide_office
    assert_select "select[name=translation_locale]", count: 0
  end

  view_test 'index lists existing translations' do
    worldwide_office = create(:worldwide_office, translated_into: [:fr])
    get :index, worldwide_office_id: worldwide_office
    edit_translation_path = edit_admin_worldwide_office_translation_path(worldwide_office, 'fr')
    view_worldwide_office_path = worldwide_office_path(worldwide_office, locale: 'fr')
    assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'Français'
    assert_select "a[href=#{CGI::escapeHTML(view_worldwide_office_path)}]", text: 'view'
  end

  view_test 'index does not list the english translation' do
    get :index, worldwide_office_id: @worldwide_office
    edit_translation_path = edit_admin_worldwide_office_translation_path(@worldwide_office, 'en')
    assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'en', count: 0
  end

  test 'create redirects to edit for the chosen language' do
    post :create, worldwide_office_id: @worldwide_office, translation_locale: 'fr'
    assert_redirected_to edit_admin_worldwide_office_translation_path(@worldwide_office, id: 'fr')
  end

  view_test 'edit indicates which language is being translated to' do
    worldwide_office = create(:worldwide_office, translated_into: [:fr])
    get :edit, worldwide_office_id: @worldwide_office, id: 'fr'
    assert_select "h1", text: /Edit 'Français \(French\)' translation/
  end

  view_test 'edit presents a form to update an existing translation' do
    worldwide_office = create(:worldwide_office,
      translated_into: {fr: {
        name: 'Département des barbes en France',
        summary: 'Nous nous occupons de la pilosité faciale du pays',
        description: 'Barbes, moustaches, même rouflaquettes',
        services: 'Montante, pommades, humide rase'
      }}
    )

    get :edit, worldwide_office_id: worldwide_office, id: 'fr'

    translation_path = admin_worldwide_office_translation_path(worldwide_office, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "input[type=text][name='worldwide_office[name]'][value='Département des barbes en France']"
      assert_select "textarea[name='worldwide_office[summary]']", text: 'Nous nous occupons de la pilosité faciale du pays'
      assert_select "textarea[name='worldwide_office[description]']", text: 'Barbes, moustaches, même rouflaquettes'
      assert_select "textarea[name='worldwide_office[services]']", text: 'Montante, pommades, humide rase'
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'update updates translation and redirects back to the index' do
    put :update, worldwide_office_id: @worldwide_office, id: 'fr', worldwide_office: {
      name: 'Département des barbes en France',
      summary: 'Nous nous occupons de la pilosité faciale du pays',
      description: 'Barbes, moustaches, même rouflaquettes',
      services: 'Montante, pommades, humide rase'
    }

    @worldwide_office.reload

    with_locale :fr do
      assert_equal 'Département des barbes en France', @worldwide_office.name
      assert_equal 'Nous nous occupons de la pilosité faciale du pays', @worldwide_office.summary
      assert_equal 'Barbes, moustaches, même rouflaquettes', @worldwide_office.description
      assert_equal 'Montante, pommades, humide rase', @worldwide_office.services
    end

    assert_redirected_to admin_worldwide_office_translations_path(@worldwide_office)
  end

  view_test 'update re-renders form if translation is invalid' do
    put :update, worldwide_office_id: @worldwide_office, id: 'fr', worldwide_office: {
      description: 'Barbes, moustaches, même rouflaquettes',
    }

    translation_path = admin_worldwide_office_translation_path(@worldwide_office, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "textarea[name='worldwide_office[description]']", text: 'Barbes, moustaches, même rouflaquettes'
    end
  end
end
