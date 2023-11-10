require "test_helper"

class Admin::AttachmentsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  def valid_file_attachment_params
    {
      title: "Attachment title",
      attachment_data_attributes: { file: upload_fixture("whitepaper.pdf") },
    }
  end

  def valid_html_attachment_params
    {
      title: "Attachment title",
      govspeak_content_attributes: {
        body: "Some **govspeak** body",
      },
    }
  end

  def valid_external_attachment_params
    {
      title: "Attachment title",
      external_url: "http://www.somewebsite.com/somepath",
    }
  end

  setup do
    login_as :gds_editor
    @edition = create(:consultation)
  end

  def self.supported_attachable_types
    {
      edition: :edition_id,
      consultation_outcome: :consultation_response_id,
      consultation_public_feedback: :consultation_response_id,
      policy_group: :policy_group_id,
    }
  end

  supported_attachable_types.each do |type, param_name|
    view_test "GET :index handles #{type} as attachable" do
      attachable = create(type) # rubocop:disable Rails/SaveBang
      create(:file_attachment, attachable:, title: "Lorem Ipsum")

      get :index, params: { param_name => attachable.id }

      assert_response :success
      assert_select "p.govuk-body", "Title: Lorem Ipsum"
    end

    view_test "GET :new handles #{type} as attachable" do
      attachable = create(type) # rubocop:disable Rails/SaveBang

      get :new, params: { param_name => attachable.id }

      assert_response :success
      assert_select "input[name='attachment[title]']"
    end

    test "POST :create handles file attachments for #{type} as attachable" do
      attachable = create(type) # rubocop:disable Rails/SaveBang

      post :create, params: { param_name => attachable.id, attachment: valid_file_attachment_params }

      assert_response :redirect
      assert_equal 1, attachable.reload.attachments.size
      assert_equal "Attachment title", attachable.attachments.first.title
      assert_equal "whitepaper.pdf", attachable.attachments.first.filename
    end

    test "DELETE :destroy handles file attachments for #{type} as attachable" do
      attachable = create(type) # rubocop:disable Rails/SaveBang
      attachment = create(:file_attachment, attachable:)

      delete :destroy, params: { param_name => attachable.id, id: attachment.id }

      assert_response :redirect
      assert Attachment.find(attachment.id).deleted?, "attachment should have been soft-deleted"
    end
  end

  test "POST :create handles duplicate ordering key exceptions" do
    attachable = create(:edition)
    FileAttachment.any_instance.expects(:save).raises(Mysql2::Error, "Duplicate entry 'GenericEdition-1234-56' for key 'no_duplicate_attachment_orderings'")

    post :create, params: { edition_id: attachable.id, attachment: valid_file_attachment_params }

    assert_redirected_to admin_edition_attachments_url(attachable)
  end

  view_test "GET :index shows html attachments" do
    create(:html_attachment, title: "An HTML attachment", attachable: @edition)

    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select "p.govuk-body", text: "Title: An HTML attachment"
  end

  view_test "GET :index renders the uploading banner when an attachment hasn't been uploaded to asset manager" do
    create(:html_attachment, title: "An HTML attachment", attachable: @edition)
    create(:file_attachment, title: "An uploaded file attachment", attachable: @edition)
    create(:file_attachment_with_no_assets, title: "An uploading file attachment", attachable: @edition)
    create(:external_attachment, title: "An external attachment", attachable: @edition)

    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select "p.govuk-body", text: "Title: An HTML attachment"
    assert_select "p.govuk-body", text: "Title: An uploaded file attachment"
    assert_select "p.govuk-body", text: "Title: An uploading file attachment Processing"
    assert_select "p.govuk-body", text: "Title: An external attachment"
  end

  test "POST :create handles html attachments when attachable allows them" do
    post :create, params: { edition_id: @edition, type: "html", attachment: valid_html_attachment_params }

    assert_response :redirect
    assert_equal 1, @edition.reload.attachments.size
    assert_equal "Attachment title", @edition.attachments.first.title
    assert_equal "Some **govspeak** body", @edition.attachments.first.body
  end

  test "POST :create saves an attachment on the draft edition" do
    attachment = valid_html_attachment_params.merge(title: SecureRandom.uuid)

    post :create, params: { edition_id: @edition.id, type: "html", attachment: }
    assert_not_nil(Attachment.find_by(title: attachment[:title]))
  end

  test "POST :create for an HtmlAttachment updates the publishing api" do
    attachment = valid_html_attachment_params

    Whitehall::PublishingApi
      .expects(:save_draft)
      .with(@edition)

    Whitehall::PublishingApi
      .expects(:save_draft)
      .with(instance_of(HtmlAttachment))

    post :create, params: { edition_id: @edition.id, type: "html", attachment: }
  end

  test "POST :create for a FileAttachnment doesnt update the publishing api" do
    attachment = valid_file_attachment_params

    Whitehall::PublishingApi
      .expects(:save_draft)
      .with(@edition)

    Whitehall::PublishingApi
      .expects(:save_draft)
      .never

    post :create, params: { edition_id: @edition.id, type: "file", attachment: }
  end

  test "POST :create ignores html attachments when attachable does not allow them" do
    attachable = create(:statistical_data_set, access_limited: false)

    post :create, params: { edition_id: attachable, type: "html", attachment: valid_html_attachment_params }

    assert_response :redirect
    assert_equal 0, attachable.reload.attachments.size
  end

  test "POST :create triggers a job to be queued to store the attachment in Asset Manager" do
    attachment = valid_file_attachment_params
    variant = Asset.variants[:original]
    model_type = AttachmentData.to_s

    AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, has_entries("assetable_id" => kind_of(Integer), "asset_variant" => variant, "assetable_type" => model_type), anything, @edition.class.to_s, @edition.id, [@edition.auth_bypass_id])

    post :create, params: { edition_id: @edition.id, type: "file", attachment: }
  end

  test "DELETE :destroy handles html attachments" do
    attachment = create(:html_attachment, attachable: @edition)

    delete :destroy, params: { edition_id: @edition, id: attachment.id }

    assert_response :redirect
    assert Attachment.find(attachment.id).deleted?, "attachment should have been deleted"
  end

  view_test "GET :index shows external attachments" do
    create(:external_attachment, title: "An external attachment", attachable: @edition)

    get :index, params: { edition_id: @edition }

    assert_response :success
    assert_select "p.govuk-body", text: "Title: An external attachment"
  end

  test "POST :create handles external attachments when attachable allows them" do
    publication = create(:publication, attachments: [])
    post :create, params: { edition_id: publication, type: "external", attachment: valid_external_attachment_params }

    assert_response :redirect
    assert_equal 1, publication.reload.attachments.size
    assert_equal "Attachment title", publication.attachments.first.title
    assert_equal "http://www.somewebsite.com/somepath", publication.attachments.first.external_url
  end

  test "POST :create ignores external attachments when attachable does not allow them" do
    attachable = create(:statistical_data_set, access_limited: false)

    post :create, params: { edition_id: attachable, type: "external", attachment: valid_external_attachment_params }

    assert_response :redirect
    assert_equal 0, attachable.reload.attachments.size
  end

  test "Actions are unavailable on unmodifiable editions" do
    edition = create(:published_news_article)

    get :index, params: { edition_id: edition }
    assert_response :redirect
  end

  test "PUT :order saves the new order of attachments" do
    a, b, c = 3.times.map { |n| create(:file_attachment, attachable: @edition, ordering: n) }

    Consultation.any_instance.expects(:reorder_attachments).with([c.id.to_s, a.id.to_s, b.id.to_s]).once

    put :order,
        params: { edition_id: @edition,
                  ordering: { a.id.to_s => "1",
                              b.id.to_s => "2",
                              c.id.to_s => "0" } }

    assert_response :redirect
  end

  test "PUT :order sorts attachment orderings as numbers" do
    a, b, c = 3.times.map { |n| create(:file_attachment, attachable: @edition, ordering: n) }

    Consultation.any_instance.expects(:reorder_attachments).with([a.id.to_s, b.id.to_s, c.id.to_s]).once

    put :order,
        params: { edition_id: @edition,
                  ordering: { a.id.to_s => "9",
                              b.id.to_s => "10",
                              c.id.to_s => "11" } }

    assert_response :redirect
  end

  test "GET :new raises an exception with an unknown parent type" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :new, params: { edition_id: 123 }
    end
  end

  view_test "GET :new for a publication includes House of Commons metadata for file attachments" do
    publication = create(:publication)
    get :new, params: { edition_id: publication, type: "file" }

    assert_select "input[name='attachment[hoc_paper_number]']"
    assert_select "option[value='#{Attachment.parliamentary_sessions.first}']"
  end

  view_test "GET :new for a publication includes House of Commons metadata for HTML attachments" do
    publication = create(:publication)
    get :new, params: { edition_id: publication, type: "html" }

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
      .with(attachment)

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

  test "PUT :update for file attachment doesn't update the publishing api" do
    attachment = create(:file_attachment, attachable: @edition)

    Whitehall::PublishingApi
      .expects(:save_draft)
      .never

    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          attachment: {
            title: "New title",
          },
        }
  end

  test "PUT :update with a file triggers a job to be queued to store the attachment in Asset Manager" do
    attachment = create(:file_attachment, attachable: @edition)
    variant = Asset.variants[:original]
    model_type = attachment.attachment_data.class.to_s

    AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, has_entries("assetable_id" => kind_of(Integer), "asset_variant" => variant, "assetable_type" => model_type), anything, @edition.class.to_s, @edition.id, [@edition.auth_bypass_id])

    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          attachment: {
            attachment_data_attributes: {
              file: upload_fixture("whitepaper.pdf"),
            },
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

  test "PUT :update with empty file payload changes attachment metadata, but not the attachment data" do
    attachment = create(:file_attachment, attachable: @edition)
    attachment_data = attachment.attachment_data
    put :update,
        params: {
          edition_id: @edition,
          id: attachment,
          attachment: {
            title: "New title",
            attachment_data_attributes: { file_cache: "", to_replace_id: attachment.attachment_data.id },
          },
        }
    assert_equal "New title", attachment.reload.title
    assert_equal attachment_data, attachment.attachment_data
  end

  test "PUT :update with a file creates a replacement attachment data whilst leaving the original alone" do
    attachment = create(:file_attachment, attachable: @edition)
    old_data = attachment.attachment_data
    put :update,
        params: {
          edition_id: @edition,
          id: attachment,
          attachment: {
            attachment_data_attributes: { to_replace_id: old_data.id, file: upload_fixture("whitepaper.pdf") },
          },
        }
    attachment.reload
    old_data.reload

    assert_not_equal old_data, attachment.attachment_data
    assert_equal attachment.attachment_data, old_data.replaced_by
    assert_equal "whitepaper.pdf", attachment.filename
  end

  test "POST :discards file_cache when a file is provided" do
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    whitepaper_pdf = upload_fixture("whitepaper.pdf", "application/pdf")
    whitepaper_attachment_data = build(:attachment_data, file: whitepaper_pdf)

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/whitepaper/), anything, anything, anything, anything, anything).never
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/greenpaper/), anything, anything, anything, anything, anything).times(2)

    post :create,
         params: {
           edition_id: @edition,
           type: "file",
           attachment: {
             title: "New title",
             attachment_data_attributes: { file: greenpaper_pdf, file_cache: whitepaper_attachment_data.file_cache },
           },
         }
  end

  test "PUT :discards file_cache when a file is provided" do
    attachment = create(:file_attachment, attachable: @edition)
    attachment_data = attachment.attachment_data
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    whitepaper_pdf = upload_fixture("whitepaper.pdf", "application/pdf")
    whitepaper_attachment_data = build(:attachment_data, file: whitepaper_pdf)

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/whitepaper/), anything, anything, anything, anything, anything).never
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/greenpaper/), anything, anything, anything, anything, anything).times(2)

    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          type: "file",
          attachment: {
            title: "New title",
            attachment_data_attributes: { file: greenpaper_pdf, file_cache: whitepaper_attachment_data.file_cache, to_replace_id: attachment_data.id },
          },
        }
  end

  test "attachment access is forbidden for users without access to the edition" do
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
                 @controller.polymorphic_path(controller.attachable_attachments_path(@edition))
  end

  test "#attachable_attachments_path should be the response page for responses" do
    response = create(:consultation_outcome)

    assert_equal admin_consultation_outcome_path(response.consultation),
                 @controller.polymorphic_path(controller.attachable_attachments_path(response))
  end
end
