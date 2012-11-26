class PublicUploadsController < ApplicationController
  include ActionView::Helpers::AssetTagHelper
  include UploadsControllerHelper

  def show
    send_upload upload_path, public: true
  end

  private

  def upload_path
    Whitehall.clean_upload_path + [params[:path], params[:extension]].join(".")
  end
end