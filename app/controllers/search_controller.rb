class SearchController < PublicFacingController
  def index
    @search_term = search_term
    if search_term.present?
      @results = client.search(@search_term)
      render action: :results
    end
  end

  def autocomplete
    render text: client.autocomplete(search_term)
  end

  private

  def client
    Whitehall::SearchClient.new
  end

  def search_term
    params[:q]
  end
end