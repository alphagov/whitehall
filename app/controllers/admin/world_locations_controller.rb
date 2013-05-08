class Admin::WorldLocationsController < Admin::BaseController
  before_filter :load_world_location, only: [:edit, :update, :show, :features]
  before_filter :build_mainstream_links, only: [:edit]
  before_filter :destroy_blank_mainstream_links, only: [:create, :update]

  def index
    @active_world_locations, @inactive_world_locations = WorldLocation.ordered_by_name.partition { |wl| wl.active? }
  end

  def edit
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

  def build_mainstream_links
    unless @world_location.mainstream_links.any?(&:new_record?)
      @world_location.mainstream_links.build
    end
  end

  def destroy_blank_mainstream_links
    if params[:world_location][:mainstream_links_attributes]
      params[:world_location][:mainstream_links_attributes].each do |index, link|
        if link[:title].blank? && link[:url].blank?
          link[:_destroy] = "1"
        end
      end
    end
  end
end
