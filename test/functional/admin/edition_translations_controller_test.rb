# encoding: UTF-8
require 'test_helper'

class Admin::EditionTranslationsControllerTest < ActionController::TestCase
  include Admin::EditionRoutesHelper
  include Rails.application.routes.url_helpers
  default_url_options[:host] = 'test.host'

  setup do
    @policy_writer = login_as(:policy_writer)
  end

  should_be_an_admin_controller

  view_test 'new presents a form to create a new translation' do
    edition = create(:edition)

    get :new, edition_id: edition

    assert_select "form[action=#{admin_edition_translations_path(edition)}]" do
      assert_select "select[name='translation_locale']"

      assert_select "input[type=text][name='edition[title]']"
      assert_select "textarea[name='edition[summary]'][rows=2][cols=40]"
      assert_select "textarea[name='edition[body]'][rows=20][cols=40]"

      assert_select "input[type=submit][value=Save]"
      assert_select "a[href=#{admin_edition_path(edition)}]", text: 'cancel'
    end
  end

  view_test 'new does not provide English as a choice of locale' do
    edition = create(:edition)

    get :new, edition_id: edition

    assert_select "select[name='translation_locale']" do
      assert_select "option[value=en]", count: 0
    end
  end

  test "should create a translation for an edition that's yet to be published, and redirect back to the edition admin page" do
    edition = create(:draft_edition)

    post :create, edition_id: edition, translation_locale: 'fr', edition: {
      title: 'translated-title',
      summary: 'translated-summary',
      body: 'translated-body'
    }

    edition.reload

    with_locale :fr do
      assert_equal 'translated-title', edition.title
      assert_equal 'translated-summary', edition.summary
      assert_equal 'translated-body', edition.body
    end

    assert_redirected_to admin_edition_path(edition)
  end

  test "should create a translation for a new draft of a previously published edition" do
    published_edition = create(:published_edition)
    draft_edition = published_edition.create_draft(@policy_writer)

    post :create, edition_id: draft_edition, translation_locale: 'fr', edition: {
      title: 'translated-title',
      summary: 'translated-summary',
      body: 'translated-body'
    }

    draft_edition.reload

    with_locale :fr do
      assert_equal 'translated-title', draft_edition.title
      assert_equal 'translated-summary', draft_edition.summary
      assert_equal 'translated-body', draft_edition.body
    end
  end

  test "should not overwrite an existing manually added change note when adding a new translation" do
    edition = create(:draft_edition, change_note: 'manually-added-change-note')

    post :create, edition_id: edition, translation_locale: 'fr', edition: {
      title: 'translated-title',
      summary: 'translated-summary',
      body: 'translated-body'
    }

    edition.reload

    assert_equal 'manually-added-change-note', edition.change_note
  end

  view_test 'create renders the form again if the translation is invalid' do
    edition = create(:draft_edition)

    post :create, edition_id: edition, translation_locale: 'fr', edition: {
      title: ''
    }

    assert_select '.form-errors'
  end
end