require 'test_helper'

class Admin::AttachmentDataControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test "edit should allow users to upload attachment data" do
    publication = create(:publication, :with_attachment)
    attachment_data = publication.attachments.first.attachment_data

    get :edit, id: attachment_data.id

    assert_select "form" do
      assert_select "input[type='file']"
    end
  end

  test "update should not save file if filename is different" do
    publication = create(:publication, :with_attachment)
    attachment_data = publication.attachments.first.attachment_data

    put :update, id: attachment_data.id, attachment_data: {file: fixture_file_upload("/attachment_data_update/greenpaper.final.pdf", "application/pdf")}

    assert_equal 'You can only update a file if the new file has the same name as the old one, if this is not the case please add a new attachment instead', flash[:alert]
    not_updated_attachment_data = AttachmentData.find(attachment_data.id)
    assert_not_equal not_updated_attachment_data.carrierwave_file, "greenpaper.final.pdf"
    assert_equal 3470, not_updated_attachment_data.file_size
  end

  test "update should save file if filename is identical" do
    publication = create(:publication, :with_attachment)
    attachment_data = publication.attachments.first.attachment_data

    put :update, id: attachment_data.id, attachment_data: {file: fixture_file_upload("/attachment_data_update/greenpaper.pdf", "application/pdf")}

    assert_equal 12167, fixture_file_upload("/attachment_data_update/greenpaper.pdf", "application/pdf").size

    assert_equal 'Attachment data updated, you can close this tab', flash[:notice]
    updated_attachment_data = AttachmentData.find(attachment_data.id)
    assert_equal updated_attachment_data.carrierwave_file, "greenpaper.pdf"
    assert_equal 12167, updated_attachment_data.file_size
  end

end
