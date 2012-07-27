class SearchController < PublicFacingController
  def index
    @search_term = search_term
    if search_term.present?
      @results = Whitehall.search_client.search(@search_term)
      render action: :results
    end
  end

  def autocomplete
    render text: Whitehall.search_client.autocomplete(search_term)
  end

  private

  def search_term
    params[:q]
  end
end