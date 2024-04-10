class Admin::WorldwideOrganisationPagesController < Admin::BaseController
  before_action :find_worldwide_organisation
  before_action :find_worldwide_organisation_page, only: %i[edit update confirm_destroy destroy]

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

  def edit; end

  def update
    @worldwide_organisation_page.assign_attributes(worldwide_organisation_page_params)

    if @worldwide_organisation_page.save
      redirect_to admin_editionable_worldwide_organisation_pages_path(@worldwide_organisation), notice: "#{@worldwide_organisation_page.title} has been updated"
    else
      render :edit
    end
  end

  def confirm_destroy; end

  def destroy
    title = @worldwide_organisation_page.title

    if @worldwide_organisation_page.destroy
      redirect_to admin_editionable_worldwide_organisation_pages_path(@worldwide_organisation), notice: "#{title} has been deleted"
    else
      render :edit
    end
  end

private

  def find_worldwide_organisation
    @worldwide_organisation = Edition.find(params[:editionable_worldwide_organisation_id])
  end

  def find_worldwide_organisation_page
    @worldwide_organisation_page = @worldwide_organisation.pages.find(params[:id])
  end

  def worldwide_organisation_page_params
    params.require(:worldwide_organisation_page)
          .permit(:corporate_information_page_type_id,
                  :summary,
                  :body)
  end
end
