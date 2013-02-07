require 'whitehall/document_filter/filterer'

module Whitehall::DocumentFilter
  class Rummager < Filterer

    def default
      @default = {
        page: @page,
        per_page: @per_page
      }
    end

    def formats_from_model_names(model_names)
      model_names.map do |model_name|
        Object.const_get(model_name).format_name.gsub(" ", "_")
      end
    end

    def announcements_search
      filter_args = default.dup

      filter_args[:keywords] = @keywords if @keywords.present?
      filter_args.merge(filter_by_announcement_type)

      filter_args.merge(filter_date)

      filter_args.merge(sort)

      @results = Whitehall.government_search_client.filter()
    end

    def filter_by_people(search)
      if @people_ids.present? && @people_ids != ["all"]
        search.filter :term, people: @people_ids
      end
    end

    def sort
      if @direction.present? && @keywords.blank?
        case @direction
        when "before"
          {sort: { public_timestamp: :desc } }
        when "after"
          {sort: { public_timestamp: :asc } }
        end
      end
    end

    def filter_date(search)
      if @date.present? && @direction.present?
        case @direction
        when "before"
          {public_timestamp: {before: @date - 1.day}}
        when "after"
          {public_timestamp: {after: @date }}
        end
      end
    end

    def filter_by_announcement_type
      if selected_announcement_type_option
        type_filter =
          if selected_announcement_type_option.speech_types.present?
            {speech_type: selected_announcement_type_option.speech_types.map(&:id)}
          elsif selected_announcement_type_option.news_article_types.present?
            {news_article_type: selected_announcement_type_option.news_article_types.map(&:id)}
          else
            {}
          end
        type_filter[:format] = formats_from_model_names(selected_announcement_type_option.edition_types)
        type_filter
      else
        {format: ["speech", "news_article", "fatality_notice"]}
      end


    def publications_search
      # Publication.all
    end

    def policies_search
      # Policy.all
    end

    def documents
      objects = Edition.find(@results.map({ |h| h["id"] }))
      sorted = @results.map do |doc|
        objects.detect { |obj| obj.id == doc['id'] }
      end

      @documents ||= Kaminari.paginate_array(sorted).page(@page).per(@per_page)
    end

  end
end
