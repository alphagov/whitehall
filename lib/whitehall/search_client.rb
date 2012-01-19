module Whitehall
  class SearchClient
    class SearchUriNotSpecified < RuntimeError; end

    cattr_accessor :search_uri

    def search(query)
      raise SearchUriNotSpecified unless search_uri
      JSON.parse(search_response(:search, query).body)
    end

    def autocomplete(query)
      raise SearchUriNotSpecified unless search_uri
      search_response(:autocomplete, query).body
    end

    private

    def search_response(type, query)
      uri = URI("#{search_uri}/#{type}?q=#{CGI.escape(query)}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.get(uri.request_uri, {"Accept" => "application/json"})
    end
  end
end