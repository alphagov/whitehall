class Admin::LicencesController < Admin::BaseController
  def index
    @licences = Licence.all
  end
end
