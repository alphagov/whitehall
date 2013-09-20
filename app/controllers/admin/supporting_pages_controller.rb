class Admin::SupportingPagesController < Admin::BaseController
  include PublicDocumentRoutesHelper
  include Admin::AttachmentActionParamHandler

  before_filter :find_edition
  before_filter :limit_edition_access!
  before_filter :find_supporting_page, only: [:show, :edit, :update, :destroy]
  before_filter :cope_with_attachment_action_params, only: [:update]

  def new
    @supporting_page = @edition.supporting_pages.build(params[:supporting_page])
    build_attachment
  end

  def create
    @supporting_page = @edition.supporting_pages.build(params[:supporting_page])
    if @supporting_page.save
      redirect_to admin_edition_path(@edition), notice: "The supporting page was added successfully"
    else
      build_attachment
      flash[:alert] = "There was a problem: #{@supporting_page.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def show
  end

  def edit
    build_attachment
  end

  def update
    if @supporting_page.update_attributes(params[:supporting_page])
      redirect_to admin_supporting_page_path(@supporting_page), notice: "The supporting page was updated successfully"
    else
      flash[:alert] = "There was a problem: #{@supporting_page.errors.full_messages.to_sentence}"
      build_attachment
      render :edit
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = %(This page has been saved since you opened it. Your version appears at the top and the latest version appears at the bottom. Please incorporate any relevant changes into your version and then save it.)

    @conflicting_supporting_page = SupportingPage.find(params[:id])
    @supporting_page.lock_version = @conflicting_supporting_page.lock_version
    build_attachment
    render action: "edit"
  end

  def destroy
    if @supporting_page.destroyable?
      @supporting_page.destroy
      flash[:notice] = %("#{@supporting_page.title}" destroyed.)
    else
      flash[:alert] = "Cannot destroy a supporting page that has been published"
    end
    redirect_to admin_edition_path(@supporting_page.edition)
  end

  private

  def find_edition
    @edition = Edition.find(params[:edition_id])
  end

  def find_supporting_page
    @supporting_page = @edition.supporting_pages.find(params[:id])
  end

  def build_attachment
    @supporting_page.build_empty_attachment
  end
end
