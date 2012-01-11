class SearchController < PublicFacingController
  def index
    client = Whitehall::SearchClient.new
    @search_term = params[:q]
    @results = client.search(@search_term)
  end
end