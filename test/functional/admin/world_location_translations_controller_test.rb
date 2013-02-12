# encoding: UTF-8
require "test_helper"

class Admin::WorldLocationTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @location = create(:country, name: 'Afrolasia', mission_statement: 'Teaching the people how to brew tea')
  end

  should_be_an_admin_controller

  view_test 'index shows a link to add a new translation' do
    get :index, world_location_id: @location
    new_translation_path = new_admin_world_location_translation_path(@location)
    assert_select "a[href=#{CGI::escapeHTML(new_translation_path)}]", text: "Create Translation"
  end

  view_test 'index lists existing translations' do
    @location.translations.create!(name: 'Afrolasie', locale: 'fr', mission_statement: 'Enseigner aux gens comment infuser le thé')
    get :index, world_location_id: @location
    edit_translation_path = edit_admin_world_location_translation_path(@location, 'fr')
    assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'fr'
  end

  view_test 'index does not list english' do
    get :index, world_location_id: @location
    edit_translation_path = edit_admin_world_location_translation_path(@location, 'en')
    assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'en', count: 0
  end

  view_test 'new presents a form to create a new translation' do
    I18n.stubs(:available_locales).returns([:en, :es, :fr, :ar])

    get :new, world_location_id: @location
    translations_path = admin_world_location_translations_path(@location)

    assert_select "form[action=#{CGI::escapeHTML(translations_path)}]" do
      assert_select "select[name='translation_locale']" do
        assert_select "option[value=es]"
        assert_select "option[value=fr]"
        assert_select "option[value=ar]"
      end

      assert_select "fieldset" do
        assert_select "input[type=text][name='world_location[name]']"
        assert_select ".original-translation", text: "English: Afrolasia"
      end

      assert_select "fieldset" do
        assert_select "textarea[name='world_location[mission_statement]']"
        assert_select ".original-translation", text: "English: Teaching the people how to brew tea"
      end
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'new does not provide en as a choice of locale' do
    I18n.stubs(:available_locales).returns([:en, :es, :fr, :ar])

    get :new, world_location_id: @location

    assert_select "select[name='translation_locale']" do
      assert_select "option[value=en]", count: 0
    end
  end

  view_test 'create adds a new translation and redirects back to the index' do
    post :create, world_location_id: @location, translation_locale: 'fr', world_location: {
      name: 'Afrolasie',
      mission_statement: 'Enseigner aux gens comment infuser le thé'
    }

    @location.reload

    with_locale :fr do
      assert_equal 'Afrolasie', @location.name
      assert_equal 'Enseigner aux gens comment infuser le thé', @location.mission_statement
    end

    assert_redirected_to admin_world_location_translations_path(@location)
  end

  test 'create leaves existing translation untouched' do
    post :create, world_location_id: @location, translation_locale: 'fr', world_location: {
      name: 'Afrolasie',
      mission_statement: 'Enseigner aux gens comment infuser le thé'
    }

    @location.reload

    with_locale :en do
      assert_equal 'Afrolasia', @location.name
      assert_equal 'Teaching the people how to brew tea', @location.mission_statement
    end
  end

  view_test 'create renders the form again if the translation is invalid' do
    I18n.stubs(:available_locales).returns([:en, :es, :fr, :ar])

    post :create, world_location_id: @location, translation_locale: 'fr', world_location: {
      name: nil,
      mission_statement: 'Enseigner aux gens comment infuser le thé'
    }

    translations_path = admin_world_location_translations_path(@location)

    assert_select "form[action=#{CGI::escapeHTML(translations_path)}]" do
      assert_select "select[name='translation_locale']" do
        assert_select "option[value=es]"
        assert_select "option[value=fr][selected=selected]"
        assert_select "option[value=ar]"
      end

      assert_select "textarea[name='world_location[mission_statement]']", text: 'Enseigner aux gens comment infuser le thé'
    end
  end

  view_test 'edit presents a form to update an existing translation' do
    @location.translations.create!(name: 'Afrolasie', locale: 'fr', mission_statement: 'Enseigner aux gens comment infuser le thé')

    get :edit, world_location_id: @location, id: 'fr'

    translation_path = admin_world_location_translation_path(@location, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "select[name='translation_locale'][disabled=disabled]"
      assert_select "input[type=text][name='world_location[name]'][value='Afrolasie']"
      assert_select "textarea[name='world_location[mission_statement]']", text: 'Enseigner aux gens comment infuser le thé'
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'update updates translation and redirects back to the index' do
    put :update, world_location_id: @location, id: 'fr', world_location: {
      name: 'Afrolasie',
      mission_statement: 'Enseigner aux gens comment infuser le thé'
    }

    @location.reload

    with_locale :fr do
      assert_equal 'Afrolasie', @location.name
      assert_equal 'Enseigner aux gens comment infuser le thé', @location.mission_statement
    end

    assert_redirected_to admin_world_location_translations_path(@location)
  end

  view_test 'update re-renders form if translation is invalid' do
    put :update, world_location_id: @location, id: 'fr', world_location: {
      mission_statement: 'Enseigner aux gens comment infuser le thé'
    }

    translation_path = admin_world_location_translation_path(@location, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "textarea[name='world_location[mission_statement]']", text: 'Enseigner aux gens comment infuser le thé'
    end
  end
end
