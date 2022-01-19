class Admin::WorldLocationCoronavirusTravelController < Admin::BaseController
  before_action :require_coronavirus_travel_editor_permission!
  before_action :load_world_location

  def edit
    @coronavirus_travel = WorldLocation::CoronavirusTravel.new(@world_location)
  end

  def update
    @coronavirus_travel = WorldLocation::CoronavirusTravel.new(@world_location)

    @coronavirus_travel.assign_attributes(coronavirus_travel_params)

    if @coronavirus_travel.save
      WorldLocationCoronavirusTravelWorker.perform_at(@coronavirus_travel.next_rag_applies_at, @world_location.id)
      redirect_to admin_coronavirus_travel_path(@world_location), notice: "Coronavirus travel updated successfully"
    else
      render :edit
    end
  end

private

  def load_world_location
    @world_location = WorldLocation.friendly.find(params[:id] || params[:world_location_id])
  end

  def coronavirus_travel_params
    params
      .require(:world_location_coronavirus_travel)
      .permit(:rag_status, :next_rag_status, :next_rag_applies_at, :status_out_of_date)
  end
end
