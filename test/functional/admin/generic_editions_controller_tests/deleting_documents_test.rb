require 'test_helper'

class Admin::GenericEditionsController::DeletingDocumentsTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup do
    login_as :policy_writer
  end

  view_test "show displays the delete button for draft editions" do
    draft_edition = create(:draft_edition)

    get :show, id: draft_edition

    assert_select "form[action='#{admin_generic_edition_path(draft_edition)}']" do
      assert_select "input[name='_method'][type='hidden'][value='delete']"
      assert_select "input[type='submit']"
    end
  end

  view_test "show displays the delete button for submitted editions" do
    submitted_edition = create(:submitted_edition)

    get :show, id: submitted_edition

    assert_select "form[action='#{admin_generic_edition_path(submitted_edition)}']" do
      assert_select "input[name='_method'][type='hidden'][value='delete']"
      assert_select "input[type='submit']"
    end
  end

  view_test "show does not display the delete button for published editions" do
    published_edition = create(:published_edition)

    get :show, id: published_edition

    refute_select ".edition-sidebar input[name='_method'][type='hidden'][value='delete']"
  end

  view_test "show does not display the delete button for archived editions" do
    archived_edition = create(:archived_edition)

    get :show, id: archived_edition

    refute_select "form[action='#{admin_generic_edition_path(archived_edition)}'] input[name='_method'][type='hidden'][value='delete']"
  end

  test "destroy marks the edition as deleted" do
    edition = create(:draft_edition)
    delete :destroy, id: edition
    edition.reload
    assert edition.deleted?
  end

  test "destroying an edition redirects to the draft editions page" do
    draft_edition = create(:draft_edition)
    delete :destroy, id: draft_edition
    assert_redirected_to admin_editions_path
  end

  test "destroy displays a notice indicating the edition has been deleted" do
    draft_edition = create(:draft_edition, title: "edition-title")
    delete :destroy, id: draft_edition
    assert_equal "The document 'edition-title' has been deleted", flash[:notice]
  end
end

