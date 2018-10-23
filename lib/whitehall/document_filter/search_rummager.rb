require 'whitehall/document_filter/filterer'

module Whitehall::DocumentFilter
  class SearchRummager < Filterer
    def announcements_search
      filter_args = standard_filter_args.merge(filter_by_announcement_type)
      @results = Whitehall.search_client.search(filter_args)
    end

    def default_filter_args
      @default = {
        start: @page.to_s,
        count: @per_page.to_s,
        fields: %w[content_store_document_type government_name is_historic
                   public_timestamp organisations operational_field format
                   content_id title description display_type id]
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
          selected_announcement_filter_option.search_format_types
        elsif include_world_location_news
          [Announcement.search_format_type]
        else
          non_world_announcement_types
        end
      { filter_search_format_types: announcement_types }
    end

    def documents
      @documents ||= ResultSet.new(@results, @page, @per_page).paginated
    end

  private

    def all_announcement_types
      all_descendants = Announcement.concrete_descendant_search_format_types
      descendants_without_news = all_descendants - [NewsArticle.search_format_type]
      news_article_subtypes = NewsArticleType.search_format_types
      descendants_without_news + news_article_subtypes
    end

    def non_world_announcement_types
      types = all_announcement_types
      types = types - NewsArticleType::WorldNewsStory.search_format_types
      types - [WorldLocationNewsArticle.search_format_type]
    end
  end
end
