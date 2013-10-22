require 'test_helper'

class Admin::AttachmentsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  def valid_attachment_params
    {
      title: 'Attachment title',
      attachment_data_attributes: { file: fixture_file_upload('whitepaper.pdf') }
    }
  end

  def valid_html_attachment_params
    {
      title: 'Attachment title',
      body: 'Some **govspeak** body'
    }
  end

  setup do
    login_as :gds_editor
    @edition = create(:consultation)
  end

  test 'Actions are unavailable on unmodifiable editions' do
    edition = create(:published_news_article)

    get :index, edition_id: edition
    assert_response :redirect
  end

  view_test "GET :index lists the attachments for the edition" do
    @edition.attachments << build(:file_attachment)
    get :index, edition_id: @edition

    assert_response :success
    assert_select 'li span.title', text: @edition.attachments[0].title
  end

  view_test "GET :index shows metadata on each attachment" do
    @edition.attachments << build(:file_attachment, isbn: '817525766-0')
    get :index, edition_id: @edition
    assert_select 'p', text: /ISBN: 817525766-0/
  end

  test "PUT :order saves the new order of attachments" do
    attachment1 = build(:file_attachment)
    attachment2 = build(:html_attachment)
    attachment3 = build(:file_attachment)
    @edition.attachments << [attachment1, attachment2, attachment3]

    put :order, edition_id: @edition, ordering: {
                                        attachment1.id.to_s => '1',
                                        attachment2.id.to_s => '2',
                                        attachment3.id.to_s => '0'
                                      }

    assert_response :redirect
    assert_equal [attachment3, attachment1, attachment2], @edition.attachments(true)
  end

  view_test "GET :new renders the attachment form" do
    get :new, edition_id: @edition

    assert_response :success
    assert_select "input[name='attachment[title]']"
  end

  view_test "GET :new handles other 'attachable' things" do
    response = @edition.outcome = create(:consultation_outcome)
    get :new, response_id: response

    assert_response :success
    assert_select "input[name='attachment[title]']"
  end

  view_test "GET :new for a publication includes House of Commons metadata for file attachments" do
    publication = create(:publication)
    get :new, edition_id: publication, html: 'false'

    assert_select "input[name='attachment[hoc_paper_number]']"
    assert_select "option[value='#{Attachment.parliamentary_sessions.first}']"
  end

  view_test "GET :new for a publication includes House of Commons metadata for HTML attachments" do
    publication = create(:publication)
    get :new, edition_id: publication, html: 'true'

    assert_select "input[name='attachment[hoc_paper_number]']"
    assert_select "option[value='#{Attachment.parliamentary_sessions.first}']"
  end

  test "POST :create saves the file attachment to the edition and redirects to the attachments index" do
    post :create, edition_id: @edition, attachment: valid_attachment_params

    assert_redirected_to admin_edition_attachments_path(@edition)
    assert_equal 1, @edition.reload.attachments.size
    assert_equal FileAttachment, @edition.attachments[0].class
    assert_equal 'Attachment title', @edition.attachments[0].title
    assert_equal 'whitepaper.pdf', @edition.attachments[0].filename
  end

  test "POST :create saves the html attachment to the edition and redirects to the attachments index" do
    post :create, edition_id: @edition, html: 'true', attachment: valid_html_attachment_params

    assert_redirected_to admin_edition_attachments_path(@edition)
    assert_equal 1, @edition.reload.attachments.size
    assert_equal HtmlAttachment, @edition.attachments[0].class
    assert_equal 'Attachment title', @edition.attachments[0].title
    assert_equal 'Some **govspeak** body', @edition.attachments[0].body
  end

  test "POST :create handles response attachments and redirects to the response itself, rather than the attachments index" do
    consultation_response = @edition.outcome = create(:consultation_outcome)
    post :create, response_id: consultation_response, attachment: valid_attachment_params

    assert_redirected_to admin_consultation_outcome_url(@edition)
    assert_equal 1, consultation_response.reload.attachments.size
    assert_equal 'Attachment title', consultation_response.attachments[0].title
    assert_equal 'whitepaper.pdf', consultation_response.attachments[0].filename
  end

  test "POST :create with bad data does not save the attachment and re-renders the new template" do
    post :create, edition_id: @edition, attachment: { attachment_data_attributes: { } }
    assert_template :new
    assert_equal 0, @edition.reload.attachments.size
  end

  view_test "GET :edit renders the edit form" do
    attachment = create(:file_attachment, attachable: @edition)
    get :edit, edition_id: @edition, id: attachment
    assert_select "input[value=#{attachment.title}]"
  end

  test "PUT :update for HTML attachment updates the attachment" do
    attachment = create(:html_attachment, attachable: @edition)

    put :update, edition_id: @edition, id: attachment.id, attachment: {
      title: 'New title',
      body: 'New body'
    }
    assert_equal 'New title', attachment.reload.title
    assert_equal 'New body', attachment.reload.body
  end

  test "PUT :update with empty file payload changes attachment metadata, but not the attachment data" do
    attachment = create(:file_attachment, attachable: @edition)
    attachment_data = attachment.attachment_data
    put :update, edition_id: @edition, id: attachment, attachment: {
      title: 'New title',
      attachment_data_attributes: { file_cache: '', to_replace_id: attachment.attachment_data.id }
    }
    assert_equal 'New title', attachment.reload.title
    assert_equal attachment_data, attachment.attachment_data
  end

  test "PUT :update with a file creates a replacement attachment data whilst leaving the original alone" do
    attachment = create(:file_attachment, attachable: @edition)
    old_data = attachment.attachment_data
    put :update, edition_id: @edition, id: attachment, attachment: {
      attachment_data_attributes: { to_replace_id: old_data.id, file: fixture_file_upload('whitepaper.pdf') }
    }
    attachment.reload
    old_data.reload

    refute_equal old_data, attachment.attachment_data
    assert_equal attachment.attachment_data, old_data.replaced_by
    assert_equal 'whitepaper.pdf',  attachment.filename
  end

  test "DELETE :destroy deletes an attachment" do
    attachment = create(:file_attachment, attachable: @edition)
    delete :destroy, edition_id: @edition, id: attachment

    refute Attachment.exists?(attachment), 'attachment should have been deleted'
    assert_equal [], @edition.attachments.reload.to_a
  end

  test "DELETE :destroy deletes attachments from other 'attachable' things" do
    response = @edition.outcome = create(:consultation_outcome)
    attachment = create(:file_attachment, attachable: response)
    delete :destroy, response_id: response, id: attachment

    refute Attachment.exists?(attachment), 'attachment should have been deleted'
    assert_equal [], @edition.attachments.to_a
  end

  test 'attachment access is forbidden for users without access to the edition' do
    login_as :world_editor
    get :new, edition_id: @edition
    assert_response :forbidden
  end
end
