require 'test_helper'

class Admin::AttachmentsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  def valid_file_attachment_params
    {
      title: 'Attachment title',
      attachment_data_attributes: { file: fixture_file_upload('whitepaper.pdf') }
    }
  end

  def valid_html_attachment_params
    {
      title: 'Attachment title',
      govspeak_content_attributes: {
        body: 'Some **govspeak** body'
      }
    }
  end

  def valid_external_attachment_params
    {
      title: 'Attachment title',
      external_url: 'http://www.somewebsite.com/somepath',
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
      policy_group: :policy_group_id,
    }
  end

  supported_attachable_types.each do |type, param_name|
    view_test "GET :index handles #{type} as attachable" do
      attachable = create(type)
      create(:file_attachment, isbn: '817525766-0', attachable: attachable)

      get :index, params: { param_name => attachable.id }

      assert_response :success
      assert_select 'p', text: /ISBN: 817525766-0/
    end

    view_test "GET :new handles #{type} as attachable" do
      attachable = create(type)

      get :new, params: { param_name => attachable.id }

      assert_response :success
      assert_select "input[name='attachment[title]']"
    end

    test "POST :create handles file attachments for #{type} as attachable" do
      attachable = create(type)

      post :create, params: { param_name => attachable.id, attachment: valid_file_attachment_params }

      assert_response :redirect
      assert_equal 1, attachable.reload.attachments.size
      assert_equal 'Attachment title', attachable.attachments.first.title
      assert_equal 'whitepaper.pdf', attachable.attachments.first.filename
    end

    test "DELETE :destroy handles file attachments for #{type} as attachable" do
      attachable = create(type)
      attachment = create(:file_attachment, attachable: attachable)
      attachment_data = attachment.attachment_data

      delete :destroy, params: { param_name => attachable.id, id: attachment.id }

      assert_response :redirect
      assert Attachment.find(attachment.id).deleted?, 'attachment should have been soft-deleted'
      assert AttachmentData.find_by(id: attachment_data.id).nil?, 'attachment data should have been deleted'
    end
  end

  test "POST :create handles duplicate ordering key exceptions" do
    attachable = create(:edition)
    FileAttachment.any_instance.expects(:save).raises(Mysql2::Error, "Duplicate entry 'GenericEdition-1234-56' for key 'no_duplicate_attachment_orderings'")

    post :create, params: { edition_id: attachable.id, attachment: valid_file_attachment_params }

    assert_redirected_to admin_edition_attachments_url(attachable)
  end

  view_test 'GET :index shows html attachments' do
    create(:html_attachment, title: 'An HTML attachment', attachable: @edition)

    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select '.existing-attachments li strong', text: 'An HTML attachment'
  end

  test 'POST :create handles html attachments when attachable allows them' do
    post :create, params: { edition_id: @edition, type: 'html', attachment: valid_html_attachment_params }

    assert_response :redirect
    assert_equal 1, @edition.reload.attachments.size
    assert_equal 'Attachment title', @edition.attachments.first.title
    assert_equal 'Some **govspeak** body', @edition.attachments.first.govspeak_content_body
  end

  test 'POST :create saves an attachment on the draft edition' do
    attachment = valid_html_attachment_params.merge(title: SecureRandom.uuid)

    post :create, params: { edition_id: @edition.id, type: 'html', attachment: attachment }
    refute_nil(Attachment.find_by title: attachment[:title])
  end

  test 'POST :create ignores html attachments when attachable does not allow them' do
    attachable = create(:statistical_data_set, access_limited: false)

    post :create, params: { edition_id: attachable, type: 'html', attachment: valid_html_attachment_params }

    assert_response :redirect
    assert_equal 0, attachable.reload.attachments.size
  end

  test 'DELETE :destroy handles html attachments' do
    attachment = create(:html_attachment, attachable: @edition)

    delete :destroy, params: { edition_id: @edition, id: attachment.id }

    assert_response :redirect
    assert Attachment.find(attachment.id).deleted?, 'attachment should have been deleted'
  end

  view_test 'GET :index shows external attachments' do
    create(:external_attachment, title: 'An external attachment', attachable: @edition)

    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select '.existing-attachments li strong', text: 'An external attachment'
  end

  test 'POST :create handles external attachments when attachable allows them' do
    publication = create(:publication, attachments: [])
    post :create, params: { edition_id: publication, type: 'external', attachment: valid_external_attachment_params }

    assert_response :redirect
    assert_equal 1, publication.reload.attachments.size
    assert_equal 'Attachment title', publication.attachments.first.title
    assert_equal 'http://www.somewebsite.com/somepath', publication.attachments.first.external_url
  end

  test 'POST :create ignores external attachments when attachable does not allow them' do
    attachable = create(:statistical_data_set, access_limited: false)

    post :create, params: { edition_id: attachable, type: 'external', attachment: valid_external_attachment_params }

    assert_response :redirect
    assert_equal 0, attachable.reload.attachments.size
  end

  test 'Actions are unavailable on unmodifiable editions' do
    edition = create(:published_news_article)

    get :index, params: { edition_id: edition }
    assert_response :redirect
  end

  test "PUT :order saves the new order of attachments" do
    a, b, c = 3.times.map { |n| create(:file_attachment, attachable: @edition, ordering: n) }

    Consultation.any_instance.expects(:reorder_attachments).with([c.id.to_s, a.id.to_s, b.id.to_s]).once

    put :order, params: { edition_id: @edition, ordering: { a.id.to_s => '1',
                                                  b.id.to_s => '2',
                                                  c.id.to_s => '0' } }

    assert_response :redirect
  end

  test "PUT :order sorts attachment orderings as numbers" do
    a, b, c = 3.times.map { |n| create(:file_attachment, attachable: @edition, ordering: n) }

    Consultation.any_instance.expects(:reorder_attachments).with([a.id.to_s, b.id.to_s, c.id.to_s]).once

    put :order, params: { edition_id: @edition, ordering: { a.id.to_s => '9',
                                                  b.id.to_s => '10',
                                                  c.id.to_s => '11' } }

    assert_response :redirect
  end

  test "GET :new raises an exception with an unknown parent type" do
    assert_raise(ActiveRecord::RecordNotFound) {
      get :new, params: { edition_id: 123 }
    }
  end

  view_test "GET :new for a publication includes House of Commons metadata for file attachments" do
    publication = create(:publication)
    get :new, params: { edition_id: publication, type: 'file' }

    assert_select "input[name='attachment[hoc_paper_number]']"
    assert_select "option[value='#{Attachment.parliamentary_sessions.first}']"
  end

  view_test "GET :new for a publication includes House of Commons metadata for HTML attachments" do
    publication = create(:publication)
    get :new, params: { edition_id: publication, type: 'html' }

    assert_select "input[name='attachment[hoc_paper_number]']"
    assert_select "option[value='#{Attachment.parliamentary_sessions.first}']"
  end

  test "POST :create with bad data does not save the attachment and re-renders the new template" do
    post :create, params: { edition_id: @edition, attachment: { attachment_data_attributes: {} } }
    assert_template :new
    assert_equal 0, @edition.reload.attachments.size
  end

  view_test "GET :edit renders the edit form" do
    attachment = create(:file_attachment, attachable: @edition)
    get :edit, params: { edition_id: @edition, id: attachment }
    assert_select "input[value=#{attachment.title}]"
  end

  view_test "GET :edit renders the file upload field when the attachment is a base Attachment" do
    attachment = create(:file_attachment, attachable: @edition, attachment_data: create(:attachment_data))
    get :edit, params: { edition_id: @edition, id: attachment }
    assert_select "input[type=file]"
  end

  test "PUT :update for HTML attachment updates the attachment" do
    attachment = create(:html_attachment, attachable: @edition)

    put :update, params: { edition_id: @edition, id: attachment.id, attachment: {
      title: 'New title',
      govspeak_content_attributes: { body: 'New body', id: attachment.govspeak_content.id }
    } }
    assert_equal 'New title', attachment.reload.title
    assert_equal 'New body', attachment.reload.govspeak_content_body
  end

  test 'PUT :updates an attachment on the draft edition' do
    attachment = create(:html_attachment, attachable: @edition)
    title = SecureRandom.uuid

    put :update, params: { edition_id: @edition, id: attachment.id, attachment: {
      title: title,
      govspeak_content_attributes: { body: 'New body', id: attachment.govspeak_content.id }
    } }

    refute_nil(Attachment.find_by title: title)
  end

  test "PUT :update with empty file payload changes attachment metadata, but not the attachment data" do
    attachment = create(:file_attachment, attachable: @edition)
    attachment_data = attachment.attachment_data
    put :update, params: { edition_id: @edition, id: attachment, attachment: {
      title: 'New title',
      attachment_data_attributes: { file_cache: '', to_replace_id: attachment.attachment_data.id }
    } }
    assert_equal 'New title', attachment.reload.title
    assert_equal attachment_data, attachment.attachment_data
  end

  test "PUT :update with a file creates a replacement attachment data whilst leaving the original alone" do
    attachment = create(:file_attachment, attachable: @edition)
    old_data = attachment.attachment_data
    put :update, params: { edition_id: @edition, id: attachment, attachment: {
      attachment_data_attributes: { to_replace_id: old_data.id, file: fixture_file_upload('whitepaper.pdf') }
    } }
    attachment.reload
    old_data.reload

    refute_equal old_data, attachment.attachment_data
    assert_equal attachment.attachment_data, old_data.replaced_by
    assert_equal 'whitepaper.pdf',  attachment.filename
  end

  test "PUT :update_many changes attributes of multiple attachments" do
    files = Dir.glob(Rails.root.join('test', 'fixtures', '*.csv')).take(4)
    files.each_with_index do |f, i|
      create(:file_attachment, title: "attachment_%s" % i, attachable: @edition, file: File.open(f))
    end
    attachments = @edition.reload.attachments

    # append '_' to every attachment title in the collection
    new_data = attachments.map {|a| [a.id.to_s, { title: a.title + '_' }] }
    put :update_many, params: { edition_id: @edition, attachments: Hash[new_data] }

    @edition.reload.attachments.each do |attachment|
      assert_match(/.+_$/, attachment.title)
    end
  end

  test "update_many returns validation errors in JSON" do
    attachment = create(:file_attachment, attachable: @edition)

    new_data = { attachment.id.to_s => { title: "" } }
    put :update_many, params: { edition_id: @edition, attachments: new_data }

    response_json = JSON.parse(@response.body)
    assert_equal ["Title can't be blank"], response_json["errors"][attachment.id.to_s]
  end

  test 'attachment access is forbidden for users without access to the edition' do
    login_as :world_editor
    get :new, params: { edition_id: @edition }
    assert_response :forbidden
  end

  test "attachments can have locales" do
    post :create, params: { edition_id: @edition, attachment: valid_file_attachment_params.merge(locale: :fr) }
    attachment = @edition.reload.attachments.first

    assert_equal "fr", attachment.locale

    put :update, params: { edition_id: @edition, id: attachment, attachment: valid_file_attachment_params.merge(locale: :es) }
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
