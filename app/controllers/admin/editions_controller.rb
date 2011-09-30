class Admin::EditionsController < ApplicationController
  before_filter :authenticate!
  before_filter :find_edition, only: [:show, :edit, :update, :publish, :revise, :fact_check]

  def index
    @editions = Edition.unsubmitted
  end

  def submitted
    @editions = Edition.submitted
  end

  def published
    @editions = Edition.published
  end

  def new
    @edition = Edition.new(document: document_class.new)
  end

  def create
    @edition = current_user.editions.build(params[:edition].merge(document: document_class.new))
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
          redirect_to admin_edition_path(@edition),
            notice: 'The policy has been saved'
        end
      else
        flash.now[:alert] = 'There are some problems with the policy'
        render action: 'edit'
      end
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = %{This policy has been saved since you opened it. Your version appears on the left and the latest version appears on the right. Please incorporate any relevant changes into your version and then save it.}
    @conflicting_edition = Edition.find(params[:id])
    @edition.lock_version = @conflicting_edition.lock_version
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

  def revise
    edition = @edition.build_draft(current_user)
    if edition.save
      redirect_to edit_admin_edition_path(edition)
    else
      redirect_to edit_admin_edition_path(@edition.document.editions.draft.first),
        alert: edition.errors.full_messages.to_sentence
    end
  end

  private

  def document_class
    @document_class ||= params[:document_type] == "Publication" ? Publication : Policy
  end

  def find_edition
    @edition = Edition.find(params[:id])
  end
end