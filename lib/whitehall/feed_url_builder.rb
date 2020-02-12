module Whitehall
  class FeedUrlBuilder
    attr_accessor :params

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
        values.empty? || values.all?(&:blank?) || values.include?("all") || DocumentFilter::Options.new.invalid_filter_key?(key)
      }.merge(format: :atom).symbolize_keys
    end
  end
end
