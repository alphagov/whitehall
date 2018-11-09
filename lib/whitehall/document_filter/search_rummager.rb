require 'whitehall/document_filter/filterer'

module Whitehall::DocumentFilter
  class SearchRummager < Filterer
    def announcements_search
      filter_args = standard_filter_args.merge(filter_by_announcement_type)
      @results = Whitehall.search_client.search(filter_args)
    end

    def default_filter_args
      @default = {
        start: position_in_result_list.to_s,
        count: @per_page.to_s,
        fields: %w[content_store_document_type government_name is_historic
                   public_timestamp organisations operational_field format
                   content_id title description display_type link document_collections]
      }
    end

    def standard_filter_args
      default_filter_args
        .merge(filter_by_keywords)
        .merge(filter_by_people)
        .merge(filter_by_organisations)
        .merge(filter_by_locations)
        .merge(filter_by_date)
        .merge(filter_by_taxon)
        .merge(filter_by_topical_event)
        .merge(sort)
    end

    def filter_by_keywords
      if @keywords.present?
        { q: @keywords.to_s }
      else
        {}
      end
    end

    def filter_by_people
      if @people.present? && @people != %w[all]
        { filter_people: @people }
      else
        {}
      end
    end

    def filter_by_taxon
      if selected_subtaxons.any? { |taxon| taxon != "all" }
        { filter_part_of_taxonomy_tree: selected_subtaxons }
      elsif selected_taxons.any?
        { filter_part_of_taxonomy_tree: selected_taxons }
      else
        {}
      end
    end

    def filter_by_organisations
      if selected_organisations.any?
        { filter_organisations: selected_organisations.map(&:slug) }
      else
        {}
      end
    end

    def filter_by_locations
      if selected_locations.any?
        { filter_world_locations: selected_locations.map(&:slug) }
      else
        {}
      end
    end

    def filter_by_topical_event
      if selected_topical_events.any?
        { filter_topical_events: selected_topical_events.map(&:slug) }
      else
        {}
      end
    end

    def filter_by_date
      dates_hash = {}
      dates_hash[:from] = @from_date.to_s if @from_date.present?
      dates_hash[:to] = @to_date.to_s if @to_date.present?

      if dates_hash.empty?
        {}
      else
        { filter_public_timestamp: dates_hash.map { |k, v| "#{k}:#{v}" }.join(',') }
      end
    end

    def sort
      if @keywords.blank?
        { order: '-public_timestamp' }
      else
        {}
      end
    end

    def filter_by_announcement_type
      announcement_types =
        if selected_announcement_filter_option
          selected_announcement_filter_option.document_type
        elsif include_world_location_news
          all_announcement_types
        else
          non_world_announcement_types
        end
      { filter_content_store_document_type: announcement_types }
    end

    def documents
      @documents ||= ResultSet.new(@results, @page, @per_page, SearchResult).paginated
    end

  private

    def all_announcement_types
      %w(world_location_news_article world_news_story).concat(non_world_announcement_types)
    end

    def non_world_announcement_types
      all_announcement_filter_options.map(&:document_type).flatten
    end

    def position_in_result_list
      (@page.to_i - 1) * @per_page.to_i
    end
  end
end
