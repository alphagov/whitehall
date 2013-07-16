require 'test_helper'

class Admin::GenericEditionsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :policy_writer
  end

  test "POST :create redirects to edit page when Save and Continue button clicked" do
    params = attributes_for(:edition).merge(lead_organisation_ids: [create(:organisation).id])
    assert_difference 'GenericEdition.count' do
      post :create, edition: params, save_and_continue: 'Save and Continue'
    end
    assert_redirected_to edit_admin_generic_edition_url(GenericEdition.last)
  end

  test "PUT :update redirects to edit page when Save and Continue button clicked" do
    edition = create(:edition)
    put :update, id: edition, edition: { title: 'New title' }, save_and_continue: 'Save and Continue'
    assert_redirected_to edit_admin_generic_edition_url(GenericEdition.last)
  end
end
