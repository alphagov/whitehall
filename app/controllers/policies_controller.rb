class PoliciesController < ApplicationController
  def index
    @policies = Policy.all
  end

  def new
    @policy = Policy.new
  end

  def create
    policy = Policy.new(params[:policy])
    policy.save
    redirect_to edit_policy_path(policy)
  end

  def edit
    @policy = Policy.find(params[:id])
  end

  def update
    policy = Policy.find(params[:id])
    policy.update_attributes(params[:policy])
    redirect_to edit_policy_path(policy)
  end
end