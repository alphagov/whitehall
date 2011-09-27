class Admin::EditionsController < ApplicationController
  before_filter :authenticate!
  before_filter :find_edition, only: [:show, :edit, :update, :publish]

  def index
    @editions = Edition.drafts
  end

  def submitted
    @editions = Edition.submitted
  end

  def published
    @editions = Edition.published
  end

  def show
  end

  def new
    @edition = Edition.new
  end

  def create
    @edition = current_user.editions.build(params[:edition].merge(policy: Policy.new))
    if @edition.save
      redirect_to edit_admin_edition_path(@edition), notice: 'The policy has been saved'
    else
      flash.now[:alert] = 'There are some problems with the policy'
      render action: 'new'
    end
  end

  def edit
  end

  def update
    if @edition.submitted?
      if @edition.update_attributes(params[:edition])
        redirect_to submitted_admin_editions_path
      else
        render action: 'edit'
      end
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
    flash.now[:alert] = %{This policy has been saved since you opened it. You probably want to copy your changes into a text editor and <a href="#{edit_admin_edition_path(@edition)}">load the latest version</a>.}
    render action: 'edit'
  end

  def publish
    if @edition.publish_as!(current_user, params[:edition][:lock_version])
      redirect_to submitted_admin_editions_path
    else
      redirect_to admin_edition_path(@edition), alert: @edition.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to admin_edition_path(@edition), alert: "This policy has been edited since you viewed it; you are now viewing the latest version"
  end

  private

  def find_edition
    @edition = Edition.find(params[:id])
  end
end