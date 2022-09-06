class Admin::EditorialRemarksController < Admin::BaseController
  before_action :find_edition
  before_action :enforce_permissions!
  before_action :limit_edition_access!
  before_action :forbid_editing_of_locked_documents

  def enforce_permissions!
    enforce_permission!(:make_editorial_remark, @edition)
  end

  def index
    @document_remarks = Document::PaginatedRemarks.new(@edition.document, params[:page])
  end

  def new
    @editorial_remark = @edition.editorial_remarks.build
  end

  def create
    @editorial_remark = @edition.editorial_remarks.build(editorial_remark_params)
    if @editorial_remark.save
      if current_user.can_view_move_tabs_to_endpoints?
        redirect_to admin_edition_editorial_remarks_path(@edition)
      else
        redirect_to admin_edition_path(@edition)
      end
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
