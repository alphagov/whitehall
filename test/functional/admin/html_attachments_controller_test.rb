require "test_helper"

class Admin::HtmlAttachmentsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  def valid_html_attachment_params
    {
      title: "Attachment title",
      govspeak_content_attributes: {
        body: "Some **govspeak** body",
      },
    }
  end

  setup do
    login_as :gds_editor
    @edition = create(:consultation)
  end

  test "GET :new raises an exception with an unknown parent type" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :new, params: { edition_id: 123 }
    end
  end

  test "POST :create handles html attachments when attachable allows them" do
    post :create, params: { edition_id: @edition, attachment: valid_html_attachment_params }

    assert_response :redirect
    assert_equal 1, @edition.reload.attachments.size
    assert_equal "Attachment title", @edition.attachments.first.title
    assert_equal "Some **govspeak** body", @edition.attachments.first.body
  end

  test "POST :create saves an attachment on the draft edition" do
    attachment = valid_html_attachment_params.merge(title: SecureRandom.uuid)

    post :create, params: { edition_id: @edition.id, attachment: }
    assert_not_nil(Attachment.find_by(title: attachment[:title]))
  end

  test "POST :create for an HtmlAttachment updates the publishing api" do
    attachment = valid_html_attachment_params

    Whitehall::PublishingApi
      .expects(:save_draft)
      .with(@edition)

    Whitehall::PublishingApi
      .expects(:save_draft)
      .with(instance_of(HtmlAttachment), "major")

    post :create, params: { edition_id: @edition.id, attachment: }
  end

  test "POST :create ignores html attachments when attachable does not allow them" do
    attachable = create(:statistical_data_set, access_limited: false)

    post :create, params: { edition_id: attachable, attachment: valid_html_attachment_params }

    assert_response :redirect
    assert_equal 0, attachable.reload.attachments.size
  end

  test "DELETE :destroy handles html attachments" do
    attachment = create(:html_attachment, attachable: @edition)

    delete :destroy, params: { edition_id: @edition, id: attachment.id }

    assert_response :redirect
    assert Attachment.find(attachment.id).deleted?, "attachment should have been deleted"
  end

  view_test "GET :new for a publication includes House of Commons metadata for HTML attachments" do
    publication = create(:publication)
    get :new, params: { edition_id: publication }

    assert_select "input[name='attachment[hoc_paper_number]']"
    assert_select "option[value='#{Attachment.parliamentary_sessions.first}']"
  end

  test "POST :create with bad data does not save the attachment and re-renders the new template" do
    post :create, params: { edition_id: @edition, attachment: { attachment_data_attributes: {} } }
    assert_template :new
    assert_equal 0, @edition.reload.attachments.size
  end

  test "POST :create with invalid user_input validation does not save the attachment and re-renders the new template" do
    invalid_params = valid_html_attachment_params.merge(command_paper_number: "CP1510")

    post :create, params: { edition_id: @edition, attachment: invalid_params }

    assert_template :new
    assert_equal 0, @edition.reload.attachments.size
  end

  test "POST :create with invalid user_input validation does not publish draft of attachment to publishing api" do
    invalid_params = valid_html_attachment_params.merge(command_paper_number: "CP1510")

    Whitehall::PublishingApi.expects(:save_draft).with(instance_of(HtmlAttachment)).never
    Whitehall::PublishingApi.stubs(:save_draft).with(@edition)

    post :create, params: { edition_id: @edition, attachment: invalid_params }
  end

  test "PUT :update with invalid user_input validation does not save the attachment and re-renders the edit template" do
    attachment = create(:html_attachment, attachable: @edition)

    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          attachment: {
            title: attachment.title,
            command_paper_number: "CP1510",
            govspeak_content_attributes: { body: attachment.body, id: attachment.govspeak_content.id },
          },
        }

    assert_template :edit
    assert_nil attachment.reload.command_paper_number
  end

  test "PUT :update for HTML attachment updates the attachment" do
    attachment = create(:html_attachment, attachable: @edition)

    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          attachment: {
            title: "New title",
            govspeak_content_attributes: { body: "New body", id: attachment.govspeak_content.id },
          },
        }
    assert_equal "New title", attachment.reload.title
    assert_equal "New body", attachment.reload.body
  end

  test "PUT :update for HTML attachment updates the publishing api" do
    attachment = create(:html_attachment, attachable: @edition)

    Whitehall::PublishingApi
      .expects(:save_draft)
      .with(@edition)

    Whitehall::PublishingApi
      .expects(:save_draft)
      .with(attachment, "major")

    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          attachment: {
            title: "New title",
            govspeak_content_attributes: { body: "New body", id: attachment.govspeak_content.id },
          },
        }
  end

  test "PUT :updates an attachment on the draft edition" do
    attachment = create(:html_attachment, attachable: @edition)
    title = SecureRandom.uuid

    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          attachment: {
            title:,
            govspeak_content_attributes: { body: "New body", id: attachment.govspeak_content.id },
          },
        }

    assert_not_nil(Attachment.find_by(title:))
  end

  test "attachments can have locales" do
    post :create, params: { edition_id: @edition, attachment: valid_html_attachment_params.merge(locale: :fr) }
    attachment = @edition.reload.attachments.first

    assert_equal "fr", attachment.locale

    put :update, params: { edition_id: @edition, id: attachment, attachment: { locale: "es" } }
    assert_equal "es", attachment.reload.locale
  end
end
