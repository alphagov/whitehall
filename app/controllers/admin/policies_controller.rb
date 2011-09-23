class Admin::PoliciesController < ApplicationController
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
      redirect_to edit_admin_policy_path(@policy)
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
    if @policy.submitted?
      @policy.update_attributes(params[:policy])
      redirect_to submitted_admin_policies_path
    else 
      if @policy.update_attributes(params[:policy])
        if @policy.submitted?
          flash[:notice] = 'Your policy has been submitted to your second pair of eyes'
          redirect_to admin_policies_path
        else
          flash[:notice] = 'The policy has been saved'
          redirect_to edit_admin_policy_path(@policy)
        end
      else
        flash.now[:warning] = 'There are some problems with the policy'
        render :action => 'edit'
      end
    end
  end

  def publish
    policy = Policy.find(params[:id])
    unless policy.publish_as!(current_user)
      flash[:warning] = "You are not the second set of eyes"
    end
    redirect_to submitted_admin_policies_path
  end

  def submitted
    @policies = Policy.submitted
  end
end