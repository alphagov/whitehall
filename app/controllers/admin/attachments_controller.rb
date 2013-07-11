class Admin::AttachmentsController < Admin::BaseController
  before_filter :find_edition

  def new
    @attachment = Attachment.new(editions: [@edition], attachment_data: AttachmentData.new)
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    @attachment.editions = [@edition]
    if @attachment.save
      redirect_to [:edit, :admin, @edition], notice: "Attachment '#{@attachment.filename}' uploaded"
    else
      render :new
    end
  end

  def edit
    @attachment = @edition.attachments.find(params[:id])
  end

  def update
    @attachment = @edition.attachments.find(params[:id])
    if @attachment.update_attributes(remove_empty_attachment_params(params[:attachment]))
      redirect_to admin_edition_path(@edition, anchor: 'attachments')
    else
      render :edit
    end
  end

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  private
  def remove_empty_attachment_params(attachments_hash)
    if attachments_hash[:attachment_data_attributes][:file]
      attachments_hash
    else
      attachments_hash.except(:attachment_data_attributes)
    end
  end
end
