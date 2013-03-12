# encoding: UTF-8
require "test_helper"

class Admin::OrganisationTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
    @organisation = create(:organisation, name: 'Afrolasia Office', description: 'Teaching the people how to brew tea')

    Locale.stubs(:non_english).returns([
      Locale.new(:fr), Locale.new(:es)
    ])
  end

  should_be_an_admin_controller

  view_test 'index shows a form to create missing translations' do
    get :index, organisation_id: @organisation
    translations_path = admin_organisation_translations_path(@organisation)
    assert_select "form[action=#{CGI::escapeHTML(translations_path)}]" do
      assert_select "select[name=translation_locale]" do
        assert_select "option[value=fr]", text: 'Français (French)'
        assert_select "option[value=es]", text: 'Español (Spanish)'
      end

      assert_select "input[type=submit]"
    end
  end

  view_test 'index omits existing translations from create select' do
    organisation = create(:organisation, translated_into: [:fr])
    get :index, organisation_id: organisation
    assert_select "select[name=translation_locale]" do
      assert_select "option[value=fr]", count: 0
    end
  end

  view_test 'index omits create form if no missing translations' do
    organisation = create(:organisation, translated_into: [:fr, :es])
    get :index, organisation_id: organisation
    assert_select "select[name=translation_locale]", count: 0
  end

  view_test 'index lists existing translations' do
    organisation = create(:organisation, translated_into: [:fr])
    get :index, organisation_id: organisation
    edit_translation_path = edit_admin_organisation_translation_path(organisation, 'fr')
    view_organisation_path = organisation_path(organisation, locale: 'fr')
    assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'Français'
    assert_select "a[href=#{CGI::escapeHTML(view_organisation_path)}]", text: 'view'
  end

  view_test 'index does not list the english translation' do
    get :index, organisation_id: @organisation
    edit_translation_path = edit_admin_organisation_translation_path(@organisation, 'en')
    assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'en', count: 0
  end

  view_test 'index displays delete button for a translation' do
    organisation = create(:organisation, translated_into: [:fr])
    get :index, organisation_id: organisation
    assert_select "form[action=?]", admin_organisation_translation_path(organisation, :fr) do
      assert_select "input[type='submit'][value=?]", "Delete"
    end
  end

  test 'create redirects to edit for the chosen language' do
    post :create, organisation_id: @organisation, translation_locale: 'fr'
    assert_redirected_to edit_admin_organisation_translation_path(@organisation, id: 'fr')
  end

  view_test 'edit indicates which language is being translated to' do
    organisation = create(:organisation, translated_into: [:fr])
    get :edit, organisation_id: @organisation, id: 'fr'
    assert_select "h1", text: /Edit 'Français \(French\)' translation/
  end

  view_test 'edit presents a form to update an existing translation' do
    organisation = create(:organisation, translated_into: {
      fr: { name: 'Afrolasie',
            acronym: 'AFRO',
            logo_formatted_name: 'Afrolasie',
            description: 'Enseigner aux gens comment infuser le thé',
            about_us: 'Tout à propos de la façon dont nous enseignons aux gens pour infuser le thé'
          }
    })

    get :edit, organisation_id: organisation, id: 'fr'

    translation_path = admin_organisation_translation_path(organisation, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "input[type=text][name='organisation[name]'][value='Afrolasie']"
      assert_select "input[type=text][name='organisation[acronym]'][value='AFRO']"
      assert_select "textarea[name='organisation[logo_formatted_name]']", text: 'Afrolasie'
      assert_select "textarea[name='organisation[description]']", text: 'Enseigner aux gens comment infuser le thé'
      assert_select "textarea[name='organisation[about_us]']", text: 'Tout à propos de la façon dont nous enseignons aux gens pour infuser le thé'
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'edit form adds right-to-left class and dir attribute for text field and areas in right-to-left languages' do
    organisation = create(:organisation, translated_into: {ar: {name: 'الناس', description: 'تعليم الناس كيفية تحضير الشاي'}})

    get :edit, organisation_id: organisation, id: 'ar'

    translation_path = admin_organisation_translation_path(organisation, 'ar')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "fieldset[class='right-to-left']" do
        assert_select "input[type=text][name='organisation[name]'][dir='rtl'][value='الناس']"
      end
      assert_select "fieldset[class='right-to-left']" do
        assert_select "textarea[name='organisation[description]'][dir='rtl']", text: 'تعليم الناس كيفية تحضير الشاي'
      end
      assert_select "input[type=submit][value=Save]"
    end
  end

  test 'update updates translation and redirects back to the index' do
    put :update, organisation_id: @organisation, id: 'fr',
      organisation: {
        name: 'Afrolasie Bureau',
        acronym: 'AFRO',
        logo_formatted_name: 'Afrolasie Bureau',
        description: 'Enseigner aux gens comment infuser le thé',
        about_us: 'Tout à propos de la façon dont nous enseignons aux gens pour infuser le thé'
      }

    @organisation.reload

    with_locale :fr do
      assert_equal 'Afrolasie Bureau', @organisation.name
      assert_equal 'AFRO', @organisation.acronym
      assert_equal 'Afrolasie Bureau', @organisation.logo_formatted_name
      assert_equal 'Enseigner aux gens comment infuser le thé', @organisation.description
      assert_equal 'Tout à propos de la façon dont nous enseignons aux gens pour infuser le thé', @organisation.about_us
    end

    assert_redirected_to admin_organisation_translations_path(@organisation)
  end

  view_test 'update re-renders form if translation is invalid' do
    put :update, organisation_id: @organisation, id: 'fr',
      organisation: {
        name: 'Afrolasie Bureau',
        logo_formatted_name: '',
        description: 'Enseigner aux gens comment infuser le thé',
      }

    translation_path = admin_organisation_translation_path(@organisation, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "textarea[name='organisation[description]']", text: 'Enseigner aux gens comment infuser le thé'
    end
  end

  test 'destroy removes translation and redirects to list of translations' do
    organisation = create(:organisation, translated_into: [:fr])

    delete :destroy, organisation_id: organisation, id: 'fr'

    organisation.reload
    refute organisation.translated_locales.include?(:fr)
    assert_redirected_to admin_organisation_translations_path(organisation)
  end
end
