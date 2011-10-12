class MinisterialRolesController < ApplicationController
  def index
    @ministerial_roles = MinisterialRole.all
  end
  def show
    @ministerial_role = MinisterialRole.find(params[:id])
  end
end