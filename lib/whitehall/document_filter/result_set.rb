module Whitehall::DocumentFilter
  class ResultSet
    def initialize(results, page, per_page)
      @results = results
      @docs = results.is_a?(Hash) ? results['results'] : []
      @page = page
      @per_page = per_page
    end

    def merged_results
      @docs.map do |doc|
        Result.new(doc)
      end
    end

    def paginated
      if @docs.empty?
        Kaminari.paginate_array([]).page(@page).per(@per_page)
      else
        Kaminari.paginate_array(merged_results, total_count: @results['total']).page(@page).per(@per_page)
      end
    end
  end
end