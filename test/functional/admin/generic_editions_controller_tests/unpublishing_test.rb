require 'test_helper'

class Admin::GenericEditionsController::UnpublishingTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup do
    login_as :policy_writer
  end

  view_test "should display unpublish button" do
    edition = create(:edition)
    edition.stubs(:unpublishable_by?).returns(true)
    GenericEdition.stubs(:find).returns(edition)

    get :show, id: edition

    assert_select "form[action=?]", confirm_unpublish_admin_edition_path(edition)
  end

  view_test "should not display unpublish button if edition is not unpublishable" do
    edition = create(:edition)
    edition.stubs(:unpublishable_by?).returns(false)
    GenericEdition.stubs(:find).returns(edition)

    get :show, id: edition

    refute_select "form[action=?]", confirm_unpublish_admin_edition_path(edition)
  end
end