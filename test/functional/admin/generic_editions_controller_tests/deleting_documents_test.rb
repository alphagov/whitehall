require 'test_helper'
require "gds_api/test_helpers/publishing_api_v2"

class Admin::GenericEditionsController::DeletingDocumentsTest < ActionController::TestCase
  include GdsApi::TestHelpers::PublishingApiV2

  tests Admin::GenericEditionsController

  setup do
    login_as :writer
  end

  view_test "show displays the delete button for draft editions" do
    draft_edition = create(:draft_edition)

    get :show, params: { id: draft_edition }

    assert_select "form[action='#{admin_generic_edition_path(draft_edition)}']" do
      assert_select "input[name='_method'][type='hidden'][value='delete']"
      assert_select "input[type='submit']"
    end
  end

  view_test "show displays the delete button for submitted editions" do
    submitted_edition = create(:submitted_edition)

    get :show, params: { id: submitted_edition }

    assert_select "form[action='#{admin_generic_edition_path(submitted_edition)}']" do
      assert_select "input[name='_method'][type='hidden'][value='delete']"
      assert_select "input[type='submit']"
    end
  end

  view_test "show does not display the delete button for published editions" do
    published_edition = create(:published_edition)

    get :show, params: { id: published_edition }

    refute_select ".edition-sidebar input[name='_method'][type='hidden'][value='delete']"
  end

  view_test "show does not display the delete button for superseded editions" do
    superseded_edition = create(:superseded_edition)

    get :show, params: { id: superseded_edition }

    refute_select "form[action='#{admin_generic_edition_path(superseded_edition)}'] input[name='_method'][type='hidden'][value='delete']"
  end

  test "destroy marks the edition as deleted" do
    edition = create(:draft_edition)
    delete :destroy, params: { id: edition }
    edition.reload
    assert edition.deleted?
  end

  test "destroying an edition redirects to the draft editions page" do
    draft_edition = create(:draft_edition)
    delete :destroy, params: { id: draft_edition }
    assert_redirected_to admin_editions_path
  end

  test "destroy displays a notice indicating the edition has been deleted" do
    draft_edition = create(:draft_edition, title: "edition-title")
    delete :destroy, params: { id: draft_edition }
    assert_equal "The document 'edition-title' has been deleted", flash[:notice]
  end

  test "destroy notifies the publishing API of the deleted document" do
    draft_edition = create(:draft_edition, translated_into: %i[es fr])
    delete :destroy, params: { id: draft_edition }

    %w[en es fr].each do |locale|
      assert_publishing_api_discard_draft(draft_edition.content_id, locale: locale)
    end
  end
end
