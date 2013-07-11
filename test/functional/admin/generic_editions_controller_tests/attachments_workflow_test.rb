require 'test_helper'

class Admin::GenericEditionsController::AttachmentsWorkflowTest < ActionController::TestCase
  tests Admin::GenericEditionsController

  setup do
    login_as :policy_writer
  end

  test "POST on :create redirects to new attachment page when attachment indicator is present" do
    params = attributes_for(:edition).merge(lead_organisation_ids: [create(:organisation).id])

    assert_difference 'GenericEdition.count' do
      post :create, edition: params, adding_attachment: 'Button text not important'
    end

    article = GenericEdition.last
    assert_redirected_to new_admin_edition_attachment_url(article)
  end
end
