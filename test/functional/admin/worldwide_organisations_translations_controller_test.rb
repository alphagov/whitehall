# encoding: UTF-8

require "test_helper"

class Admin::WorldwideOrganisationsTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @worldwide_organisation = create(:worldwide_organisation)

    Locale.stubs(:non_english).returns([
      Locale.new(:fr), Locale.new(:es)
    ])
  end

  should_be_an_admin_controller

  view_test 'index shows a form to create missing translations' do
    get :index, params: { worldwide_organisation_id: @worldwide_organisation }
    translations_path = admin_worldwide_organisation_translations_path(@worldwide_organisation)
    assert_select "form[action=?]", translations_path do
      assert_select "select[name=translation_locale]" do
        assert_select "option[value=fr]", text: 'Français (French)'
        assert_select "option[value=es]", text: 'Español (Spanish)'
      end

      assert_select "input[type=submit]"
    end
  end

  view_test 'index omits existing translations from create select' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr])
    get :index, params: { worldwide_organisation_id: worldwide_organisation }
    assert_select "select[name=translation_locale]" do
      assert_select "option[value=fr]", count: 0
    end
  end

  view_test 'index omits create form if no missing translations' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: %i[fr es])
    get :index, params: { worldwide_organisation_id: worldwide_organisation }
    assert_select "select[name=translation_locale]", count: 0
  end

  view_test 'index lists existing translations' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr])
    get :index, params: { worldwide_organisation_id: worldwide_organisation }
    edit_translation_path = edit_admin_worldwide_organisation_translation_path(worldwide_organisation, 'fr')
    view_worldwide_organisation_path = worldwide_organisation_path(worldwide_organisation, locale: 'fr')
    assert_select "a[href=?]", edit_translation_path, text: 'Français'
    assert_select "a[href=?]", view_worldwide_organisation_path, text: 'view'
  end

  view_test 'index does not list the english translation' do
    get :index, params: { worldwide_organisation_id: @worldwide_organisation }
    edit_translation_path = edit_admin_worldwide_organisation_translation_path(@worldwide_organisation, 'en')
    assert_select "a[href=?]", edit_translation_path, text: 'en', count: 0
  end

  view_test 'index displays delete button for a translation' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr])

    get :index, params: { worldwide_organisation_id: worldwide_organisation }

    assert_select "form[action=?]", admin_worldwide_organisation_translation_path(worldwide_organisation, 'fr') do
      assert_select "input[type='submit'][value=?]", "Delete"
    end
  end

  test 'create redirects to edit for the chosen language' do
    post :create, params: { worldwide_organisation_id: @worldwide_organisation, translation_locale: 'fr' }
    assert_redirected_to edit_admin_worldwide_organisation_translation_path(@worldwide_organisation, id: 'fr')
  end

  view_test 'edit indicates which language is being translated to' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr])
    get :edit, params: { worldwide_organisation_id: @worldwide_organisation, id: 'fr' }
    assert_select "h1", text: /Edit ‘Français \(French\)’ translation/
  end

  view_test 'edit presents a form to update an existing translation' do
    worldwide_organisation = create(:worldwide_organisation,
      translated_into: { fr: {
        name: 'Département des barbes en France',
      } })

    get :edit, params: { worldwide_organisation_id: worldwide_organisation, id: 'fr' }

    translation_path = admin_worldwide_organisation_translation_path(worldwide_organisation, 'fr')

    assert_select "form[action=?]", translation_path do
      assert_select "input[type=text][name='worldwide_organisation[name]'][value='Département des barbes en France']"
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'edit presents a form respecting the RTL value of the language' do
    worldwide_organisation = create(:worldwide_organisation)

    get :edit, params: { worldwide_organisation_id: worldwide_organisation, id: 'ar' }

    assert_select "form" do
      assert_select "fieldset.right-to-left input[type=text][name='worldwide_organisation[name]']"
    end
  end

  view_test 'update updates translation and redirects back to the index' do
    put :update, params: { worldwide_organisation_id: @worldwide_organisation, id: 'fr', worldwide_organisation: {
      name: 'Département des barbes en France',
    } }

    @worldwide_organisation.reload

    with_locale :fr do
      assert_equal 'Département des barbes en France', @worldwide_organisation.name
    end

    assert_redirected_to admin_worldwide_organisation_translations_path(@worldwide_organisation)
  end

  view_test 'update re-renders form if translation is invalid' do
    put :update, params: { worldwide_organisation_id: @worldwide_organisation, id: 'fr', worldwide_organisation: {
      name: '',
    } }

    refute @worldwide_organisation.available_in_locale?('fr')
    translation_path = admin_worldwide_organisation_translation_path(@worldwide_organisation, 'fr')
    assert_select "form[action=?]", translation_path
  end

  test 'destroy removes translation and redirects to list of translations' do
    worldwide_organisation = create(:worldwide_organisation, translated_into: [:fr])

    delete :destroy, params: { worldwide_organisation_id: worldwide_organisation, id: 'fr' }

    worldwide_organisation.reload
    refute worldwide_organisation.translated_locales.include?(:fr)
    assert_redirected_to admin_worldwide_organisation_translations_path(worldwide_organisation)
  end
end
