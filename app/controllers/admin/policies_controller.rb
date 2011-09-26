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
    policy = Policy.find(params[:id])
    if policy.publish_as!(current_user, params[:policy][:lock_version])
      redirect_to submitted_admin_policies_path
    else
      redirect_to admin_policy_path(policy), alert: policy.errors.full_messages.to_sentence
    end
  end

  def submitted
    @policies = Policy.submitted
  end
end