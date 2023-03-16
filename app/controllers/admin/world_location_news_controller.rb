class Admin::WorldLocationNewsController < Admin::BaseController
  before_action :load_world_location, only: %i[edit update show features]
  layout :get_layout

  def edit; end

  def show; end

  def index
    @active_world_locations, @inactive_world_locations = WorldLocation.ordered_by_name.partition(&:active?)

    render_design_system("index", "legacy_index", next_release: false)
  end

  def update
    if @world_location_news.update(world_location_news_params)
      redirect_to [:admin, @world_location_news], notice: "World location updated successfully"
    else
      render action: :edit
    end
  end

  def features
    @feature_list = @world_location.world_location_news.load_or_create_feature_list(params[:locale])

    filter_params = default_filter_params.merge(optional_filter_params).merge(state: "published")

    @filter = Admin::EditionFilter.new(Edition, current_user, filter_params)
    @featurable_topical_events = TopicalEvent.active
    @featurable_offsite_links = @world_location.world_location_news.offsite_links

    if request.xhr?
      render partial: "admin/feature_lists/search_results", locals: { feature_list: @feature_list }
    else
      render :features
    end
  end

private

  def default_filter_params
    {
      world_location: @world_location.id,
    }
  end

  def optional_filter_params
    params.slice(:page, :type, :world_location, :title).permit!.to_h.symbolize_keys
  end

  def load_world_location
    @world_location = WorldLocation.friendly.find(params[:id])
    @world_location_news = @world_location.world_location_news
  end

  def world_location_news_params
    params.require(:world_location_news).permit(
      :mission_statement,
      :title,
      featured_links_attributes: %i[url title id _destroy],
      world_location_attributes: %i[active id world_location_type],
    )
  end

  def get_layout
    design_system_actions = []
    design_system_actions += %w[index] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end
end
