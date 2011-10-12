require "test_helper"

class MinisterialRolesControllerTest < ActionController::TestCase

  test "don't show draft policies" do
    ministerial_role = create(:ministerial_role)
    draft_policy = create(:draft_policy)
    draft_policy.ministerial_roles << ministerial_role

    get :show, id: ministerial_role.id

    refute assigns(:policies).include?(draft_policy)
  end

  test "don't show draft publications" do
    ministerial_role = create(:ministerial_role)
    draft_publication = create(:draft_publication)
    draft_publication.ministerial_roles << ministerial_role

    get :show, id: ministerial_role.id

    refute assigns(:policies).include?(draft_publication)
  end

end