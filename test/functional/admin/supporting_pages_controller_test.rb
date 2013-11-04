require "test_helper"

class Admin::SupportingPagesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller
  should_allow_attached_images_for :supporting_page

private
  def controller_attributes_for(edition_type, attributes = {})
    super.reverse_merge(
      related_policy_ids: [create(:policy).id]
    )
  end
end
