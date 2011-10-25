class Admin::PreviewController < Admin::BaseController
  def preview
    render layout: false
  end
end