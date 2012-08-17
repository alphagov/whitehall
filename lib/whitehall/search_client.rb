module Whitehall
  class SearchClient
    class SearchUriNotSpecified < RuntimeError; end
    class SearchError < RuntimeError; end
    class SearchServiceError < SearchError; end
    class SearchTimeout < SearchError; end

    attr_accessor :search_uri

    def initialize(search_uri)
      raise SearchUriNotSpecified unless search_uri
      self.search_uri = search_uri
    end

    def search(query, format_filter = nil)
      return [] unless query.present?
      JSON.parse(search_response(:search, query, format_filter).body)
    end

    def autocomplete(query, format_filter = nil)
      return [] unless query.present?
      search_response(:autocomplete, query, format_filter).body
    end

    private

    def search_response(type, query, format_filter = nil)
      request_path = "/#{type}?q=#{CGI.escape(query)}"
      request_path << "&format_filter=#{CGI.escape(format_filter)}" if format_filter
      uri = URI("#{search_uri}#{request_path}")
      http = Net::HTTP.new(uri.host, uri.port)
      response = http.get(uri.request_uri, {"Accept" => "application/json"})
      raise SearchServiceError.new("#{response.code}: #{response.body}") unless response.code == "200"
      response
    rescue Timeout::Error
      raise SearchTimeout
    end
  end
end
