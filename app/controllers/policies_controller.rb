class PoliciesController < ApplicationController
  def index
    @editions = Edition.published
  end

  def show
    @edition = Edition.find(params[:id])
  end
end