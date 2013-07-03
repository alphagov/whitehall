class Admin::AttachmentsController < Admin::BaseController
  before_filter :find_edition
  def new
    @attachment = Attachment.new(editions: [@edition])
  end

  def create
    @attachment = Attachment.new(params[:attachment])
    @attachment.editions = [@edition]
    if @attachment.save
      redirect_to [:edit, :admin, @edition]
    else
      render :new
    end
  end

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end
end
