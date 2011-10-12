class MinisterialRolesController < ApplicationController
  def index
    @ministerial_roles = MinisterialRole.all
  end

  def show
    @ministerial_role = MinisterialRole.find(params[:id])
    @policies = @ministerial_role.published_policies
    @publications = @ministerial_role.published_publications
  end
end