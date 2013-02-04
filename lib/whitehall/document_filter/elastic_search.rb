require 'whitehall/document_filter/filterer'

module Whitehall::DocumentFilter
  class ElasticSearch < Filterer

    def announcements_search
      @query ||= Tire.search Whitehall.government_search_index_name, load: {include: [:document, :organisations]} do |search|
        filter_by_announcement_type(search)
        filter_by_people(search)
        apply_filters(search)
      end
    end

    def publications_search
      @query ||= Tire.search Whitehall.government_search_index_name, load: {include: [:document, :organisations, :attachments, response: :attachments]} do |search|
        filter_by_publication_type(search)
        apply_filters(search)
      end
    end

    def policies_search
      @query ||= Tire.search Whitehall.government_search_index_name, load: {include: [:document, :organisations]} do |search|
        search.filter :term, format: "policy"
        apply_filters(search)
      end
    end

    def documents
      @query.results
    end

    private

    def keyword_search(search)
      if @keywords.present?
        search.query do |q|
          # q.string @keywords
          q.boolean do |it|
            it.should do |q|
              q.text 'title', @keywords, { type: 'phrase_prefix',
                                           operator: 'and',
                                           analyzer: 'query_default',
                                           boost: 10,
                                           fuzziness: 0.5 }
            end
            it.should { |q| q.string @keywords, default_operator: 'and', analyzer: 'query_default' }
          end
        end
      else
        search.query { all }
      end
    end

    def filter_topics(search)
      if selected_topics.any?
        search.filter :term, topics: selected_topics.map(&:id)
      end
    end

    def filter_organisations(search)
      if selected_organisations.any?
        search.filter :term, organisations: selected_organisations.map(&:id)
      end
    end

    def filter_by_announcement_type(search)
      if selected_announcement_type_option
        if selected_announcement_type_option.speech_types.present?
          search.filter :term, {speech_type: selected_announcement_type_option.speech_types.map(&:id)}
        elsif selected_announcement_type_option.news_article_types.present?
          search.filter :term, {news_article_type: selected_announcement_type_option.news_article_types.map(&:id)}
        end
        search.filter :term, format: formats_from_model_names(selected_announcement_type_option.edition_types)
      else
        search.filter :or, [{term: {format: "speech"}}, {term: {format: "news_article"}}, {term: {format: "fatality_notice"}}]
      end
    end

    def formats_from_model_names(model_names)
      model_names.map do |model_name|
        Object.const_get(model_name).format_name.gsub(" ", "_")
      end
    end

    def filter_by_publication_type(search)
      if selected_publication_filter_option
        publication_ids = selected_publication_filter_option.publication_types.map(&:id)
        if selected_publication_filter_option.edition_types.any?
          edition_types = selected_publication_filter_option.edition_types
          format = edition_types.first.underscore
          search.filter :or, [{term: {format: format}}, {term: {publication_type: publication_ids}}]
        else
          search.filter :term, publication_type: publication_ids
        end
        if selected_consultation_type_option
          search.filter :term, display_type: selected_consultation_type_option
        end
      else
        search.filter :or, [{term: {format: "publication"}}, {term: {format: "statistical_data_set"}}, {term: {format: "consultation"}}]
      end
    end

    def filter_by_people(search)
      if @people_ids.present? && @people_ids != ["all"]
        search.filter :term, people: @people_ids
      end
    end

    def filter_date_and_sort(search)
      if @date.present? && @direction.present?
        case @direction
        when "before"
          search.filter :range, public_timestamp: {to: @date - 1.day}
          # Sort ordering is messing with the scores
          search.sort { by :public_timestamp, :desc } unless @keywords.present?
        when "after"
          search.filter :range, public_timestamp: {from: @date }
          search.sort { by :public_timestamp} unless @keywords.present?
        end
      end
    end

    def paginate(search)
      search.size @per_page
      search.from( @page.to_i <= 1 ? 0 : (@per_page.to_i * (@page.to_i-1)) )
    end

    def apply_filters(search)
      keyword_search(search)
      filter_topics(search)
      filter_organisations(search)
      filter_date_and_sort(search)
      paginate(search)
    end
  end
end
