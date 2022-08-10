class Admin::LicencesController < Admin::BaseController
  def index
    @licences = Licence.all
  end

  def edit
    @licence = Licence.find(params[:id])
  end
end
