class PlaceholderController < ApplicationController
  include ActionView::Helpers::AssetTagHelper

  def show
  end

  def virus_checking_placeholder_image
     redirect_to view_context.path_to_image('thumbnail-virus-checking.jpg')
  end
end
