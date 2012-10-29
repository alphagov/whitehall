class Admin::EditorialRemarksController < Admin::BaseController
  before_filter :find_edition
  before_filter :limit_edition_access!

  def new
    @editorial_remark = @edition.editorial_remarks.build
  end

  def create
    @editorial_remark = @edition.editorial_remarks.build(params[:editorial_remark].merge(author: current_user))
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
end