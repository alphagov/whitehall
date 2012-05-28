require 'test_helper'

class Admin::EditionOrganisationsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  test "should allow featuring of the edition organisation" do
    edition_organisation = create(:edition_organisation, featured: false)
    login_as :departmental_editor
    post :update, id: edition_organisation, edition_organisation: {featured: true}
    assert edition_organisation.reload.featured?
  end

  test "should allow unfeaturing of the edition organisation" do
    edition_organisation = create(:edition_organisation, featured: true)
    login_as :departmental_editor
    post :update, id: edition_organisation, edition_organisation: {featured: false}
    refute edition_organisation.reload.featured?
  end

  test "should redirect back to the organisation's admin edit page" do
    organisation = create(:organisation)
    edition_organisation = create(:edition_organisation, organisation: organisation)
    login_as :departmental_editor
    post :update, id: edition_organisation, edition_organisation: {}
    assert_redirected_to edit_admin_organisation_path(organisation)
  end
end