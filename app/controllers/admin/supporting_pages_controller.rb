class Admin::SupportingPagesController < Admin::BaseController
  before_filter :find_document, only: [:new, :create]
  before_filter :find_supporting_page, only: [:show, :edit, :update, :destroy]

  def new
    @supporting_page = @document.supporting_pages.build(params[:supporting_page])
    build_attachment
  end

  def create
    @supporting_page = @document.supporting_pages.build(params[:supporting_page])
    if @supporting_page.save
      redirect_to admin_document_path(@document), notice: "The supporting page was added successfully"
    else
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
      render :edit
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = %{This page has been saved since you opened it. Your version appears at the top and the latest version appears at the bottom. Please incorporate any relevant changes into your version and then save it.}
    @conflicting_supporting_page = SupportingPage.find(params[:id])
    @supporting_page.lock_version = @conflicting_supporting_page.lock_version
    render action: "edit"
  end

  def destroy
    if @supporting_page.destroyable?
      @supporting_page.destroy
      flash[:notice] = %{"#{@supporting_page.title}" destroyed.}
    else
      flash[:alert] = "Cannot destroy a supporting page that has been published"
    end
    redirect_to admin_document_path(@supporting_page.document)
  end

  private

  def find_document
    @document = Document.find(params[:document_id])
  end

  def find_supporting_page
    @supporting_page = SupportingPage.find(params[:id])
  end

  def build_attachment
    unless @supporting_page.supporting_page_attachments.any?(&:new_record?)
      supporting_page_attachment = @supporting_page.supporting_page_attachments.build
      supporting_page_attachment.build_attachment
    end
  end
end