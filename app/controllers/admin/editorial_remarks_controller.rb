class Admin::EditorialRemarksController < Admin::BaseController
  layout "bootstrap_admin"

  def new
    @edition = Edition.find(params[:edition_id])
    @editorial_remark = @edition.editorial_remarks.build
  end

  def create
    @edition = Edition.find(params[:edition_id])
    @editorial_remark = @edition.editorial_remarks.build(params[:editorial_remark].merge(author: current_user))
    if @editorial_remark.save
      redirect_to admin_edition_path(@edition)
    else
      render "new"
    end
  end
end
