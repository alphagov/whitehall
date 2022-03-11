class Admin::DesignSystemController < Admin::BaseController
  def toggle
    session[:design_system] = !session[:design_system]

    referer = URI(request.referer)
    destination = if referer.path.start_with?(admin_root_path)
                    referer.path + (referer.query ? "?#{referer.query}" : "")
                  else
                    admin_root_path
                  end

    redirect_to destination
  rescue URI::InvalidURIError
    redirect_to admin_root_path
  end
end
