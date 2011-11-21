class OrganisationsController < ApplicationController
  def index
    @organisations = Organisation.all
  end

  def show
    @organisation = Organisation.find(params[:id])
    load_published_documents_in_scope { |scope| scope.in_organisation(@organisation) }
    @speeches = @organisation.ministerial_roles.map { |mr| mr.speeches.published }.flatten.uniq
  end
end