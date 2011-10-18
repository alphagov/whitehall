class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.all
  end

  def show
    @organisation = Organisation.find(params[:id])
    @policies = Policy.published.in_organisation(@organisation)
    @publications = Publication.published.in_organisation(@organisation)
  end
end