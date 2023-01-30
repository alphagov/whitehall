namespace :asset_manager do
  desc "Update draft file attachments with auth_bypass_ids"
  task update_attachments_with_auth_bypass_ids: :environment do
    # republish assets who's editions are draft with an auth bypass id
    latest_draft_editions = Edition.in_pre_publication_state.latest_edition

    latest_draft_editions.find_each do |edition|
      next unless edition.respond_to?(:attachments)

      edition.attachments.files.each do |file_attachment|
        new_attributes = { auth_bypass_ids: [edition.auth_bypass_id] }
        attachment_data_id = file_attachment.attachment_data.id
        AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
      end
    end
  end

  desc "Update draft consultation response form attachments with auth_bypass_ids"
  task update_consultation_response_forms_with_auth_bypass_ids: :environment do
    latest_draft_consultations = Consultation.in_pre_publication_state.latest_edition

    latest_draft_consultations.find_each do |consultation|
      if consultation.consultation_participation&.consultation_response_form.present?
        response_form = consultation.consultation_participation.consultation_response_form
        response_form_data_id = response_form.consultation_response_form_data.id
        new_attributes = { auth_bypass_ids: [consultation.auth_bypass_id] }

        AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue(
          "asset_manager_updater",
          "ConsultationResponseFormData",
          response_form_data_id,
          new_attributes,
        )
      end

      if consultation.outcome.present?
        consultation.outcome.attachments.files.each do |file_attachment|
          new_attributes = { auth_bypass_ids: [consultation.auth_bypass_id] }
          attachment_data_id = file_attachment.attachment_data.id
          AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
        end
      end

      next if consultation.public_feedback.blank?

      consultation.public_feedback.attachments.files.each do |file_attachment|
        new_attributes = { auth_bypass_ids: [consultation.auth_bypass_id] }
        attachment_data_id = file_attachment.attachment_data.id
        AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
      end
    end
  end

  desc "Update draft images with auth_bypass_ids"
  task update_images_with_auth_bypass_ids: :environment do
    latest_draft_editions = Edition.in_pre_publication_state.latest_edition

    latest_draft_editions.find_each do |edition|
      edition.images.each do |image|
        image_data_id = image.image_data.id
        new_attributes = { auth_bypass_ids: [edition.auth_bypass_id] }
        AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "ImageData", image_data_id, new_attributes)
      end
    end
  end
end
