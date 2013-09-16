class Admin::AttachmentsController < Admin::BaseController
  before_filter :find_attachable
  before_filter :limit_edition_access!, if: :attachable_is_an_edition?
  before_filter :enforce_edition_permissions!, if: :attachable_is_an_edition?
  before_filter :prevent_modification_of_unmodifiable_edition, if: :attachable_is_an_edition?
  before_filter :find_attachment, only: [:edit, :update, :destroy]

  def index
  end

  def order
    params[:ordering].each do |attachment_id, ordering|
      @attachable.attachments.find(attachment_id).update_column(:ordering, ordering)
    end
    redirect_to attachable_attachments_path(@attachable), notice: 'Attachments re-ordered'
  end

  def new
    @attachment = @attachable.attachments.build(attachment_data: AttachmentData.new)
  end

  def create
    @attachment = @attachable.attachments.build(params[:attachment])
    if @attachment.save
      redirect_to attachable_attachments_path(@attachable), notice: "Attachment '#{@attachment.filename}' uploaded"
    else
      render :new
    end
  end

  def update
    if @attachment.update_attributes(attachment_params)
      message = "Attachment '#{@attachment.filename}' updated"
      redirect_to attachable_attachments_path(@attachable), notice: message
    else
      render :edit
    end
  end

  def destroy
    @attachment.destroy
    redirect_to attachable_attachments_path(@attachable), notice: 'Attachment deleted'
  end

  private

  def find_attachable
    @attachable =
      if params.has_key?(:edition_id)
        @edition = Edition.find(params[:edition_id])
      elsif params.has_key?(:response_id)
        Response.find(params[:response_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end

  def find_attachment
    @attachment = @attachable.attachments.find(params[:id])
  end

  def attachment_params
    if params[:attachment][:attachment_data_attributes][:file]
      params[:attachment]
    else
      params[:attachment].except(:attachment_data_attributes)
    end
  end

  def enforce_edition_permissions!
    enforce_permission!(:update, @attachable)
  end

  def attachable_is_an_edition?
    @attachable.is_a?(Edition)
  end
end
