
module Whitehall::DocumentFilter
  class Mysql
    extend Forwardable
    attr_reader :documents

    delegate [:count, :current_page, :num_pages, :last_page?, :first_page?, :total_count] => :documents

    class << self
      attr_accessor :number_of_documents_per_page
    end
    self.number_of_documents_per_page = 20

    def initialize(documents, params = {})
      @documents = documents
      @params = params
      filter_by_topics!
      filter_by_departments!
      filter_by_keywords!
      filter_by_date!
      filter_by_publication_filter_option!
      filter_by_announcement_filter_option!
      filter_by_relevant_to_local_government_option!
      filter_by_location!
      paginate!
      apply_sort_direction!
    end

    def all_topics
      Topic.with_content.order(:name)
    end

    def selected_topics
      find_by_slug(Topic, @params[:topics])
    end

    def selected_organisations
      find_by_slug(Organisation, @params[:departments])
    end

    def selected_publication_filter_option
      filter_option = @params[:publication_filter_option] || @params[:publication_type]
      Whitehall::PublicationFilterOption.find_by_slug(filter_option)
    end

    def selected_announcement_type_option
      Whitehall::AnnouncementFilterOption.find_by_slug(@params[:announcement_type_option])
    end

    def selected_locations
      if @params[:locations].present? && @params[:locations] != ["all"]
        @params[:locations].reject! {|l| l == "all"}
        WorldLocation.find_all_by_slug(@params[:locations])
      else
        []
      end
    end

    def keywords
      if @params[:keywords].present?
        @params[:keywords].strip.split(/\s+/)
      else
        []
      end
    end

    def direction
      @params[:direction]
    end

    def date
      Date.parse(@params[:date]) if @params[:date].present?
    rescue ArgumentError => e
      if e.message[/invalid date/]
        return nil
      else
        raise e
      end
    end

    def relevant_to_local_government
      @params[:relevant_to_local_government].present? && @params[:relevant_to_local_government].to_s == '1'
    end

  private

    def find_by_slug(klass, slugs)
      @selected ||= {}
      @selected[klass] ||= if slugs.present? && !slugs.include?("all")
        klass.where(slug: slugs)
      else
        []
      end
    end

    def filter_by_topics!
      @documents = @documents.published_in_topic(selected_topics) if selected_topics.any?
    end

    def filter_by_departments!
      @documents = @documents.in_organisation(selected_organisations) if selected_organisations.any?
    end

    def filter_by_keywords!
      @documents = @documents.with_summary_containing(*keywords) if keywords.any?
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
          @documents = @documents.where(editions[:publication_type_id].in(publication_ids).or(editions[:type].in(edition_types)))
        else
          @documents = @documents.where(publication_type_id: publication_ids)
        end
      end
    end

    def filter_by_announcement_filter_option!
      if selected_announcement_type_option
        @documents = @documents.where(@documents.arel_table[:type].in(selected_announcement_type_option.edition_types))
        if selected_announcement_type_option.speech_types.present?
          @documents = @documents.where(@documents.arel_table[:speech_type_id].in(selected_announcement_type_option.speech_types.map(&:id)))
        elsif selected_announcement_type_option.news_article_types.present?
          @documents = @documents.where(@documents.arel_table[:news_article_type_id].in(selected_announcement_type_option.news_article_types.map(&:id)))
        end
      end
    end

    def filter_by_relevant_to_local_government_option!
      # By default we don't want to surface these results
      @documents = @documents.where(relevant_to_local_government: relevant_to_local_government)
    end

    def filter_by_location!
      if selected_locations.any?
        @documents = @documents.joins(:world_locations)
        @documents = @documents.where(world_locations: {id: selected_locations.map(&:id)})
      end
    end

    def paginate!
      if @params[:page].present?
        @documents = @documents.page(@params[:page]).per(self.class.number_of_documents_per_page)
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
          @documents = @documents.alphabetical
        end
      end
    end
  end
end
