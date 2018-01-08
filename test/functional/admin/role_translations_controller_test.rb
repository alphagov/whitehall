# encoding: UTF-8

require "test_helper"

class Admin::RoleTranslationsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @role = create(:ambassador_role, responsibilities: "responsibilities")

    Locale.stubs(:non_english).returns([
      Locale.new(:fr), Locale.new(:es)
    ])
  end

  should_be_an_admin_controller

  view_test 'index shows a form to create missing translations' do
    get :index, params: { role_id: @role }

    translations_path = admin_role_translations_path(@role)
    assert_select "form[action=?]", translations_path do
      assert_select "select[name=translation_locale]" do
        assert_select "option[value=fr]", text: 'Français (French)'
        assert_select "option[value=es]", text: 'Español (Spanish)'
      end

      assert_select "input[type=submit]"
    end
  end

  view_test 'index omits existing translations from create select' do
    role = create(:role, translated_into: [:fr])

    get :index, params: { role_id: role }

    assert_select "select[name=translation_locale]" do
      assert_select "option[value=fr]", count: 0
    end
  end

  view_test 'index omits create form if no missing translations' do
    role = create(:role, translated_into: [:fr, :es])

    get :index, params: { role_id: role }

    assert_select "select[name=translation_locale]", count: 0
  end

  view_test 'index lists existing translations' do
    role = create(:role, translated_into: [:fr])

    get :index, params: { role_id: role }

    edit_translation_path = edit_admin_role_translation_path(role, 'fr')
    assert_select "a[href=?]", edit_translation_path, text: 'Français'
  end

  view_test 'index does not list the english translation' do
    get :index, params: { role_id: @role }

    edit_translation_path = edit_admin_role_translation_path(@role, 'en')
    assert_select "a[href=?]", edit_translation_path, text: 'en', count: 0
  end

  view_test 'index displays delete button for a translation' do
    role = create(:role, translated_into: [:fr])

    get :index, params: { role_id: role }

    assert_select "form[action=?]", admin_role_translation_path(role, :fr) do
      assert_select "input[type='submit'][value=?]", "Delete"
    end
  end

  test 'create redirects to edit for the chosen language' do
    post :create, params: { role_id: @role, translation_locale: 'fr' }

    assert_redirected_to edit_admin_role_translation_path(@role, id: 'fr')
  end

  view_test 'edit indicates which language is being translated to' do
    role = create(:role, translated_into: [:fr])
    get :edit, params: { role_id: @role, id: 'fr' }
    assert_select "h1", text: /Edit ‘Français \(French\)’ translation/
  end

  view_test 'edit presents a form to update an existing translation' do
    role = create(:role, translated_into: {
      fr: { name: 'nom de rôle', responsibilities: 'responsabilités' }
    })

    get :edit, params: { role_id: role, id: 'fr' }

    translation_path = admin_role_translation_path(role, 'fr')
    assert_select "form[action=?]", translation_path do
      assert_select "input[type=text][name='role[name]'][value=?]", 'nom de rôle'
      assert_select "textarea[name='role[responsibilities]']", text: 'responsabilités'
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'edit form adds right-to-left class and dir attribute for text field and areas in right-to-left languages' do
    role = create(:role, translated_into: {
      ar: { name: 'دور اسم', responsibilities: 'المسؤوليات' }}
    )

    get :edit, params: { role_id: role, id: 'ar' }

    translation_path = admin_role_translation_path(role, 'ar')
    assert_select "form[action=?]", translation_path do
      assert_select "fieldset[class='right-to-left']" do
        assert_select "input[type=text][name='role[name]'][dir='rtl'][value=?]", 'دور اسم'
        assert_select "textarea[name='role[responsibilities]'][dir='rtl']", text: 'المسؤوليات'
      end
      assert_select "input[type=submit][value=Save]"
    end
  end

  view_test 'update updates translation and redirects back to the index' do
    put :update, params: { role_id: @role, id: 'fr', role: {
      name: 'nom de rôle', responsibilities: 'responsabilités'
    } }

    @role.reload
    with_locale :fr do
      assert_equal 'nom de rôle', @role.name
      assert_equal 'responsabilités', @role.responsibilities
    end
    assert_redirected_to admin_role_translations_path(@role)
  end

  view_test 'update re-renders form if translation is invalid' do
    put :update, params: { role_id: @role, id: 'fr', role: {
      name: '', responsibilities: 'responsabilités'
    } }

    translation_path = admin_role_translation_path(@role, 'fr')
    assert_select "form[action=?]",  translation_path do
      assert_select '.form-errors'
      assert_select "input[type=text][name='role[name]'][value=?]", ''
      assert_select "textarea[name='role[responsibilities]']", text: 'responsabilités'
    end
  end

  test 'destroy removes translation and redirects to list of translations' do
    role = create(:role, translated_into: [:fr])

    delete :destroy, params: { role_id: role, id: 'fr' }

    role.reload
    refute role.translated_locales.include?(:fr)
    assert_redirected_to admin_role_translations_path(role)
  end
end
