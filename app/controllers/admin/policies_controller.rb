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
      redirect_to edit_admin_policy_path(@policy), notice: 'The policy has been saved'
    else
      flash.now[:alert] = 'There are some problems with the policy'
      render action: 'new'
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
          redirect_to admin_policies_path,
            notice: 'Your policy has been submitted to your second pair of eyes'
        else
          redirect_to edit_admin_policy_path(@policy),
            notice: 'The policy has been saved'
        end
      else
        flash.now[:alert] = 'There are some problems with the policy'
        render action: 'edit'
      end
    end
  end

  def publish
    alert = nil
    if current_user.departmental_editor?
      policy = Policy.find(params[:id])
      unless policy.publish_as!(current_user)
        alert = "You are not the second set of eyes"
      end
    else
      alert = "Only departmental editors can publish policies"
    end
    redirect_to submitted_admin_policies_path, alert: alert
  end

  def submitted
    @policies = Policy.submitted
  end
end