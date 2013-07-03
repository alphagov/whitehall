require 'test_helper'

class Admin::AttachmentsControllerTest < ActionController::TestCase
  setup { login_as :gds_editor }

  should_be_an_admin_controller

  test "GET :new builds new attachment for edition and renders new template" do
    edition = create(:news_article)
    get :new, edition_id: edition

    assert_response :success
    assert_template :new
    assert_equal edition, assigns(:edition)
    assert assigns(:attachment).is_a?(Attachment)
    assert assigns(:attachment).editions.include?(edition)
  end

  test "POST :create saves the attachment to the edition and redirects back to the edition edit page" do
    edition = create(:news_article)
    post :create, edition_id: edition, attachment: { title: 'Attachment title',
                                          attachment_data_attributes: { file: fixture_file_upload('whitepaper.pdf') }
                                       }

    assert_redirected_to edit_admin_news_article_url(edition)
    assert_equal 1, edition.reload.attachments.size
    assert_equal 'Attachment title', edition.attachments[0].title
    assert_equal 'whitepaper.pdf', edition.attachments[0].filename
  end

  test "POST :create with bad data does not save the attachment and re-renders the new template" do
    edition = create(:news_article)
    post :create, edition_id: edition, attachment: { attachment_data_attributes: { } }

    assert_template :new
    assert_equal 0, edition.reload.attachments.size
  end
end
