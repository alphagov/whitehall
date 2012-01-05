module Whitehall
  class SearchClient
    class SearchUriNotSpecified < RuntimeError; end

    cattr_accessor :search_uri, :http_auth_username, :http_auth_password

    def search(query)
      raise SearchUriNotSpecified unless search_uri

      uri = URI("#{search_uri}?q=#{query}")

      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth http_auth_username, http_auth_password
      request["Accept"] = "application/json"

      response = Net::HTTP.start(uri.host, uri.port) {|http|
        http.request(request)
      }
      JSON.parse(response.body)
    end
  end
end