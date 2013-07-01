module Whitehall::DocumentFilter
  class Filterer
    attr_reader :page, :per_page, :direction, :date, :keywords, :people_ids, :locale
    class << self
      attr_accessor :number_of_documents_per_page
    end
    self.number_of_documents_per_page = 40

    def initialize(params = {})
      @params          = params
      @per_page        = params[:per_page] || Whitehall::DocumentFilter::Filterer.number_of_documents_per_page
      @page            = params[:page]
      @direction       = params[:direction]
      @date            = parse_date(@params[:date])
      @keywords        = params[:keywords]
      @locale          = params[:locale]

      @relevant_to_local_government = params[:relevant_to_local_government]
      @include_world_location_news  = params[:include_world_location_news]

      @topics          = @params[:topics]
      @departments     = @params[:departments]
      @people_ids      = @params[:people_id]
      @world_locations = @params[:world_locations]
    end

    def announcements_search
      raise NotImplementedError, 'you must provide #announcements_search implementation in your filterer subclass'
    end

    def publications_search
      raise NotImplementedError, 'you must provide #publications_search implementation in your filterer subclass'
    end

    def policies_search
      raise NotImplementedError, 'you must provide #policies_search implementation in your filterer subclass'
    end

    def documents
      raise NotImplementedError, 'you must provide #documents implementation in your filterer subclass'
    end

    def selected_topics
      find_by_slug(Classification, @topics)
    end

    def selected_organisations
      find_by_slug(Organisation, @departments)
    end

    def selected_publication_filter_option
      filter_option = @params[:publication_filter_option] || @params[:publication_type]
      Whitehall::PublicationFilterOption.find_by_slug(filter_option)
    end

    def selected_announcement_type_option
      filter_option = @params[:announcement_type_option] || @params[:announcement_type]
      Whitehall::AnnouncementFilterOption.find_by_slug(filter_option)
    end

    def selected_people_option
      if @people_ids && @people_ids.any? && @people_ids != ["all"]
        @people_ids.reject! {|l| l == "all"}
        People.where(id: @people_ids)
      else
        []
      end
    end

    def selected_locations
      if @world_locations && @world_locations.any? && @world_locations != ["all"]
        @world_locations.reject! {|l| l == "all"}
        WorldLocation.find_all_by_slug(@world_locations)
      else
        []
      end
    end

    def keywords
      if @keywords.present?
        @keywords.strip.split(/\s+/)
      else
        []
      end
    end

    def relevant_to_local_government
      @relevant_to_local_government.to_s == '1'
    end

    def include_world_location_news
      @include_world_location_news.to_s == '1'
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

    def parse_date(date)
      Date.parse(date) if date.present?
    rescue ArgumentError => e
      if e.message[/invalid date/]
        return nil
      else
        raise e
      end
    end
  end
end
