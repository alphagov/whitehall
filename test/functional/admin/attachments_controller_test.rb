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

  def self.supported_attachable_types
    {
      edition: :edition_id,
      consultation_outcome: :response_id,
      consultation_public_feedback: :response_id,
      corporate_information_page: :corporate_information_page_id,
    }
  end

  supported_attachable_types.each do |type, param_name|
    view_test "GET :index handles #{type} as attachable" do
      skip

      attachable = create(type)
      create(:file_attachment, isbn: '817525766-0', attachable: attachable)

      get :index, param_name => attachable.id

      assert_response :success
      assert_select 'p', text: /ISBN: 817525766-0/
    end

    view_test "GET :new handles #{type} as attachable" do
      attachable = create(type)

      get :new, param_name => attachable.id

      assert_response :success
      assert_select "input[name='attachment[title]']"
    end

    test "POST :create handles file attachments for #{type} as attachable" do
      attachable = create(type)

      post :create, param_name => attachable.id, attachment: valid_attachment_params

      assert_response :redirect
      assert_equal 1, attachable.reload.attachments.size
      assert_equal 'Attachment title', attachable.attachments.first.title
      assert_equal 'whitepaper.pdf', attachable.attachments.first.filename
    end

    test "POST :create handles html attachments for #{type} as attachable" do
      attachable = create(type)

      post :create, param_name => attachable.id, html: 'true', attachment: valid_html_attachment_params

      assert_response :redirect
      assert_equal 1, attachable.reload.attachments.size
      assert_equal 'Attachment title', attachable.attachments.first.title
      assert_equal 'Some **govspeak** body', attachable.attachments.first.body
    end

    test "DELETE :destroy handles file attachments for #{type} as attachable" do
      attachable = create(type)
      attachment = create(:file_attachment, attachable: attachable)

      delete :destroy, param_name => attachable.id, id: attachment.id

      assert_response :redirect
      refute Attachment.exists?(attachment), 'attachment should have been deleted'
    end

    test "DELETE :destroy handles html attachments for #{type} as attachable" do
      attachable = create(type)
      attachment = create(:html_attachment, attachable: attachable)

      delete :destroy, param_name => attachable.id, id: attachment.id

      assert_response :redirect
      refute Attachment.exists?(attachment), 'attachment should have been deleted'
    end
  end

  view_test "GET :index shows html attachments" do
    create(:html_attachment, title: 'An HTML attachment', attachable: @edition)

    get :index, edition_id: @edition

    assert_response :success
    assert_select 'li span.title', text: 'An HTML attachment'
  end

  test 'Actions are unavailable on unmodifiable editions' do
    edition = create(:published_news_article)

    get :index, edition_id: edition
    assert_response :redirect
  end

  test "PUT :order saves the new order of attachments" do
    a, b, c = 3.times.map { |n| create(:file_attachment, attachable: @edition, ordering: n) }

    Consultation.any_instance.expects(:reorder_attachments).with([c.id.to_s, a.id.to_s, b.id.to_s]).once

    put :order, edition_id: @edition, ordering: { a.id.to_s => '1',
                                                  b.id.to_s => '2',
                                                  c.id.to_s => '0' }

    assert_response :redirect
  end

  test "PUT :order sorts attachment orderings as numbers" do
    a, b, c = 3.times.map { |n| create(:file_attachment, attachable: @edition, ordering: n) }

    Consultation.any_instance.expects(:reorder_attachments).with([a.id.to_s, b.id.to_s, c.id.to_s]).once

    put :order, edition_id: @edition, ordering: { a.id.to_s => '9',
                                                  b.id.to_s => '10',
                                                  c.id.to_s => '11' }

    assert_response :redirect
  end

  test "GET :new raises an exception with an unknown parent type" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get :new, parent_id: 123
    }
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

  view_test "GET :edit renders the file upload field when the attachment is a base Attachment" do
    attachment = create(:file_attachment, attachable: @edition, attachment_data: create(:attachment_data))
    get :edit, edition_id: @edition, id: attachment
    assert_select "input[type=file]"
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

  test 'attachment access is forbidden for users without access to the edition' do
    login_as :world_editor
    get :new, edition_id: @edition
    assert_response :forbidden
  end

  test "attachments can have locales" do
    post :create, edition_id: @edition, attachment: valid_attachment_params.merge(locale: :fr)
    attachment = @edition.reload.attachments.first

    assert_equal "fr", attachment.locale

    put :update, edition_id: @edition, id: attachment, attachment: valid_attachment_params.merge(locale: :es)
    assert_equal "es", attachment.reload.locale
  end

  test "#attachable_attachments_path should be the attachments index" do
    assert_equal admin_edition_attachments_path(@edition),
                 polymorphic_path(controller.attachable_attachments_path(@edition))
  end

  test "#attachable_attachments_path should be the response page for responses" do
    response = create(:consultation_outcome)

    assert_equal admin_consultation_outcome_path(response.consultation),
                 polymorphic_path(controller.attachable_attachments_path(response))
  end
end
