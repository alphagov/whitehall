class PlaceholderController < PublicFacingController
  include ActionView::Helpers::AssetTagHelper

  def show
  end

  def placeholder_image
     redirect_to view_context.path_to_image('thumbnail-placeholder.png')
  end
end
