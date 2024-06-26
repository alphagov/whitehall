class ContentObjectStore::HealthCheckController < ApplicationController
  def index
    render json: { status: "OK" }, status: :ok
  end
end
