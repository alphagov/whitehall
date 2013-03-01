class Admin::SupportingPagesController < Admin::BaseController
  include PublicDocumentRoutesHelper

  before_filter :find_edition
  before_filter :limit_edition_access!
  before_filter :find_supporting_page, only: [:show, :edit, :update, :destroy]
  before_filter :cope_with_attachment_action_params, only: [:update]
  prepend_before_filter :skip_file_content_examination_for_privileged_users, only: [:create, :update]

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
    flash.now[:alert] = %{This page has been saved since you opened it. Your version appears at the top and the latest version appears at the bottom. Please incorporate any relevant changes into your version and then save it.}
    @conflicting_supporting_page = SupportingPage.find(params[:id])
    @supporting_page.lock_version = @conflicting_supporting_page.lock_version
    build_attachment
    render action: "edit"
  end

  def destroy
    if @supporting_page.destroyable?
      @supporting_page.destroy
      flash[:notice] = %{"#{@supporting_page.title}" destroyed.}
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

  def cope_with_attachment_action_params
    return unless params[:supporting_page] && params[:supporting_page][:supporting_page_attachments_attributes]
    params[:supporting_page][:supporting_page_attachments_attributes].each do |_, supporting_page_attachment_params|
      Admin::AttachmentActionParamHandler.manipulate_params!(supporting_page_attachment_params)
    end
  end

  def skip_file_content_examination_for_privileged_users
    return unless params[:supporting_page] && params[:supporting_page][:supporting_page_attachments_attributes]

    params[:supporting_page][:supporting_page_attachments_attributes].each do |_, supporting_page_attachment_join_params|
      if supporting_page_attachment_join_params &&
         supporting_page_attachment_join_params[:attachment_attributes] &&
         supporting_page_attachment_join_params[:attachment_attributes][:attachment_data_attributes]
        if current_user.can_upload_executable_attachments?
          supporting_page_attachment_join_params[:attachment_attributes][:attachment_data_attributes][:skip_file_content_examination] = true
        else
          supporting_page_attachment_join_params[:attachment_attributes][:attachment_data_attributes][:skip_file_content_examination] = false
        end
      end
    end
  end
end
