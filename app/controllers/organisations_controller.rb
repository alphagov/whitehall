class OrganisationsController < ApplicationController
  def show
    @organisation = Organisation.find(params[:id])
  end
end