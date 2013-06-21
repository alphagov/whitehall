class PublicUploadsController < ApplicationController
  include ActionView::Helpers::AssetTagHelper
  include UploadsControllerHelper

  def show
    send_upload upload_path, public: true
  end

  private

  def upload_path
    basename = [params[:path], params[:extension]].join(".")
    File.join(Whitehall.clean_upload_path, basename)
  end
end