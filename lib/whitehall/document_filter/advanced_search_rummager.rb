require 'whitehall/document_filter/filterer'

module Whitehall::DocumentFilter
  class AdvancedSearchRummager < Filterer
    def publications_search
      filter_args = standard_filter_args.merge(filter_by_publication_type)
                                        .merge(filter_by_official_document_status)
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
        .merge(filter_by_people)
        .merge(filter_by_topics)
        .merge(filter_by_organisations)
        .merge(filter_by_locations)
        .merge(filter_by_date)
        .merge(filter_by_taxon)
        .merge(sort)
    end

    def filter_by_keywords
      if @keywords.present?
        { keywords: @keywords.to_s }
      else
        {}
      end
    end

    def filter_by_people
      if @people.present? && @people != %w[all]
        { people: @people }
      else
        {}
      end
    end

    # Note that "Topics" are called "Policy Areas" in Rummager. That's why we
    # use `policy_areas` as the filter key here.
    def filter_by_topics
      if selected_topics.any?
        { policy_areas: selected_topics.map(&:slug) }
      else
        {}
      end
    end

    def filter_by_taxon
      if selected_subtaxons.any? { |taxon| taxon != "all" }
        { part_of_taxonomy_tree: selected_subtaxons }
      elsif selected_taxons.any?
        { part_of_taxonomy_tree: selected_taxons }
      else
        {}
      end
    end

    def filter_by_organisations
      if selected_organisations.any?
        { organisations: selected_organisations.map(&:slug) }
      else
        {}
      end
    end

    def filter_by_locations
      if selected_locations.any?
        { world_locations: selected_locations.map(&:slug) }
      else
        {}
      end
    end

    def filter_by_official_document_status
      case selected_official_document_status
      when "command_and_act_papers"
        { has_official_document: "1" }
      when "command_papers_only"
        { has_command_paper: "1" }
      when "act_papers_only"
        { has_act_paper: "1" }
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
        { public_timestamp: dates_hash }
      end
    end

    def sort
      if @keywords.blank?
        { order: { public_timestamp: "desc" } }
      else
        {}
      end
    end

    def filter_by_publication_type
      publication_types =
        if selected_publication_filter_option
          selected_publication_filter_option.search_format_types
        else
          Publicationesque.concrete_descendant_search_format_types
        end
      { search_format_types: publication_types }
    end

    def documents
      @documents ||= ResultSet.new(@results, @page, @per_page).paginated
    end
  end
end
