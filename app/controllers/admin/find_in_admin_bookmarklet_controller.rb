class Admin::FindInAdminBookmarkletController < Admin::BaseController
  def show
    case params[:browser]
    when "ie", "other" then
      render params[:browser]
    else
      render plain: "Not found", status: :not_found
    end
  end

end
