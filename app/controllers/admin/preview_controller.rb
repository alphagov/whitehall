class Admin::PreviewController < Admin::BaseController
  before_filter :find_images, only: :preview

  def preview
    render layout: false
  end
  
  def find_images
    @images = (params[:image_ids] || []).map { |id| Image.find(id) }
  end
end