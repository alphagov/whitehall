require 'whitehall/document_filter/filterer'

module Whitehall::DocumentFilter
  class Rummager < Filterer
    def announcements_search
      filter_args = standard_filter_args.merge(filter_by_announcement_type)
      @results = Whitehall.government_search_client.advanced_search(filter_args)
    end

    def publications_search
      filter_args = standard_filter_args.merge(filter_by_publication_type)
      @results = Whitehall.government_search_client.advanced_search(filter_args)
    end

    def policies_search
      filter_args = standard_filter_args.merge(search_format_types: [Policy.search_format_type])
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
      dates_hash = {}
      if @form_date.present?
        dates_hash.merge(from: @from_date)
      end
      if @to_date.present?
        dates_hash.merge(to: @to_date)
      end
      if dates_hash.empty?
        {}
      else
        {public_timestamp: dates_hash}
      end
    end

    def sort
      if (@form_date.present? || @to_date.present?) && @keywords.blank?
        {order: { public_timestamp: "desc" } }
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
      @documents ||= ResultSet.new(@results, @page, @per_page).paginated
    end
  end
end
