class WorldwideRedirectChecker
  class Response
    REDIRECT_CODE = 301

    attr_reader :url, :expected_redirect_url, :connection

    def initialize(url, expected_redirect_url, connection)
      @url = url
      @expected_redirect_url = expected_redirect_url
      @connection = connection
    end

    def is_correct_redirect?
      is_redirect? && redirect_url_matches_expected_url?
    end

    def error_message
      return "not a redirect (Status: #{http_response.status})" unless is_redirect?
      return "does not match expected_url (#{response_redirect_url} instead of #{expected_redirect_url})" unless redirect_url_matches_expected_url?
    end

  private

    def is_redirect?
      http_response.status == REDIRECT_CODE
    end

    def redirect_url_matches_expected_url?
      response_redirect_url == expected_redirect_url
    end

    def http_response
      @http_response ||= connection.get(URI.parse(Plek.current.website_root + url))
    end

    def response_redirect_url
      http_response.headers["location"]
    end
  end

  attr_reader :redirects

  def initialize(redirects)
    @redirects = redirects
  end

  def call
    redirects.each do |r|
      response = Response.new(r[:url], r[:redirect_url], connection)

      if response.is_correct_redirect?
        puts "✅  Redirect successful: #{r[:url]} -> #{r[:redirect_url]}"
      else
        puts "❌  Redirect incorrect: #{r[:url]} - #{response.error_message}"
      end
    end
  end

private

  def connection
    @connection ||= Faraday.new(headers: { accept_encoding: 'none' }) do |faraday|
      faraday.adapter Faraday.default_adapter
      faraday.basic_auth(user, password) if ENV.has_key?("BASIC_AUTH_CREDENTIALS")
    end
  end

  def user
    creds[0]
  end

  def password
    creds[1]
  end

  def creds
    ENV["BASIC_AUTH_CREDENTIALS"].split(":")
  end
end
