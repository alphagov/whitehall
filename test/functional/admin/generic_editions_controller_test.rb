require 'test_helper'

class Admin::GenericEditionsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    login_as :writer
  end

  test "POST :create redirects to edit page when 'Save and continue editing' button clicked" do
    params = attributes_for(:edition)
    assert_difference 'GenericEdition.count' do
      post :create, params: { edition: params, save_and_continue: 'Save and continue editing' }
    end
    assert_redirected_to edit_admin_edition_legacy_associations_path(GenericEdition.last.id, return: :edit)
  end

  test "PUT :update redirects to edit page when 'Save and continue' button clicked" do
    edition = create(:edition)
    put :update, params: { id: edition, edition: { title: 'New title' }, save_and_continue: 'Save and continue editing' }
    assert_redirected_to edit_admin_edition_legacy_associations_path(GenericEdition.last.id, return: :edit)
  end
end
