class PoliciesController < ApplicationController
  def index
    @policies = Policy.published
  end

  def show
    @policy = Policy.find(params[:id])
  end
end