require 'whitehall/document_filter/filterer'

module Whitehall::DocumentFilter
  class Rummager < Filterer
    attr_accessor :edition_eager_load
    def edition_eager_load
      @edition_eager_load ||= [:document, :organisations]
    end

    def announcements_search
      filter_args =
        standard_filter_args
          .merge(filter_by_announcement_type)

      @results = Whitehall.government_search_client.advanced_search(filter_args)
    end

    def publications_search
      filter_args =
        standard_filter_args
          .merge(filter_by_publication_type)

      @results = Whitehall.government_search_client.advanced_search(filter_args)
    end

    def policies_search
      filter_args =
        standard_filter_args
          .merge(search_format_types: [Policy.search_format_type])

      @results = Whitehall.government_search_client.advanced_search(filter_args)
    end

    def default_filter_args
      @default = {
        page: @page.to_s,
        per_page: @per_page.to_s
      }
    end

    def standard_filter_args
      default_filter_args
        .merge(filter_by_keywords)
        .merge(filter_by_relevance_to_local_government)
        .merge(filter_by_people)
        .merge(filter_by_topics)
        .merge(filter_by_organisations)
        .merge(filter_by_locations)
        .merge(filter_by_date)
        .merge(sort)
    end

    def filter_by_keywords
      if @keywords.present?
        {keywords: @keywords.to_s}
      else
        {}
      end
    end

    def filter_by_relevance_to_local_government
      if relevant_to_local_government
        {relevant_to_local_government: "1"}
      else
        {}
      end
    end

    def filter_by_people
      if @people_ids.present? && @people_ids != ["all"]
        {people: @people.map(&:slug)}
      else
        {}
      end
    end

    def filter_by_topics
      if selected_topics.any?
        {topics: selected_topics.map(&:slug)}
      else
        {}
      end
    end

    def filter_by_organisations
      if selected_organisations.any?
        {organisations: selected_organisations.map(&:slug)}
      else
        {}
      end
    end

    def filter_by_locations
      if selected_locations.any?
        {world_locations: selected_locations.map(&:slug)}
      else
        {}
      end
    end

    def filter_by_date
      if @date.present? && @direction.present?
        case @direction
        when "before"
          {public_timestamp: {before: (@date - 1.day).to_s(:db)}}
        when "after"
          {public_timestamp: {after: @date.to_s(:db) }}
        else
          {}
        end
      else
        {}
      end
    end

    def sort
      if @direction.present? && @keywords.blank?
        case @direction
        when "before"
          {order: { public_timestamp: "desc" } }
        when "after"
          {order: { public_timestamp: "asc" } }
        else
          {}
        end
      else
        {}
      end
    end

    def filter_by_announcement_type
      announcement_types =
        if selected_announcement_type_option
          selected_announcement_type_option.search_format_types
        elsif include_world_location_news
          [Announcement.search_format_type]
        else
          Announcement.concrete_descendant_search_format_types - [WorldLocationNewsArticle.search_format_type]
        end
      {search_format_types: announcement_types}
    end

    def filter_by_publication_type
      publication_types =
        if selected_publication_filter_option
          selected_publication_filter_option.search_format_types
        else
          Publicationesque.concrete_descendant_search_format_types
        end
      {search_format_types: publication_types}
    end

    def documents
      if @results.empty? || @results['results'].empty?
        @documents ||= Kaminari.paginate_array([]).page(@page).per(@per_page)
      else
        objects = Edition.with_translations.with_translations_for(:organisations).includes(self.edition_eager_load).find(@results['results'].map{ |h| h["id"] })
        sorted = @results['results'].map do |doc|
          objects.detect { |obj| obj.id == doc['id'] }
        end

        @documents ||= Kaminari.paginate_array(sorted, total_count: @results['total']).page(@page).per(@per_page)
      end
    end

  end
end
