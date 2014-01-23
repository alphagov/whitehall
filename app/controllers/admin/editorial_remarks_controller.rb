class Admin::EditorialRemarksController < Admin::BaseController
  before_filter :find_edition
  before_filter :enforce_permissions!
  before_filter :limit_edition_access!

  def enforce_permissions!
    enforce_permission!(:make_editorial_remark, @edition)
  end

  def new
    @editorial_remark = @edition.editorial_remarks.build
  end

  def create
    @editorial_remark = @edition.editorial_remarks.build(editorial_remark_params)
    if @editorial_remark.save
      redirect_to admin_edition_path(@edition)
    else
      render "new"
    end
  end

private
  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def editorial_remark_params
    params.require(:editorial_remark).permit(:body).merge(author: current_user)
  end
end
