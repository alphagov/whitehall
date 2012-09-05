class Admin::CorporateInformationPagesController < Admin::BaseController
  before_filter :find_organisation
  before_filter :build_corporate_information_page, only: [:new, :create]
  before_filter :find_corporate_information_page, only: [:edit, :update]

  def new
    build_corporate_information_page
  end

  def create
    build_corporate_information_page
    if @corporate_information_page.save
      flash[:notice] = "Corporate information page created successfully"
      redirect_to [:admin, @organisation]
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def update
    if @corporate_information_page.update_attributes(params[:corporate_information_page])
      flash[:notice] = "Corporate information page updated successfully"
      redirect_to [:admin, @organisation]
    else
      flash[:alert] = "There was a problem: #{@corporate_information_page.errors.full_messages.to_sentence}"
      render :new
    end
  end

  def find_corporate_information_page
    @corporate_information_page = @organisation.corporate_information_pages.find(params[:id])
  end

  private

  def build_corporate_information_page
    @corporate_information_page ||= @organisation.corporate_information_pages.build(params[:corporate_information_page])
  end

  def find_organisation
    @organisation = Organisation.find(params[:organisation_id])
  end
end