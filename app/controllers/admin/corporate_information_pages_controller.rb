class Admin::CorporateInformationPagesController < Admin::BaseController
  before_filter :find_organisation
  before_filter :build_corporate_information_page, only: [:new, :create]
  before_filter :find_corporate_information_page, only: [:edit, :update, :destroy]

  def new
    build_corporate_information_page
  end

  def create
    build_corporate_information_page
    if @corporate_information_page.save
      flash[:notice] = "#{@corporate_information_page.title} created successfully"
      redirect_to [:admin, @organisation]
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def update
    if @corporate_information_page.update_attributes(params[:corporate_information_page])
      flash[:notice] = "#{@corporate_information_page.title} updated successfully"
      redirect_to [:admin, @organisation]
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def destroy
    if @corporate_information_page.destroy
      flash[:notice] = "#{@corporate_information_page.title} deleted successfully"
      redirect_to [:admin, @organisation]
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
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
end