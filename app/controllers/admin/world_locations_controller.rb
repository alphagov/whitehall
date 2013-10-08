class Admin::WorldLocationsController < Admin::BaseController
  before_filter :load_world_location, only: [:edit, :update, :show, :features]

  def index
    @active_world_locations, @inactive_world_locations = WorldLocation.ordered_by_name.partition { |wl| wl.active? }
  end

  def edit
    @world_location.top_tasks.build unless @world_location.top_tasks.any?
  end

  def update
    if @world_location.update_attributes(params[:world_location])
      redirect_to [:admin, @world_location], notice: "World location updated successfully"
    else
      render action: :edit
    end
  end

  def features
    @feature_list = @world_location.load_or_create_feature_list(params[:locale])
    filter_params = params.slice(:page, :type, :world_location_ids, :title).
      reverse_merge(world_location_ids: [@world_location.id]).
      merge(state: 'published')
    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @featurable_topical_events = []
  end

  private

  def load_world_location
    @world_location = WorldLocation.find(params[:id] || params[:world_location_id])
  end
end
