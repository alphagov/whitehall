class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.all
  end

  def show
    @organisation = Organisation.find(params[:id])
    @policies = @organisation.published_policies
    @publications = @organisation.published_publications
  end
end