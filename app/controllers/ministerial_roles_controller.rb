class MinisterialRolesController < ApplicationController
  def index
    @ministerial_roles = MinisterialRole.all
  end

  def show
    @ministerial_role = MinisterialRole.find(params[:id])
    @policies = Policy.published.in_ministerial_role(@ministerial_role)
    @publications = Publication.published.in_ministerial_role(@ministerial_role)
  end
end