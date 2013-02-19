class Admin::WorldLocationsController < Admin::BaseController
  before_filter :load_world_location, only: [:edit, :update]
  before_filter :load_news_articles, only: [:edit, :update]
  before_filter :build_mainstream_links, only: [:edit]
  before_filter :destroy_blank_mainstream_links, only: [:create, :update]

  def index
    @world_locations = WorldLocation.ordered_by_name
  end

  def edit
  end

  def update
    if @world_location.update_attributes(params[:world_location])
      redirect_to admin_world_locations_path, notice: "World location updated successfully"
    else
      render action: :edit
    end
  end

  private

  def load_world_location
    @world_location = WorldLocation.find(params[:id])
  end

  def load_news_articles
    @news_articles = NewsArticle.accessible_to(current_user).published.in_world_location(@world_location).in_reverse_chronological_order
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
