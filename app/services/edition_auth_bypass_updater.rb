class EditionAuthBypassUpdater
  attr_reader :edition, :current_user, :updater

  def initialize(edition:, current_user:, updater:)
    @edition = edition
    @current_user = current_user
    @updater = updater
  end

  def call
    @edition.set_auth_bypass_id
    @edition.save_as(@current_user)
    @updater.perform!

    update_file_attachments(@edition)
    update_image_attachments(@edition)
    update_consultation_attachments(@edition)
  end

private

  def update_file_attachments(edition)
    return unless edition.respond_to?(:attachments) && edition.attachments.files.present?

    new_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

    edition.attachments.files.each do |file_attachment|
      attachment_data_id = file_attachment.attachment_data.id
      AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
    end
  end

  def update_image_attachments(edition)
    edition.images.each do |image|
      image_data_id = image.image_data.id
      new_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }
      AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "ImageData", image_data_id, new_attributes)
    end
  end

  def update_consultation_attachments(edition)
    return unless edition.is_a?(Consultation)

    if edition.consultation_participation&.consultation_response_form.present?
      response_form = edition.consultation_participation.consultation_response_form
      response_form_data_id = response_form.consultation_response_form_data.id
      new_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }

      AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "ConsultationResponseFormData", response_form_data_id, new_attributes)
    end

    if edition.outcome.present?
      edition.outcome.attachments.files.each do |file_attachment|
        new_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }
        attachment_data_id = file_attachment.attachment_data.id
        AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
      end
    end

    if edition.public_feedback.present?
      edition.public_feedback.attachments.files.each do |file_attachment|
        new_attributes = { "auth_bypass_ids" => [edition.auth_bypass_id] }
        attachment_data_id = file_attachment.attachment_data.id
        AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, new_attributes)
      end
    end
  end
end
