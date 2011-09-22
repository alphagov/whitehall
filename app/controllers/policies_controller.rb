class PoliciesController < ApplicationController
  before_filter :authenticate!

  def index
    @policies = Policy.drafts
  end

  def show
    @policy = Policy.find(params[:id])
  end

  def new
    @policy = Policy.new
  end

  def create
    @policy = current_user.policies.build(params[:policy])
    if @policy.save
      flash[:notice] = 'The policy has been saved'
      redirect_to edit_policy_path(@policy)
    else
      flash.now[:warning] = 'There are some problems with the policy'
      render :action => 'new'
    end
  end

  def edit
    @policy = Policy.find(params[:id])
  end

  def update
    @policy = Policy.find(params[:id])
    if @policy.update_attributes(params[:policy])
      if @policy.submitted?
        flash[:notice] = 'Your policy has been submitted to your second pair of eyes'
        redirect_to policies_path
      else
        flash[:notice] = 'The policy has been saved'
        redirect_to edit_policy_path(@policy)
      end
    else
      flash.now[:warning] = 'There are some problems with the policy'
      render :action => 'edit'
    end
  end

  def submitted
    @policies = Policy.submitted
  end
end