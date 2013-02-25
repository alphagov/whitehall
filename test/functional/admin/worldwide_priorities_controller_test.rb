require 'test_helper'

class Admin::WorldwidePrioritiesControllerTest < ActionController::TestCase

  setup do
    @user = login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :worldwide_priority
  should_allow_creating_of :worldwide_priority
  should_allow_editing_of :worldwide_priority
  should_allow_revision_of :worldwide_priority

  should_show_document_audit_trail_for :worldwide_priority, :show
  should_show_document_audit_trail_for :worldwide_priority, :edit

  should_allow_association_between_world_locations_and :worldwide_priority
  should_allow_association_with_worldwide_organisations :worldwide_priority
  should_allow_attached_images_for :worldwide_priority
  should_allow_organisations_for :worldwide_priority

  should_be_rejectable :worldwide_priority
  should_be_publishable :worldwide_priority
  should_allow_unpublishing_for :worldwide_priority
  should_be_force_publishable :worldwide_priority
  should_be_able_to_delete_an_edition :worldwide_priority
  should_link_to_public_version_when_published :worldwide_priority
  should_not_link_to_public_version_when_not_published :worldwide_priority
  should_link_to_preview_version_when_not_published :worldwide_priority
  should_prevent_modification_of_unmodifiable :worldwide_priority
  should_allow_access_limiting_of :worldwide_priority

  view_test "show displays the number of translations excluding the default English translation" do
    edition = create(:draft_worldwide_priority)
    with_locale(:es) { edition.update_attributes!(attributes_for(:draft_worldwide_priority)) }

    get :show, id: edition

    assert_select "a[href='#translations'] .badge", text: '1'
  end

  view_test 'show displays a form to create missing translations' do
    edition = create(:draft_worldwide_priority)

    get :show, id: edition

    assert_select "form[action=#{admin_edition_translations_path(edition)}]" do
      assert_select "select[name=translation_locale]"
      assert_select "input[type=submit]"
    end
  end

  view_test 'show omits existing edition translations from create select' do
    edition = create(:draft_worldwide_priority)
    with_locale(:es) { edition.update_attributes!(attributes_for(:draft_worldwide_priority)) }

    get :show, id: edition

    assert_select "select[name=translation_locale]" do
      assert_select "option[value=es]", count: 0
    end
  end

  view_test 'show omits create form if no missing translations' do
    edition = create(:draft_worldwide_priority)
    with_locale(:es) { edition.update_attributes!(attributes_for(:draft_worldwide_priority)) }
    Locale.stubs(:non_english).returns([Locale.new(:es)])

    get :show, id: edition

    assert_select "select[name=translation_locale]", count: 0
  end

  view_test 'show omits create form unless the edition is editable' do
    edition = create(:published_worldwide_priority)
    refute edition.editable?

    get :show, id: edition

    assert_select "select[name=translation_locale]", count: 0
  end

  view_test "show displays a link to edit an existing translation" do
    edition = create(:draft_worldwide_priority, title: 'english-title', summary: 'english-summary', body: 'english-body')
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body') }

    get :show, id: edition

    assert_select "#translations .edition_translation.locale-fr" do
      assert_select "a[href='#{edit_admin_edition_translation_path(edition, 'fr')}']", text: 'Edit'
    end
  end

  view_test "show displays a link to delete an existing translation" do
    edition = create(:draft_worldwide_priority, title: 'english-title', summary: 'english-summary', body: 'english-body')
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body') }

    get :show, id: edition

    assert_select "#translations .edition_translation.locale-fr" do
      assert_select "form[action=?]", admin_edition_translation_path(edition, 'fr') do
        assert_select "input[type='submit'][value=?]", "Delete"
      end
    end
  end

  view_test "show displays the language of the translation on published editions" do
    edition = build(:published_worldwide_priority, title: 'english-title', summary: 'english-summary', body: 'english-body')
    with_locale(:fr) do
      edition.attributes = {title: 'french-title', summary: 'french-summary', body: 'french-body'}
    end
    edition.save!

    get :show, id: edition

    assert_select "#translations" do
      assert_select "p", text: 'French translation'
    end
  end

  view_test "show omits the link to edit an existing translation unless the edition is editable" do
    edition = create(:draft_worldwide_priority, title: 'english-title', summary: 'english-summary', body: 'english-body')
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body') }
    edition.publish_as(create(:departmental_editor), force: true)

    get :show, id: edition

    assert_select "#translations" do
      assert_select "a[href='#{edit_admin_edition_translation_path(edition, 'fr')}']", count: 0
    end
  end

  view_test "show omits the link to delete an existing translation unless the edition is deletable" do
    edition = create(:draft_worldwide_priority, title: 'english-title', summary: 'english-summary', body: 'english-body')
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body') }
    edition.publish_as(create(:departmental_editor), force: true)

    get :show, id: edition

    assert_select "#translations .edition_translation.locale-fr" do
      assert_select "form[action=?]", admin_edition_translation_path(edition, 'fr'), count: 0
    end
  end

  view_test "show displays all non-english translations" do
    edition = create(:draft_worldwide_priority, title: 'english-title', summary: 'english-summary', body: 'english-body-in-govspeak')
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body-in-govspeak') }

    transformation = {
      "english-body-in-govspeak" => "english-body-in-html",
      "french-body-in-govspeak" => "french-body-in-html"
    }
    govspeak_transformation_fixture(transformation) do
      get :show, id: edition
    end

    assert_select "#translations" do
      refute_select ".edition_translation.locale-en"
      assert_select ".edition_translation.locale-fr" do
        assert_select '.title', text: 'french-title'
        assert_select '.summary', text: 'french-summary'
        assert_select '.body', text: 'french-body-in-html'
      end
    end
  end
end
