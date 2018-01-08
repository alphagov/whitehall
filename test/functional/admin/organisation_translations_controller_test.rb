# encoding: UTF-8

require "test_helper"

class Admin::OrganisationTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
    @organisation = create(:organisation, name: 'Afrolasia Office')

    Locale.stubs(:non_english).returns([
      Locale.new(:fr), Locale.new(:es)
    ])
  end

  should_be_an_admin_controller

  view_test 'index shows a form to create missing translations' do
    get :index, params: { organisation_id: @organisation }
    translations_path = admin_organisation_translations_path(@organisation)
    assert_select "form[action=?]", translations_path do
      assert_select "select[name=translation_locale]" do
        assert_select "option[value=fr]", text: 'Français (French)'
        assert_select "option[value=es]", text: 'Español (Spanish)'
      end

      assert_select "input[type=submit]"
    end
  end

  view_test 'index omits existing translations from create select' do
    organisation = create(:organisation, translated_into: [:fr])
    get :index, params: { organisation_id: organisation }
    assert_select "select[name=translation_locale]" do
      assert_select "option[value=fr]", count: 0
    end
  end

  view_test 'index omits create form if no missing translations' do
    organisation = create(:organisation, translated_into: [:fr, :es])
    get :index, params: { organisation_id: organisation }
    assert_select "select[name=translation_locale]", count: 0
  end

  view_test 'index lists existing translations' do
    organisation = create(:organisation, translated_into: [:fr])
    get :index, params: { organisation_id: organisation }
    edit_translation_path = edit_admin_organisation_translation_path(organisation, 'fr')
    view_organisation_path = organisation_path(organisation, locale: 'fr')
    assert_select "a[href=?]", edit_translation_path, text: 'Français'
    assert_select "a[href=?]", view_organisation_path, text: 'view'
  end

  view_test 'index does not list the english translation' do
    get :index, params: { organisation_id: @organisation }
    edit_translation_path = edit_admin_organisation_translation_path(@organisation, 'en')
    assert_select "a[href=?]", edit_translation_path, text: 'en', count: 0
  end

  view_test 'index displays delete button for a translation' do
    organisation = create(:organisation, translated_into: [:fr])
    get :index, params: { organisation_id: organisation }
    assert_select "form[action=?]", admin_organisation_translation_path(organisation, :fr) do
      assert_select "input[type='submit'][value=?]", "Delete"
    end
  end

  test 'create redirects to edit for the chosen language' do
    post :create, params: { organisation_id: @organisation, translation_locale: 'fr' }
    assert_redirected_to edit_admin_organisation_translation_path(@organisation, id: 'fr')
  end

  view_test 'edit indicates which language is being translated to' do
    organisation = create(:organisation, translated_into: [:fr])
    get :edit, params: { organisation_id: @organisation, id: 'fr' }
    assert_select "h1", text: /Edit ‘Français \(French\)’ translation/
  end

  view_test 'edit presents a form to update an existing translation' do
    organisation = create(:organisation, translated_into: {
      fr: { name: 'Afrolasie',
            acronym: 'AFRO',
            logo_formatted_name: 'Afrolasie',
          }
    })

    get :edit, params: { organisation_id: organisation, id: 'fr' }

    translation_path = admin_organisation_translation_path(organisation, 'fr')

    assert_select "form[action=?]", translation_path do
      assert_select "input[type=text][name='organisation[name]'][value='Afrolasie']"
      assert_select "input[type=text][name='organisation[acronym]'][value='AFRO']"
      assert_select "textarea[name='organisation[logo_formatted_name]']", text: 'Afrolasie'
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'edit form adds right-to-left class and dir attribute for text field and areas in right-to-left languages' do
    organisation = create(:organisation, translated_into: {ar: {name: 'الناس'}})

    get :edit, params: { organisation_id: organisation, id: 'ar' }

    translation_path = admin_organisation_translation_path(organisation, 'ar')

    assert_select "form[action=?]", translation_path do
      assert_select "fieldset[class='right-to-left']" do
        assert_select "input[type=text][name='organisation[name]'][dir='rtl'][value='الناس']"
      end
      assert_select "input[type=submit][value=Save]"
    end
  end

  test 'update updates translation and redirects back to the index' do
    put :update, params: { organisation_id: @organisation, id: 'fr', organisation: {
        name: 'Afrolasie Bureau',
        acronym: 'AFRO',
        logo_formatted_name: 'Afrolasie Bureau',
      } }

    @organisation.reload

    with_locale :fr do
      assert_equal 'Afrolasie Bureau', @organisation.name
      assert_equal 'AFRO', @organisation.acronym
      assert_equal 'Afrolasie Bureau', @organisation.logo_formatted_name
    end

    assert_redirected_to admin_organisation_translations_path(@organisation)
  end

  view_test 'update re-renders form if translation is invalid' do
    put :update, params: { organisation_id: @organisation, id: 'fr', organisation: {
        name: 'Afrolasie Bureau',
        logo_formatted_name: '',
      } }

    refute @organisation.available_in_locale?('fr')
    translation_path = admin_organisation_translation_path(@organisation, 'fr')
    assert_select "form[action=?]", translation_path
  end

  test 'destroy removes translation and redirects to list of translations' do
    organisation = create(:organisation, translated_into: [:fr])

    delete :destroy, params: { organisation_id: organisation, id: 'fr' }

    organisation.reload
    refute organisation.translated_locales.include?(:fr)
    assert_redirected_to admin_organisation_translations_path(organisation)
  end
end
