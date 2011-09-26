class Admin::EditionsController < ApplicationController
  before_filter :authenticate!

  def index
    @editions = Edition.drafts
  end

  def show
    @edition = Edition.find(params[:id])
  end

  def new
    @edition = Edition.new
  end

  def create
    @edition = current_user.editions.build(params[:edition])
    if @edition.save
      redirect_to edit_admin_edition_path(@edition), notice: 'The policy has been saved'
    else
      flash.now[:alert] = 'There are some problems with the policy'
      render action: 'new'
    end
  end

  def edit
    @edition = Edition.find(params[:id])
  end

  def update
    @edition = Edition.find(params[:id])
    if @edition.submitted?
      @edition.update_attributes(params[:edition])
      redirect_to submitted_admin_editions_path
    else
      if @edition.update_attributes(params[:edition])
        if @edition.submitted?
          redirect_to admin_editions_path,
            notice: 'Your policy has been submitted to your second pair of eyes'
        else
          redirect_to edit_admin_edition_path(@edition),
            notice: 'The policy has been saved'
        end
      else
        flash.now[:alert] = 'There are some problems with the policy'
        render action: 'edit'
      end
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = "This policy has been edited since you viewed it; you are now viewing the latest version"
    render action: 'edit'
  end

  def publish
    edition = Edition.find(params[:id])
    if edition.publish_as!(current_user, params[:edition][:lock_version])
      redirect_to submitted_admin_editions_path
    else
      redirect_to admin_edition_path(edition), alert: edition.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_edition_path(edition), alert: "This policy has been edited since you viewed it; you are now viewing the latest version"
  end

  def submitted
    @editions = Edition.submitted
  end
end