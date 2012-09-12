class Admin::CorporateInformationPagesController < Admin::BaseController
  before_filter :find_organisation
  before_filter :build_corporate_information_page, only: [:new, :create]
  before_filter :find_corporate_information_page, only: [:edit, :update, :destroy]

  def new
    build_corporate_information_page
    build_attachment
  end

  def create
    build_corporate_information_page
    if @corporate_information_page.save
      flash[:notice] = "#{@corporate_information_page.title} created successfully"
      redirect_to [:admin, @organisation]
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      build_attachment
      render :new
    end
  end

  def edit
    build_attachment
  end

  def update
    if @corporate_information_page.update_attributes(params[:corporate_information_page])
      flash[:notice] = "#{@corporate_information_page.title} updated successfully"
      redirect_to [:admin, @organisation]
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      build_attachment
      render :new
    end
  rescue ActiveRecord::StaleObjectError
    flash.now[:alert] = %{This page has been saved since you opened it. Your version appears at the top and the latest version appears at the bottom. Please incorporate any relevant changes into your version and then save it.}
    @conflicting_corporate_information_page = @organisation.corporate_information_pages.for_slug(params[:id])
    @corporate_information_page.lock_version = @conflicting_corporate_information_page.lock_version
    build_attachment
    render action: "edit"
  end

  def destroy
    if @corporate_information_page.destroy
      flash[:notice] = "#{@corporate_information_page.title} deleted successfully"
      redirect_to [:admin, @organisation]
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      build_attachment
      render :new
    end
  end

private

  def find_corporate_information_page
    @corporate_information_page = @organisation.corporate_information_pages.for_slug(params[:id])
  end

  def build_corporate_information_page
    @corporate_information_page ||= @organisation.corporate_information_pages.build(params[:corporate_information_page])
  end

  def find_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end

  def build_attachment
    unless @corporate_information_page.corporate_information_page_attachments.any?(&:new_record?)
      corporate_information_page_attachment = @corporate_information_page.corporate_information_page_attachments.build
      corporate_information_page_attachment.build_attachment
    end
  end
end