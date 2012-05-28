class Admin::EditorialRemarksController < Admin::BaseController
  def new
    @edition = Edition.find(params[:document_id])
    @editorial_remark = @edition.editorial_remarks.build
  end

  def create
    @edition = Edition.find(params[:document_id])
    @editorial_remark = @edition.editorial_remarks.build(params[:editorial_remark].merge(author: current_user))
    if @editorial_remark.save
      redirect_to admin_documents_path(state: :submitted)
    else
      render "new"
    end
  end
end
