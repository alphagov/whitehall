class Admin::AttachmentDataController < Admin::BaseController

  before_filter :find_attachment

  def edit  
  end

  def update
    params[:attachment_data] ||= {}
    new_file_name = params[:attachment_data][:file].try(:original_filename)
    unless new_file_name == @attachment_data.carrierwave_file
      flash[:alert] = "You can only update a file if the new file has the same name as the old one, if this is not the case please add a new attachment instead"
      render :edit
    else
      @attachment_data.file = params[:attachment_data][:file]
      @attachment_data.update_file_attributes #dont remove me please
      @attachment_data.save
      flash[:notice] = "Attachment data updated, you can close this tab"
      render :edit
    end
  end

  def find_attachment
    @attachment_data = AttachmentData.find(params[:id])
  end
end