# encoding: UTF-8
require "test_helper"

class Admin::WorldLocationTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @location = create(:world_location, name: 'Afrolasia', mission_statement: 'Teaching the people how to brew tea')

    Locale.stubs(:non_english).returns([
      Locale.new(:fr), Locale.new(:es)
    ])

    WorldLocationNewsPageWorker.any_instance.stubs(:perform).returns(true)
  end

  should_be_an_admin_controller

  view_test 'index shows a form to create missing translations' do
    get :index, params: { world_location_id: @location }
    translations_path = admin_world_location_translations_path(@location)
    assert_select "form[action=?]", translations_path do
      assert_select "select[name=translation_locale]" do
        assert_select "option[value=fr]", text: 'Français (French)'
        assert_select "option[value=es]", text: 'Español (Spanish)'
      end

      assert_select "input[type=submit]"
    end
  end

  view_test 'index does not list the english translation' do
    get :index, params: { world_location_id: @location }
    edit_translation_path = edit_admin_world_location_translation_path(@location, 'en')
    assert_select "a[href=?]", edit_translation_path, text: 'en', count: 0
  end

  test 'create redirects to edit for the chosen language' do
    post :create, params: { world_location_id: @location, translation_locale: 'fr' }
    assert_redirected_to edit_admin_world_location_translation_path(@location, id: 'fr')
  end

  view_test 'edit indicates which language is being translated to' do
    location = create(:world_location, translated_into: [:fr])
    get :edit, params: { world_location_id: @location, id: 'fr' }
    assert_select "h1", text: /Edit ‘Français \(French\)’ translation/
  end

  view_test 'edit presents a form to update an existing translation' do
    location = create(:world_location, translated_into: {fr: {name: 'Afrolasie', mission_statement: 'Enseigner aux gens comment infuser le thé'}})

    get :edit, params: { world_location_id: location, id: 'fr' }

    translation_path = admin_world_location_translation_path(location, 'fr')

    assert_select "form[action=?]", translation_path do
      assert_select "input[type=text][name='world_location[name]'][value='Afrolasie']"
      assert_select "textarea[name='world_location[mission_statement]']", text: 'Enseigner aux gens comment infuser le thé'
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'edit form adds right-to-left class and dir attribute for text field and areas in right-to-left languages' do
    location = create(:world_location, translated_into: {ar: {name: 'الناس', mission_statement: 'تعليم الناس كيفية تحضير الشاي'}})

    get :edit, params: { world_location_id: location, id: 'ar' }

    translation_path = admin_world_location_translation_path(location, 'ar')

    assert_select "form[action=?]", translation_path do
      assert_select "fieldset[class='right-to-left']" do
        assert_select "input[type=text][name='world_location[name]'][dir='rtl'][value='الناس']"
      end
      assert_select "fieldset[class='right-to-left']" do
        assert_select "textarea[name='world_location[mission_statement]'][dir='rtl']", text: 'تعليم الناس كيفية تحضير الشاي'
      end
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'update updates translation and redirects back to the index' do
    put :update, params: { world_location_id: @location, id: 'fr', world_location: {
      name: 'Afrolasie',
      mission_statement: 'Enseigner aux gens comment infuser le thé'
    } }

    @location.reload

    with_locale :fr do
      assert_equal 'Afrolasie', @location.name
      assert_equal 'Enseigner aux gens comment infuser le thé', @location.mission_statement
    end

    assert_redirected_to admin_world_location_translations_path(@location)
  end

  view_test 'update re-renders form if translation is invalid' do
    put :update, params: { world_location_id: @location, id: 'fr', world_location: {
      name: '',
      mission_statement: 'Enseigner aux gens comment infuser le thé'
    } }

    translation_path = admin_world_location_translation_path(@location, 'fr')

    assert_select "form[action=?]", translation_path do
      assert_select "textarea[name='world_location[mission_statement]']", text: 'Enseigner aux gens comment infuser le thé'
    end
  end

  test 'destroy removes translation and redirects to list of translations' do
    location = create(:world_location, translated_into: [:fr])

    delete :destroy, params: { world_location_id: location, id: 'fr' }

    location.reload
    refute location.translated_locales.include?(:fr)
    assert_redirected_to admin_world_location_translations_path(location)
  end
end
