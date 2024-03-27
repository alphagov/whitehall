class Admin::WorldwideOrganisationPagesController < Admin::BaseController
  before_action :find_worldwide_organisation

  def index; end

  def new
    @worldwide_organisation_page = @worldwide_organisation.pages.build
  end

  def create
    @worldwide_organisation_page = @worldwide_organisation.pages.build(worldwide_organisation_page_params)

    if @worldwide_organisation_page.save
      redirect_to admin_editionable_worldwide_organisation_pages_path(@worldwide_organisation), notice: "#{@worldwide_organisation_page.title} has been added"
    else
      render :new
    end
  end

private

  def find_worldwide_organisation
    @worldwide_organisation = Edition.find(params[:editionable_worldwide_organisation_id])
  end

  def worldwide_organisation_page_params
    params.require(:worldwide_organisation_page)
          .permit(:corporate_information_page_type_id,
                  :summary,
                  :body)
  end
end
