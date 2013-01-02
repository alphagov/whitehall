class Admin::WorldLocationsController < Admin::BaseController
  before_filter :load_world_location, only: [:edit, :update]
  before_filter :load_news_articles, only: [:edit, :update]

  def index
    @world_locations = WorldLocation.all
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
    @news_articles = NewsArticle.accessible_to(current_user).published.in_world_location(@world_location).by_first_published_at
  end
end
