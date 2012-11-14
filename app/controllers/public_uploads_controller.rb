class PublicUploadsController < ApplicationController
  include ActionView::Helpers::AssetTagHelper
  include UploadsControllerHelper

  def show
    send_upload upload_path, public: true
  end

  private

  def upload_path
    "clean-uploads/" + [params[:path], params[:extension]].join(".")
  end
end