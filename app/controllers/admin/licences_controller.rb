class Admin::LicencesController < Admin::BaseController
  def index
    @licences = Licence.all
  end

  def edit
    @licence = Licence.find(params[:id])
    @activity_options = Activity.order(:title).map do |activity|
      [activity.title, activity.id]
    end
  end
end
