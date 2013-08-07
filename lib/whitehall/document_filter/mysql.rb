require 'whitehall/document_filter/filterer'

module Whitehall::DocumentFilter
  class Mysql < Filterer
    attr_accessor :documents

    def publications_search
      @documents = Publicationesque.published.includes(:document, :organisations)
      apply_filters
    end

    def announcements_search
      @documents = Announcement.published.includes(:document, :organisations)
      apply_filters
    end

    def policies_search
      @documents = Policy.published.includes(:document)
      apply_filters
    end

    def apply_filters
      filter_by_locale!
      filter_by_topics!
      filter_by_departments!
      filter_by_keywords!
      filter_by_date!
      filter_by_publication_filter_option!
      filter_by_announcement_filter_option!
      filter_by_relevant_to_local_government_option!
      filter_by_include_world_location_news_option!
      filter_by_location!
      paginate!
      apply_sort_direction!
    end

    private

    def filter_by_locale!
      @documents = @documents.with_translations(locale) if locale
    end

    def filter_by_topics!
      if selected_topics.any?
        @documents = @documents.published_in_topic(selected_topics) 
      end
    end

    def filter_by_departments!
      if selected_organisations.any?
        @documents = @documents.in_organisation(selected_organisations)
      end
    end

    def filter_by_keywords!
      if keywords.any?
        @documents = @documents.with_title_or_summary_containing(*keywords) 
      end
    end

    def filter_by_date!
      if date.present? && direction.present?
        case direction
        when "before"
          @documents = @documents.published_before(date)
        when "after"
          @documents = @documents.published_after(date)
        end
      end
    end

    def filter_by_publication_filter_option!
      if selected_publication_filter_option
        publication_ids = selected_publication_filter_option.publication_types.map(&:id)
        if selected_publication_filter_option.edition_types.any?
          edition_types = selected_publication_filter_option.edition_types
          editions = @documents.arel_table
          @documents = @documents.where(
            editions[:publication_type_id].in(publication_ids).or(
              editions[:type].in(edition_types)))
        else
          @documents = @documents.where(publication_type_id: publication_ids)
        end
      end
    end

    def filter_by_announcement_filter_option!
      if selected_announcement_type_option
        @documents = @documents.where(@documents.arel_table[:type].in(
          selected_announcement_type_option.edition_types))
        if selected_announcement_type_option.speech_types.present?
          @documents = @documents.where(
            @documents.arel_table[:speech_type_id].in(
              selected_announcement_type_option.speech_types.map(&:id)))
        elsif selected_announcement_type_option.news_article_types.present?
          @documents = @documents.where(
            @documents.arel_table[:news_article_type_id].in(
              selected_announcement_type_option.news_article_types.map(&:id)))
        end
      end
    end

    def filter_by_relevant_to_local_government_option!
      if relevant_to_local_government
        @documents = @documents.relevant_to_local_government(relevant_to_local_government)
      end
    end

    def filter_by_include_world_location_news_option!
      # By defaults we don't want to include any WorldLocationNewsArticles
      unless include_world_location_news
        @documents = @documents.without_editions_of_type(WorldLocationNewsArticle)
      end
    end

    def filter_by_location!
      if selected_locations.any?
        # we start from Announcement or Publicationesque, but not all
        # Publicationesque subtypes have a world_locations join (only
        # Publication does), so we have to do this join manually.
        @documents = @documents.joins("INNER JOIN `edition_world_locations` ON `edition_world_locations`.`edition_id` = `editions`.`id`
INNER JOIN `world_locations` ON `world_locations`.`id` = `edition_world_locations`.`world_location_id`")
        @documents = @documents.where(world_locations: {id: selected_locations.map(&:id)})
      end
    end

    def paginate!
      if page.present?
        @documents = @documents.page(page).per(per_page)
      end
    end

    def apply_sort_direction!
      if direction.present?
        case direction
        when "before"
          @documents = @documents.in_reverse_chronological_order
        when "after"
          @documents = @documents.in_chronological_order
        when "alphabetical"
          @documents = @documents.alphabetical(locale || I18n.default_locale)
        end
      end
    end
  end
end
