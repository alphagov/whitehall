module Whitehall::DocumentFilter
  class ResultSet
    def initialize(results, page, per_page, result_type)
      @results = results
      @docs = results.respond_to?(:[]) ? results['results'] : []
      @page = page
      @per_page = per_page
      @result_type = result_type
    end

    def merged_results
      @docs.map { |doc| @result_type.new(doc) }
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
