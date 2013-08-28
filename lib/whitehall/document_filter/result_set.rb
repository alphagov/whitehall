module Whitehall::DocumentFilter
  class ResultSet
    def initialize(results, page, per_page)
      @results = results
      @docs = results.is_a?(Hash) ? results['results'] : []
      @organisations = prefetch("organisations", Organisation.includes(:translations))
      @topics = prefetch("topics", Classification.scoped)
      @document_series = prefetch("document_series", DocumentSeries.scoped)
      @operational_fields = prefetch("operational_field", OperationalField.scoped)
      @page = page
      @per_page = per_page
    end

    def prefetch(field_name, association)
      return [] if @docs.empty?
      slugs = @docs.map { |doc| doc[field_name] }.flatten.uniq
      association.where(slug: slugs).each_with_object({}) do |item, memo|
        memo[item.slug] = item
      end
    end

    def merged_results
      @docs.map do |doc|
        Result.new(doc, @organisations, @topics, @document_series, @operational_fields)
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