class Admin::Api::SearchController < Admin::BaseController
  skip_before_filter :verify_authenticity_token, only: [:reindex_specialist_sector_editions]

  def reindex_specialist_sector_editions
    published_and_tagged_editions = Edition.published.joins(:specialist_sectors).where(specialist_sectors: {tag: params[:slug]})
    published_and_tagged_editions.each do |edition|
      edition.update_in_search_index
    end

    render json: {result: 'ok', count: published_and_tagged_editions.count}
  end
end
