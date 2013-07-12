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

class AttachableEditionsControllersTest < ActionController::TestCase
  tests Admin::NewsArticlesController

  setup do
    login_as :policy_writer
  end

  view_test 'GET :edit displays attachments on the edition' do
    edition = create(:news_article, :with_attachment)
    get :edit, id: edition
    attachment = edition.attachments.first
    assert_select 'span.title', attachment.title
  end

  view_test 'GET :show lists attachments on the edition' do
    skip 'TODO'
  end
end
