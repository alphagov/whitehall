class Admin::LicencesController < Admin::BaseController
  def index
    @licences = Licence.all
  end

  def show
    @licence = Licence.find(params[:id])
  end

  def edit
    @licence = Licence.find(params[:id])
    @activity_options = Activity.order(:title).map do |activity|
      [activity.title, activity.id]
    end
  end

  def update
    @licence = Licence.find(params[:id])

    if @licence.update!(licence_field_params)
      redirect_to admin_licences_path, notice: %("#{@licence.title}" saved.)
    else
      render action: "edit"
    end
  end

private

  def licence_field_params
    params.require(:licence).permit(:link, :title, :description, :activity_id, :external_link, sector_ids: [])
  end
end
