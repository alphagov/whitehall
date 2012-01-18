module Whitehall
  class SearchClient
    class SearchUriNotSpecified < RuntimeError; end

    cattr_accessor :search_uri

    def search(query)
      raise SearchUriNotSpecified unless search_uri

      uri = URI("#{search_uri}/search?q=#{query}")
      JSON.parse(search_response(uri).body)
    end

    def autocomplete(query)
      uri = URI("#{search_uri}/autocomplete?q=#{query}")
      search_response(uri).body
    end

    private

    def search_response(uri)
      request = Net::HTTP::Get.new(uri.request_uri)
       request["Accept"] = "application/json"

       Net::HTTP.start(uri.host, uri.port) {|http|
         http.request(request)
       }
    end
  end
end