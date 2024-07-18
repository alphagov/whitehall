class Admin::WorldwideOrganisationsMainOfficesController < Admin::BaseController
  before_action :find_worldwide_organisation

  def show; end

  def update
    @worldwide_organisation.update!(main_office_params)
    redirect_to admin_worldwide_organisation_worldwide_offices_path(@worldwide_organisation), notice: "Main office updated successfully"
  end

private

  def find_worldwide_organisation
    @worldwide_organisation = Edition.find(params[:id])
  end

  def main_office_params
    params.require(:worldwide_organisation).permit(:main_office_id)
  end
end
