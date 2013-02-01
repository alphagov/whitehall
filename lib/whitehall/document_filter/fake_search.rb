module Whitehall::DocumentFilter
  class FakeSearch
    attr_reader :page, :direction, :date

    def initialize(params = {})
      @params = params
      @per_page = params[:per_page] || 20
      @page = params[:page]
      @direction = params[:direction]
      @date = parse_date(@params[:date]) if @params[:date].present?
      @keywords = params[:keywords]
      @people_ids = @params[:people_id]
    end

    def announcements_search
      # Announcement.all
    end

    def publications_search
      # Publication.all
    end

    def policies_search
      # Policy.all
    end

    def documents
      @documents ||= Kaminari.paginate_array([]).page(@page).per(@per_page)
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
      filter_option = @params[:announcement_type_option] || @params[:announcement_type]
      Whitehall::AnnouncementFilterOption.find_by_slug(filter_option)
    end

    def selected_consultation_type_option
      @params[:consultation_type_option] unless @params[:consultation_type_option] == "all"
    end

    def selected_people_option
      @people_ids
    end

    def keywords
      if @keywords.present?
        @keywords.strip.split(/\s+/)
      else
        []
      end
    end

    def parse_date(date)
      Date.parse(date)
      rescue ArgumentError => e
        if e.message[/invalid date/]
          return nil
        else
          raise e
      end
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

  end
end
