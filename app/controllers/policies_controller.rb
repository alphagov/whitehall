class PoliciesController < ApplicationController
  def index
    @policies = Policy.all
  end

  def new
    @policy = Policy.new
  end

  def create
    @policy = Policy.new(params[:policy])
    if @policy.save
      redirect_to edit_policy_path(@policy)
    else
      flash[:warning] = 'There are some problems with the policy'
      render :action => 'new'
    end
  end

  def edit
    @policy = Policy.find(params[:id])
  end

  def update
    @policy = Policy.find(params[:id])
    if @policy.update_attributes(params[:policy])
      redirect_to edit_policy_path(@policy)
    else
      flash[:warning] = 'There are some problems with the policy'
      render :action => 'edit'
    end
  end
end