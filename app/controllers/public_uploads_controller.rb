class PublicUploadsController < ApplicationController
  def show
    asset_host = URI.parse(Plek.new.public_asset_host).host
    redirect_to host: asset_host
  end
end
