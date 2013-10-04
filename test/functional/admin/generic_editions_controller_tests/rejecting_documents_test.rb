require 'test_helper'

class Admin::GenericEditionsController::RejectingDocumentsTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup do
    login_as :policy_writer
  end

  view_test "displays the 'Reject' button for privileged users " do
    login_as :departmental_editor
    edition = create(:submitted_edition)
    GenericEdition.stubs(:find).with(edition.to_param).returns(edition)
    get :show, id: edition
    assert_select reject_button_selector(edition), count: 1
  end

  view_test "doesn't display the 'Reject' button for unprivileged users" do
    edition = create(:edition)
    GenericEdition.stubs(:find).with(edition.to_param).returns(edition)
    get :show, id: edition
    refute_select reject_button_selector(edition)
  end

  view_test "should show who rejected the edition" do
    edition = create(:rejected_edition)
    edition.editorial_remarks.create!(body: "editorial-remark-body", author: current_user)
    get :show, id: edition
    assert_select ".rejected_by", text: current_user.name
  end

  view_test "should not show the editorial remarks section" do
    edition = create(:submitted_edition)
    get :show, id: edition
    refute_select "#editorial_remarks .editorial_remark"
  end

  view_test "should show the list of editorial remarks" do
    edition = create(:rejected_edition)
    remark = edition.editorial_remarks.create!(body: "editorial-remark-body", author: current_user)
    get :show, id: edition
    assert_select ".editorial_remark" do
      assert_select ".body", text: /editorial-remark-body/
      assert_select ".actor", text: current_user.name
      assert_select "abbr.created_at[title=#{remark.created_at.iso8601}]"
    end
  end
end