require "test_helper"

class Admin::SupportingPagesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  view_test "allows supporting page editing for GDS admins" do
    supporting_page = create(:draft_supporting_page)

    login_as :gds_admin
    get :edit, id: supporting_page
    assert_response :success
  end

private
  def controller_attributes_for(edition_type, attributes = {})
    super.reverse_merge(
      related_policy_ids: [create(:policy).id]
    )
  end
end
