class Admin::AttachmentsController < Admin::BaseController
  before_filter :find_edition
  before_filter :limit_edition_access!
  before_filter :enforce_permissions!
  before_filter :prevent_modification_of_unmodifiable_edition
  before_filter :find_attachment, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @attachment = Attachment.new(editions: [@edition], attachment_data: AttachmentData.new)
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    @attachment.editions = [@edition]
    if @attachment.save
      redirect_to admin_edition_attachments_path(@edition), notice: "Attachment '#{@attachment.filename}' uploaded"
    else
      render :new
    end
  end

  def update
    if @attachment.update_attributes(remove_empty_attachment_params(params[:attachment]))
      redirect_to admin_edition_attachments_path(@edition), notice: "Attachment '#{@attachment.filename}' uploaded"
    else
      render :edit
    end
  end

  def destroy
    @attachment.edition_attachments.destroy_all
    redirect_to admin_edition_path(@edition, anchor: 'attachments'), notice: 'Attachment deleted'
  end

  private
  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def find_attachment
    @attachment = @edition.attachments.find(params[:id])
  end

  def remove_empty_attachment_params(attachments_hash)
    if attachments_hash[:attachment_data_attributes][:file]
      attachments_hash
    else
      attachments_hash.except(:attachment_data_attributes)
    end
  end

  def enforce_permissions!
    enforce_permission!(:update, @edition)
  end
end
