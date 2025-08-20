class Admin::ErrorsController < Admin::BaseController
  before_action :prepend_content_block_manager_view_path, if: -> { request.path.start_with?(ContentBlockManager.router_prefix) }

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

private

  def prepend_content_block_manager_view_path
    prepend_view_path Rails.root.join("lib/engines/content_block_manager/app/views")
  end
end
