class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.all
  end

  def show
    @organisation = Organisation.find(params[:id])
  end
end