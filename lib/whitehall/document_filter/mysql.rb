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

    def apply_filters
      filter_by_locale!
      filter_by_topics!
      filter_by_departments!
      filter_by_keywords!
      filter_by_date!
      filter_by_publication_filter_option!
      filter_by_announcement_filter_option!
      filter_by_include_world_location_news_option!
      filter_by_location!
      filter_by_people!
      apply_sort_direction!
      paginate!
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
      if @from_date.present?
        @documents = @documents.published_after(@from_date)
      end
      if @to_date.present?
        @documents = @documents.published_before(@to_date)
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
      if selected_announcement_filter_option
        @documents = @documents.where(@documents.arel_table[:type].in(
          selected_announcement_filter_option.edition_types))
        if selected_announcement_filter_option.speech_types.present?
          @documents = @documents.where(
            @documents.arel_table[:speech_type_id].in(
              selected_announcement_filter_option.speech_types.map(&:id)))
        elsif selected_announcement_filter_option.news_article_types.present?
          @documents = @documents.where(
            @documents.arel_table[:news_article_type_id].in(
              selected_announcement_filter_option.news_article_types.map(&:id)))
        end
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

    # Whitehall has two ways to associate people with editions.
    #  1. For Speech types:
    #   by adding an id to the role_appointment_id field in the editions table (for Speech types)
    #  2. For NewsArticle, Consultation, Publication, FatalityNotice:
    #   by adding one or more entries to the edition_role_appointments table
    # Since filtering with a `where` clause by, for example, `role_appointment_id` on the editions table
    # could potentially filter out some editions that have the many to many through edition_role_appointments
    # (and vice versa), we cannot simply chain the filtering of each of these against the @documents ActiveRecord
    # relation.
    # As such, we end up with this monstrosity which essentially runs two queries to get the list
    # of document ids that are associated with a role appointment, and then filters @documents against that
    # list of ids.
    def filter_by_people!
      if selected_people_option.any?
        people = Person.where(slug: @people_ids)

        @documents = @documents.where(id: document_ids_associated_with_people(people))
      end
    end

    def paginate!
      @documents = @documents.page(page).per(per_page)
    end

    def apply_sort_direction!
      @documents = @documents.in_reverse_chronological_order
    end

    def document_ids_associated_with_people(people)
      document_ids_with_role_appointments(people) + document_ids_with_a_role_appointment(people)
    end

    def document_ids_with_role_appointments(people)
      @documents
        .joins("INNER JOIN `edition_role_appointments` ON `edition_role_appointments`.`edition_id` = `editions`.`id`")
        .where(edition_role_appointments: { role_appointment_id: role_appointment_ids_for(people) })
        .pluck(:id)
    end

    def document_ids_with_a_role_appointment(people)
      @documents
        .where(role_appointment_id: role_appointment_ids_for(people))
        .pluck(:id)
    end

    def role_appointment_ids_for(record_set)
      record_set.collect do |record|
        record.role_appointments.flat_map(&:id)
      end
    end
  end
end
