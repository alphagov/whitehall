class Admin::ErrorsController < Admin::BaseController
  skip_before_action :authenticate_user!

  def bad_request
    render(status: :bad_request)
  end

  def forbidden
    render(status: :forbidden)
  end

  def not_found
    render(status: :not_found)
  end

  def unprocessable_content
    render(status: :unprocessable_content)
  end

  def internal_server_error
    render(status: :internal_server_error)
  end
end
