require 'test_helper'

class Admin::AttachmentsControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
    @edition = create(:news_article)
  end

  def attachment
    @attachment ||= create(:attachment, editions: [@edition])
  end

  should_be_an_admin_controller

  view_test "GET :new renders successfully" do
    get :new, edition_id: @edition
    assert_response :success
  end

  test "POST :create saves the attachment to the edition and redirects back to the edition edit page" do
    post :create, edition_id: @edition, attachment: {
      title: 'Attachment title',
      attachment_data_attributes: { file: fixture_file_upload('whitepaper.pdf') }
    }

    assert_redirected_to edit_admin_news_article_url(@edition)
    assert_equal 1, @edition.reload.attachments.size
    assert_equal 'Attachment title', @edition.attachments[0].title
    assert_equal 'whitepaper.pdf', @edition.attachments[0].filename
  end

  test "POST :create with bad data does not save the attachment and re-renders the new template" do
    post :create, edition_id: @edition, attachment: { attachment_data_attributes: { } }
    assert_template :new
    assert_equal 0, @edition.reload.attachments.size
  end

  view_test "GET :edit renders the edit form" do
    get :edit, edition_id: @edition, id: attachment
    assert_select "input[value=#{attachment.title}]"
  end

  test "PUT :update changes attachment metadata with empty file payload" do
    put :update, edition_id: @edition, id: attachment, attachment: {
      title: 'New title',
      attachment_data_attributes: { file_cache: '', id: attachment.attachment_data.id }
    }
    assert_equal 'New title', attachment.reload.title
  end

  test "PUT :update changes attachment file" do
    put :update, edition_id: @edition, id: attachment, attachment: {
      attachment_data_attributes: { file: fixture_file_upload('whitepaper.pdf') }
    }
    assert_equal 'whitepaper.pdf',  attachment.reload.filename
  end

  test "DELETE :destroy deletes an attachment" do
    delete :destroy, edition_id: @edition, id: attachment
    refute Attachment.exists?(attachment), 'attachment should have been deleted'
  end

  test 'attachment access is forbidden for users without access to the edition' do
    login_as :world_editor
    get :new, edition_id: @edition
    assert_response :forbidden
  end
end
