class AttachmentsController < ApplicationController
  include UploadsControllerHelper

  def show
    clean_path = "clean-uploads/system/uploads/attachment_data/file/#{params[:id]}/#{params[:file]}.#{params[:extension]}"
    full_path = File.expand_path(clean_path)

    if attachment_visible?(params[:id])
      send_upload full_path, public: current_user.nil?
    else
      redirect_to_placeholder full_path
    end
  end

  private

  def attachment_visible?(attachment_data_id)
    visible_edition?(attachment_data_id) || visible_consultation_response?(attachment_data_id) || visible_corporate_information_page?(attachment_data_id) || visible_supporting_page?(attachment_data_id)
  end

  def visible_edition?(attachment_data_id)
    if edition_ids = EditionAttachment.joins(:attachment).where(attachments: {attachment_data_id: attachment_data_id}).collect(&:edition_id)
      any_edition_visible?(edition_ids)
    end
  end

  def visible_consultation_response?(attachment_data_id)
    if edition_ids = Response.joins(:attachments).where(attachments: {attachment_data_id: attachment_data_id}).collect(&:edition_id)
      any_edition_visible?(edition_ids)
    end
  end

  def visible_corporate_information_page?(attachment_data_id)
    CorporateInformationPage.joins(:attachments).where(attachments: {attachment_data_id: attachment_data_id}).exists?
  end

  def visible_supporting_page?(attachment_data_id)
    if edition_ids = SupportingPage.joins(:attachments).where(attachments: {attachment_data_id: attachment_data_id}).collect(&:edition_id)
      any_edition_visible?(edition_ids)
    end
  end

  def any_edition_visible?(ids)
    if current_user
      Edition.accessible_to(current_user).where(id: ids).exists?
    else
      Edition.published.where(id: ids).exists?
    end
  end
end