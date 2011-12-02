class OrganisationsController < ApplicationController

  before_filter :load_organisation, only: [:show, :about]

  def index
    @organisations = Organisation.all
  end

  def show
    load_published_documents_in_scope { |scope| scope.in_organisation(@organisation) }
    @speeches = @organisation.ministerial_roles.map { |mr| mr.speeches.published }.flatten.uniq
  end

  def about
  end

  private

  def load_organisation
    @organisation = Organisation.find(params[:id])
  end
end