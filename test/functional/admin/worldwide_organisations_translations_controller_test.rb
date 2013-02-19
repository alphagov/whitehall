# encoding: UTF-8
require "test_helper"

class Admin::WorldwideOrganisationsTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @worldwide_organisation = create(:worldwide_organisation)

    Locale.stubs(:non_english).returns([
      Locale.new(:fr), Locale.new(:es)
    ])
  end

  should_be_an_admin_controller

  view_test 'index shows a form to create missing translations' do
    get :index, worldwide_organisation_id: @worldwide_organisation
    translations_path = admin_worldwide_organisation_translations_path(@worldwide_organisation)
    assert_select "form[action=#{CGI::escapeHTML(translations_path)}]" do
      assert_select "select[name=translation_locale]" do
        assert_select "option[value=fr]", text: 'Français (French)'
        assert_select "option[value=es]", text: 'Español (Spanish)'
      end

      assert_select "input[type=submit]"
    end
  end

  view_test 'index omits existing translations from create select' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr])
    get :index, worldwide_organisation_id: worldwide_organisation
    assert_select "select[name=translation_locale]" do
      assert_select "option[value=fr]", count: 0
    end
  end

  view_test 'index omits create form if no missing translations' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr, :es])
    get :index, worldwide_organisation_id: worldwide_organisation
    assert_select "select[name=translation_locale]", count: 0
  end

  view_test 'index lists existing translations' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr])
    get :index, worldwide_organisation_id: worldwide_organisation
    edit_translation_path = edit_admin_worldwide_organisation_translation_path(worldwide_organisation, 'fr')
    view_worldwide_organisation_path = worldwide_organisation_path(worldwide_organisation, locale: 'fr')
    assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'Français'
    assert_select "a[href=#{CGI::escapeHTML(view_worldwide_organisation_path)}]", text: 'view'
  end

  view_test 'index does not list the english translation' do
    get :index, worldwide_organisation_id: @worldwide_organisation
    edit_translation_path = edit_admin_worldwide_organisation_translation_path(@worldwide_organisation, 'en')
    assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'en', count: 0
  end

  test 'create redirects to edit for the chosen language' do
    post :create, worldwide_organisation_id: @worldwide_organisation, translation_locale: 'fr'
    assert_redirected_to edit_admin_worldwide_organisation_translation_path(@worldwide_organisation, id: 'fr')
  end

  view_test 'edit indicates which language is being translated to' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr])
    get :edit, worldwide_organisation_id: @worldwide_organisation, id: 'fr'
    assert_select "h1", text: /Edit 'Français \(French\)' translation/
  end

  view_test 'edit presents a form to update an existing translation' do
    worldwide_organisation = create(:worldwide_organisation,
      translated_into: {fr: {
        name: 'Département des barbes en France',
        summary: 'Nous nous occupons de la pilosité faciale du pays',
        description: 'Barbes, moustaches, même rouflaquettes',
        services: 'Montante, pommades, humide rase'
      }}
    )

    get :edit, worldwide_organisation_id: worldwide_organisation, id: 'fr'

    translation_path = admin_worldwide_organisation_translation_path(worldwide_organisation, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "input[type=text][name='worldwide_organisation[name]'][value='Département des barbes en France']"
      assert_select "textarea[name='worldwide_organisation[summary]']", text: 'Nous nous occupons de la pilosité faciale du pays'
      assert_select "textarea[name='worldwide_organisation[description]']", text: 'Barbes, moustaches, même rouflaquettes'
      assert_select "textarea[name='worldwide_organisation[services]']", text: 'Montante, pommades, humide rase'
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'update updates translation and redirects back to the index' do
    put :update, worldwide_organisation_id: @worldwide_organisation, id: 'fr', worldwide_organisation: {
      name: 'Département des barbes en France',
      summary: 'Nous nous occupons de la pilosité faciale du pays',
      description: 'Barbes, moustaches, même rouflaquettes',
      services: 'Montante, pommades, humide rase'
    }

    @worldwide_organisation.reload

    with_locale :fr do
      assert_equal 'Département des barbes en France', @worldwide_organisation.name
      assert_equal 'Nous nous occupons de la pilosité faciale du pays', @worldwide_organisation.summary
      assert_equal 'Barbes, moustaches, même rouflaquettes', @worldwide_organisation.description
      assert_equal 'Montante, pommades, humide rase', @worldwide_organisation.services
    end

    assert_redirected_to admin_worldwide_organisation_translations_path(@worldwide_organisation)
  end

  view_test 'update re-renders form if translation is invalid' do
    put :update, worldwide_organisation_id: @worldwide_organisation, id: 'fr', worldwide_organisation: {
      description: 'Barbes, moustaches, même rouflaquettes',
    }

    translation_path = admin_worldwide_organisation_translation_path(@worldwide_organisation, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "textarea[name='worldwide_organisation[description]']", text: 'Barbes, moustaches, même rouflaquettes'
    end
  end
end
