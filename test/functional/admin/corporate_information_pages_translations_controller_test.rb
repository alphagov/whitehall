# encoding: UTF-8
require "test_helper"

module AdminCorporateInformationPagesTranslationsControllerHelpers
  extend ActiveSupport::Concern

  def path_prefix(type, organisational_entity, corporate_information_page)
    [
      "/government/admin/#{type}s", organisational_entity.slug,
      'corporate_information_pages', corporate_information_page.id,
        'translations'
    ].join('/')
  end

  module ClassMethods
    def should_show_list_of_corporate_information_translations_for(type)
      id_key = "#{type}_id".to_sym

      setup do
        login_as :policy_writer
        Locale.stubs(:non_english).returns([ Locale.new(:fr), Locale.new(:es) ])
      end

      view_test "#{type}: index shows a form to create missing translations" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity)

        get :index, id_key => organisational_entity, corporate_information_page_id: corporate_information_page

        assert_select "form[action=#{CGI::escapeHTML(path_prefix(type, organisational_entity, corporate_information_page))}]" do
          assert_select "select[name=translation_locale]" do
            assert_select "option[value=fr]", text: 'Français (French)'
            assert_select "option[value=es]", text: 'Español (Spanish)'
          end

          assert_select "input[type=submit]"
        end
      end

      view_test "#{type}: index omits existing translations from create select" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity, translated_into: [:fr])

        get :index, id_key => organisational_entity, corporate_information_page_id: corporate_information_page

        assert_select "select[name=translation_locale]" do
          assert_select "option[value=fr]", count: 0
        end
      end

      view_test "#{type}: index omits create form if no missing translations" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity, translated_into: [:fr, :es])

        get :index, id_key => organisational_entity, corporate_information_page_id: corporate_information_page

        assert_select "select[name=translation_locale]", count: 0
      end

      view_test "#{type}: index lists existing translations" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity, translated_into: [:fr])

        get :index, id_key => organisational_entity, corporate_information_page_id: corporate_information_page

        edit_translation_path = path_prefix(type, organisational_entity, corporate_information_page) + '/fr/edit'
        assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'Français'
      end

      view_test "#{type}: index does not list the english translation" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity)

        get :index, id_key => organisational_entity, corporate_information_page_id: corporate_information_page

        edit_translation_path = path_prefix(type, organisational_entity, corporate_information_page) + '/en'
        assert_select "a[href=#{CGI::escapeHTML(edit_translation_path)}]", text: 'en', count: 0
      end

      view_test "#{type}: index displays delete button for a translation" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity, translated_into: [:fr])

        get :index, id_key => organisational_entity, corporate_information_page_id: corporate_information_page

        assert_select "form[action=?]", path_prefix(type, organisational_entity, corporate_information_page) + '/fr' do
          assert_select "input[type='submit'][value=?]", "Delete"
        end
      end

      test "#{type}: create redirects to edit for the chosen language" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity)
        post :create, id_key => organisational_entity, corporate_information_page_id: corporate_information_page, translation_locale: 'fr'
        assert_redirected_to path_prefix(type, organisational_entity, corporate_information_page) + '/fr/edit'
      end

      view_test "#{type}: edit indicates which language is being translated to" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity, translated_into: [:fr])
        get :edit, id_key => organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr'
        assert_select "h1", text: /Edit 'Français \(French\)' translation/
      end

      view_test "#{type}: edit presents a form to update an existing translation" do
        organisational_entity = create(type)
        corporate_information_page = create(
          :corporate_information_page, organisation: organisational_entity,
          translated_into: {fr: {
          summary: 'Nous nous occupons de la pilosité faciale du pays',
          body: 'Barbes, moustaches, même rouflaquettes'
        }}
        )

        get :edit, id_key => organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr'

        translation_path = path_prefix(type, organisational_entity, corporate_information_page) + '/fr'
        assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
          assert_select "textarea[name='corporate_information_page[summary]']", text: 'Nous nous occupons de la pilosité faciale du pays'
          assert_select "textarea[name='corporate_information_page[body]']", text: 'Barbes, moustaches, même rouflaquettes'
          assert_select "input[type=submit][value=Save]"
        end
      end

      view_test "#{type}: edit presents a form respecting the RTL value of the language" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity)

        get :edit, id_key => organisational_entity, corporate_information_page_id: corporate_information_page, id: 'ar'

        assert_select "form" do
          assert_select "fieldset.right-to-left textarea[name='corporate_information_page[summary]']"
          assert_select "fieldset.right-to-left textarea[name='corporate_information_page[body]']"
        end
      end

      view_test "#{type}: update updates translation and redirects back to the index" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity)

        put :update, id_key => organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr', corporate_information_page: {
          summary: 'Nous nous occupons de la pilosité faciale du pays',
          body: 'Barbes, moustaches, même rouflaquettes'
        }

        corporate_information_page.reload

        with_locale :fr do
          assert_equal 'Nous nous occupons de la pilosité faciale du pays', corporate_information_page.summary
          assert_equal 'Barbes, moustaches, même rouflaquettes', corporate_information_page.body
        end

        assert_redirected_to path_prefix(type, organisational_entity, corporate_information_page)
      end

      view_test "#{type}: update re-renders form if translation is invalid" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity)

        put :update, id_key => organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr', corporate_information_page: {
          body: '',
          summary: 'Barbes, moustaches, même rouflaquettes'
        }

        translation_path = path_prefix(type, organisational_entity, corporate_information_page) + '/fr'

        assert_select "form[action=#{CGI::escapeHTML(translation_path)}]" do
          assert_select "textarea[name='corporate_information_page[summary]']", text: 'Barbes, moustaches, même rouflaquettes'
        end
      end

      test "#{type}: destroy removes translation and redirects to list of translations" do
        organisational_entity = create(type)
        corporate_information_page = create(:corporate_information_page, organisation: organisational_entity, translated_into: [:fr])

        delete :destroy, id_key => organisational_entity, corporate_information_page_id: corporate_information_page, id: 'fr'

        corporate_information_page.reload
        refute corporate_information_page.translated_locales.include?(:fr)
        assert_redirected_to path_prefix(type, organisational_entity, corporate_information_page)
      end
    end
  end
end

class Admin::CorporateInformationPagesTranslationsControllerTest < ActionController::TestCase
  include AdminCorporateInformationPagesTranslationsControllerHelpers

  should_be_an_admin_controller
  should_show_list_of_corporate_information_translations_for :worldwide_organisation
  should_show_list_of_corporate_information_translations_for :organisation
end
