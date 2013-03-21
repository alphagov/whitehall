# encoding: UTF-8
require "test_helper"

module AdminCorporateInformationPagesTranslationsControllerHelpers
  extend ActiveSupport::Concern

  def path_prefix(type, organisational_entity, corporate_information_page)
    [
      "/government/admin/#{type}s", organisational_entity.slug,
      'corporate_information_pages', corporate_information_page.slug,
        'translations'
    ].join('/')
  end

  module ClassMethods
    def should_show_list_of_corporate_information_translations_for(type)
      id_key = "#{type}_id".to_sym

      setup do
        login_as :policy_writer
        @organisational_entity = create(type)

        Locale.stubs(:non_english).returns([ Locale.new(:fr), Locale.new(:es) ])
      end

      view_test 'index shows a form to create missing translations' do
        corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity)

        get :index, id_key => @organisational_entity, corporate_information_page_id: corporate_information_page

        assert_select "form[action=#{CGI::escapeHTML(path_prefix(type, @organisational_entity, corporate_information_page))}]" do
          assert_select "select[name=translation_locale]" do
            assert_select "option[value=fr]", text: 'Français (French)'
            assert_select "option[value=es]", text: 'Español (Spanish)'
          end

          assert_select "input[type=submit]"
        end
      end

      view_test 'index omits existing translations from create select' do
        corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity, translated_into: [:fr])

        get :index, id_key => @organisational_entity, corporate_information_page_id: corporate_information_page

        assert_select "select[name=translation_locale]" do
          assert_select "option[value=fr]", count: 0
        end
      end

      view_test 'index omits create form if no missing translations' do
        corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity, translated_into: [:fr, :es])

        get :index, id_key => @organisational_entity, corporate_information_page_id: corporate_information_page

        assert_select "select[name=translation_locale]", count: 0
      end

      view_test 'index lists existing translations' do
        corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity, translated_into: [:fr])

        get :index, id_key => @organisational_entity, corporate_information_page_id: corporate_information_page

        edit_translation_path = path_prefix(type, @organisational_entity, corporate_information_page) + '/fr/edit'
        assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'Français'
      end

      view_test 'index does not list the english translation' do
        corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity)

        get :index, id_key => @organisational_entity, corporate_information_page_id: corporate_information_page

        edit_translation_path = path_prefix(type, @organisational_entity, corporate_information_page) + '/en'
        assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'en', count: 0
      end

      view_test 'index displays delete button for a translation' do
        corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity, translated_into: [:fr])

        get :index, id_key => @organisational_entity, corporate_information_page_id: corporate_information_page

        assert_select "form[action=?]", path_prefix(type, @organisational_entity, corporate_information_page) + '/fr' do
          assert_select "input[type='submit'][value=?]", "Delete"
        end
      end
    end
  end
end

class Admin::CorporateInformationPagesTranslationsControllerTest < ActionController::TestCase
  include AdminCorporateInformationPagesTranslationsControllerHelpers

  should_be_an_admin_controller
  should_show_list_of_corporate_information_translations_for :worldwide_organisation

  test 'create redirects to edit for the chosen language' do
    corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity)
    post :create, worldwide_organisation_id: @organisational_entity, corporate_information_page_id: corporate_information_page, translation_locale: 'fr'
    assert_redirected_to edit_admin_worldwide_organisation_corporate_information_page_translation_path(@organisational_entity, corporate_information_page, id: 'fr')
  end

  view_test 'edit indicates which language is being translated to' do
    corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity, translated_into: [:fr])
    get :edit, worldwide_organisation_id: @organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr'
    assert_select "h1", text: /Edit 'Français \(French\)' translation/
  end

  view_test 'edit presents a form to update an existing translation' do
    corporate_information_page = create(
      :corporate_information_page, organisation: @organisational_entity,
      translated_into: {fr: {
      summary: 'Nous nous occupons de la pilosité faciale du pays',
      body: 'Barbes, moustaches, même rouflaquettes'
    }}
    )

    get :edit, worldwide_organisation_id: @organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr'

    translation_path = admin_worldwide_organisation_corporate_information_page_translation_path(@organisational_entity, corporate_information_page, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "textarea[name='corporate_information_page[summary]']", text: 'Nous nous occupons de la pilosité faciale du pays'
      assert_select "textarea[name='corporate_information_page[body]']", text: 'Barbes, moustaches, même rouflaquettes'
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'edit presents a form respecting the RTL value of the language' do
    corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity)

    get :edit, worldwide_organisation_id: @organisational_entity, corporate_information_page_id: corporate_information_page, id: 'ar'

    assert_select "form" do
      assert_select "fieldset.right-to-left textarea[name='corporate_information_page[summary]']"
      assert_select "fieldset.right-to-left textarea[name='corporate_information_page[body]']"
    end
  end

  view_test 'update updates translation and redirects back to the index' do
    corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity)

    put :update, worldwide_organisation_id: @organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr', corporate_information_page: {
      summary: 'Nous nous occupons de la pilosité faciale du pays',
      body: 'Barbes, moustaches, même rouflaquettes'
    }

    corporate_information_page.reload

    with_locale :fr do
      assert_equal 'Nous nous occupons de la pilosité faciale du pays', corporate_information_page.summary
      assert_equal 'Barbes, moustaches, même rouflaquettes', corporate_information_page.body
    end

    assert_redirected_to admin_worldwide_organisation_corporate_information_page_translations_path(@organisational_entity, corporate_information_page)
  end

  view_test 'update re-renders form if translation is invalid' do
    corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity)

    put :update, worldwide_organisation_id: @organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr', corporate_information_page: {
      body: '',
      summary: 'Barbes, moustaches, même rouflaquettes'
    }

    translation_path = admin_worldwide_organisation_corporate_information_page_translation_path(@organisational_entity, corporate_information_page, 'fr')

    assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
      assert_select "textarea[name='corporate_information_page[summary]']", text: 'Barbes, moustaches, même rouflaquettes'
    end
  end

  test 'destroy removes translation and redirects to list of translations' do
    corporate_information_page = create(:corporate_information_page, organisation: @organisational_entity, translated_into: [:fr])

    delete :destroy, worldwide_organisation_id: @organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr'

    corporate_information_page.reload
    refute corporate_information_page.translated_locales.include?(:fr)
    assert_redirected_to admin_worldwide_organisation_corporate_information_page_translations_path(@organisational_entity, corporate_information_page)
  end
end


