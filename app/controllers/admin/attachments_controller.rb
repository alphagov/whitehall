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

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end
end
