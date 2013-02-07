# encoding: UTF-8
require "test_helper"

class Admin::WorldLocationTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @location = create(:country, name: 'Afrolasia', mission_statement: 'Teaching the people how to brew tea')
  end

  should_be_an_admin_controller

  test 'index shows a link to add a new translation' do
    get :index, world_location_id: @location
    new_translation_path = new_admin_world_location_translation_path(@location)
    assert_select "a[href=#{CGI::escapeHTML(new_translation_path)}]", text: "Create Translation"
  end

  test 'new presents a form to create a new translation' do
    I18n.stubs(:available_locales).returns([:en, :es, :fr, :ar])

    get :new, world_location_id: @location
    translations_path = admin_world_location_translations_path(@location)

    assert_select "form[action=#{CGI::escapeHTML(translations_path)}]" do
      assert_select "select[name='translation_locale']" do
        assert_select "option[value=es]"
        assert_select "option[value=fr]"
        assert_select "option[value=ar]"
      end

      assert_select "input[type=text][name='world_location[name]']"
      assert_select "textarea[name='world_location[mission_statement]']"
      assert_select "input[type=submit][value=Save]"
    end
  end

  test 'new does not provide en as a choice of locale' do
    I18n.stubs(:available_locales).returns([:en, :es, :fr, :ar])

    get :new, world_location_id: @location

    assert_select "select[name='translation_locale']" do
      assert_select "option[value=en]", count: 0
    end
  end

  test 'create adds a new translation and redirects back to the index' do
    post :create, world_location_id: @location, translation_locale: 'fr', world_location: {
      name: 'Afrolasie',
      mission_statement: 'Enseigner aux gens comment infuser le thé'
    }

    @location.reload

    I18n.with_locale :fr do
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

    I18n.with_locale :en do
      assert_equal 'Afrolasia', @location.name
      assert_equal 'Teaching the people how to brew tea', @location.mission_statement
    end
  end

  test 'create renders the form again if the translation is invalid' do
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
end
