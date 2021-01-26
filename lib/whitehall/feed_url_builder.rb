module Whitehall
  class FeedUrlBuilder
    attr_accessor :params

    OPTION_NAMES_TO_FILTER_KEYS = {
      document_type: "document_type",
      publication_type: "publication_filter_option",
      organisations: "departments",
      announcement_type: "announcement_filter_option",
      official_documents: "official_document_status",
      locations: "world_locations",
      people: "people",
      taxons: "taxons",
      subtaxons: "subtaxons",
    }.freeze

    def initialize(params = {})
      @params = params
    end

    def url
      case params[:document_type]
      when "publications"
        Whitehall.url_maker.publications_url(url_params)
      when "announcements"
        Whitehall.url_maker.announcements_url(url_params)
      when "statistics"
        Whitehall.url_maker.statistics_url(url_params)
      end
    end

  protected

    def url_params
      params.except(:document_type).reject { |key, value|
        values = Array(value)
        values.empty? || values.all?(&:blank?) || values.include?("all") || invalid_filter_key?(key)
      }.merge(format: :atom).symbolize_keys
    end

    def invalid_filter_key?(filter_key)
      !valid_filter_key?(filter_key)
    end

    def valid_filter_key?(filter_key)
      OPTION_NAMES_TO_FILTER_KEYS.value?(filter_key.to_s)
    end
  end
end
