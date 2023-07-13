class Admin::WorldwideOrganisationsController < Admin::BaseController
  VERSIONS_PER_PAGE = 10

  respond_to :html

  before_action :find_worldwide_organisation, except: %i[index new create]
  before_action :build_worldwide_organisation, only: %i[new create]
  layout :get_layout

  def index
    @worldwide_organisations = WorldwideOrganisation.ordered_by_name
    render_design_system(:index, :legacy_index)
  end

  def new
    @worldwide_organisation.build_default_news_image
    render :legacy_new
  end

  def create
    if @worldwide_organisation.update(worldwide_organisation_params)
      redirect_to admin_worldwide_organisation_path(@worldwide_organisation), notice: "Organisation created successfully"
    else
      render :legacy_new
    end
  end

  def edit
    @worldwide_organisation.build_default_news_image
    render :legacy_edit
  end

  def update
    if @worldwide_organisation.update(worldwide_organisation_params)
      redirect_to admin_worldwide_organisation_path(@worldwide_organisation), notice: "Organisation updated successfully"
    else
      render :legacy_edit
    end
  end

  def show
    @versions = @worldwide_organisation
                  .versions_desc
                  .page(params[:page])
                  .per(VERSIONS_PER_PAGE)
  end

  def access_info
    @access_and_opening_times = @worldwide_organisation.default_access_and_opening_times
  end

  def set_main_office
    @worldwide_organisation.update!(main_office_params)
    redirect_to [:admin, @worldwide_organisation, WorldwideOffice], notice: "Main office updated successfully"
  end

  def confirm_destroy; end

  def destroy
    @worldwide_organisation.destroy!
    redirect_to admin_worldwide_organisations_path, notice: "Organisation deleted successfully"
  end

private

  def get_layout
    design_system_actions = %w[confirm_destroy]
    design_system_actions += %w[index] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def find_worldwide_organisation
    @worldwide_organisation = WorldwideOrganisation.friendly.find(params[:id])
  end

  def build_worldwide_organisation
    @worldwide_organisation = WorldwideOrganisation.new
  end

  def worldwide_organisation_params
    params.require(:worldwide_organisation).permit(
      :name,
      :logo_formatted_name,
      world_location_ids: [],
      sponsoring_organisation_ids: [],
      default_news_image_attributes: %i[file file_cache],
    )
  end

  def main_office_params
    params.require(:worldwide_organisation).permit(:main_office_id)
  end
end
