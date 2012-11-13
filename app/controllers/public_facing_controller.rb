class PublicFacingController < ApplicationController
  helper :all
  before_filter :set_cache_control_headers
  before_filter :set_search_path
  before_filter :restrict_request_formats

  private

  def set_cache_control_headers
    expires_in Whitehall.default_cache_max_age, public: true
  end

  def set_search_path
    response.headers[Slimmer::Headers::SEARCH_PATH_HEADER] = search_path
  end

  def error(status_code)
    render status: status_code, text: "#{status_code} error"
  end

  def restrict_request_formats
    allowed_formats = [Mime::HTML, Mime::JSON, Mime::XML, Mime::ATOM, Mime::ALL]
    error(406) unless allowed_formats.include?(request.format)
  end

  def set_expiry(duration = 30.minutes)
    unless Rails.env.development?
      expires_in(duration, public: true)
    end
  end
end
