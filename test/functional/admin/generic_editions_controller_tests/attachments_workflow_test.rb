require 'test_helper'

class Admin::GenericEditionsController::AttachmentsWorkflowTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup do
    login_as :policy_writer
  end

  test "POST :create redirects to new attachment page when adding_attachment button clicked" do
    params = attributes_for(:edition).merge(lead_organisation_ids: [create(:organisation).id])

    assert_difference 'GenericEdition.count' do
      post :create, edition: params, adding_attachment: 'Button text not important'
    end

    article = GenericEdition.last
    assert_redirected_to new_admin_edition_attachment_url(article)
  end

  test "PUT :update saves and redirects to new attachment page when adding_attachment button clicked" do
    edition = create(:edition)
    put :update, id: edition, edition: { title: 'New title' }, adding_attachment: 'Button text not important'
    assert_redirected_to new_admin_edition_attachment_url(edition)
    assert_equal 'New title', edition.reload.title
  end
end
