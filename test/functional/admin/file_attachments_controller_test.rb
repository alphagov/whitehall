require "test_helper"

class Admin::FileAttachmentsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  def valid_file_attachment_params
    {
      title: "Attachment title",
      attachment_data_attributes: { file: upload_fixture("whitepaper.pdf") },
    }
  end

  setup do
    login_as :gds_editor
    @edition = create(:consultation)
  end

  view_test "GET :edit for a publication includes House of Commons metadata for file attachments" do
    publication = create(:publication)
    attachment = create(:file_attachment, attachable: publication, attachment_data: create(:attachment_data, attachable: publication))
    get :edit, params: { edition_id: publication, id: attachment }

    assert_select "input[name='attachment[hoc_paper_number]']"
    assert_select "option[value='#{Attachment.parliamentary_sessions.first}']"
  end

  view_test "GET :edit for a consultation includes hidden locale field with value set to consultation primary locale" do
    consultation = create(:consultation, primary_locale: "cy")
    attachment = create(:file_attachment, attachable: consultation, attachment_data: create(:attachment_data, attachable: consultation))
    get :edit, params: { edition_id: consultation, id: attachment }

    assert_select "input[type='hidden'][name='attachment[locale]'][value='#{consultation.primary_locale}']"
  end

  test "GET :new redirects" do
    get :new, params: { edition_id: @edition }

    assert_response :redirect
  end

  test "PUT :update with bad data does not save the attachment and re-renders the edit template" do
    attachment = create(:file_attachment, attachable: @edition, attachment_data: create(:attachment_data, attachable: @edition))
    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          attachment: {
            title: nil,
          },
        }
    assert_template :edit
  end

  view_test "GET :edit renders the edit form" do
    attachment = create(:file_attachment, attachable: @edition)
    get :edit, params: { edition_id: @edition, id: attachment }
    assert_select "input[value=#{attachment.title}]"
  end

  view_test "GET :edit renders the file upload field when the attachment is a base Attachment" do
    attachment = create(:file_attachment, attachable: @edition, attachment_data: create(:attachment_data, attachable: @edition))
    get :edit, params: { edition_id: @edition, id: attachment }
    assert_select "input[type=file]"
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
    model_type = attachment.attachment_data.class.to_s

    AssetManagerCreateAssetWorker.expects(:perform_async).with(anything, has_entries("assetable_id" => kind_of(Integer), "asset_variant" => Asset.variants[:original], "assetable_type" => model_type), anything, @edition.class.to_s, @edition.id, [@edition.auth_bypass_id])

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

  test "PUT :update with a file for a different attachment with the same name results in an error" do
    create(:file_attachment, attachable: @edition)
    another_attachment = create(:csv_attachment, attachable: @edition)

    put :update,
        params: {
          edition_id: @edition,
          id: another_attachment,
          attachment: {
            attachment_data_attributes: { file: upload_fixture("greenpaper.pdf") },
          },
        }
    assert_template :edit
  end

  test "PUT :discards file_cache when a file is provided" do
    attachment = create(:csv_attachment, attachable: @edition)
    attachment_data = attachment.attachment_data
    greenpaper_pdf = upload_fixture("greenpaper.pdf", "application/pdf")
    whitepaper_pdf = upload_fixture("whitepaper.pdf", "application/pdf")
    whitepaper_attachment_data = build(:attachment_data, file: whitepaper_pdf)

    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/whitepaper/), anything, anything, anything, anything, anything).never
    AssetManagerCreateAssetWorker.expects(:perform_async).with(regexp_matches(/greenpaper/), anything, anything, anything, anything, anything).once

    put :update,
        params: {
          edition_id: @edition,
          id: attachment.id,
          attachment: {
            title: "New title",
            attachment_data_attributes: { file: greenpaper_pdf, file_cache: whitepaper_attachment_data.file_cache, to_replace_id: attachment_data.id },
          },
        }
  end
end
